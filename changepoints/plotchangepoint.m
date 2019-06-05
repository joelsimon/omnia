function F = plotchangepoint(CP, scales, cpar)
% F = PLOTCHANGEPOINT(CP, scales, cpar)
%
% PLOTCHANGEPOINT plots the output of changepoint.m, i.e., multiscale
% arrival-time identifications for an input time series.
%
% Input:
% CP        Output of changepoint.m
% scales    An array of scales to plot, or 'all' (def: 'all')
% cpar      'ar': plot vertical lines at arsecs (def)
%           'cp': plot vertical lines at cpsecs 

% Output:
% F         Structure containing figure handles
%
% For both examples, first run:
%    sacf = 'm12.20130416T105310.sac';
%    [x, h] = readsac(sacf);
%    CP = changepoint('time', x, 3, h.DELTA, h.B)
%
% Ex1: Plot all changepoints
%    F = PLOTCHANGEPOINT(CP, 'all', 'cp')
%
% Ex2: Plot arrival times at for the details at scale 1, 
%      and the approximation
%    F = PLOTCHANGEPOINT(CP, [1 4], 'ar')
%
% See also: changepoint.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 14-Feb-2019, Version 2017b

% Defaults.
defval('scales', 'all')
defval('cpar', 'ar')

if strcmp(lower(scales), 'all')
    scales = 1:length(CP.outputs.da);

else
    if ~all(isint(scales)) || min(scales) < 1 || max(scales) > ...
            length(CP.cpsamp) || length(scales(:)) > length(CP.cpsamp)
        error(['Specify ''all'' or an of integers between 1 and %i ' ...
               'for input: scales'], length(CP.cpsamp))

    end
end
[~, ha] = krijetem(subnum(length(scales) + 1, 1));
fig2print(gcf, 'fportrait');
lw = 1;

% Plot normalized time series in first subplot.
norm_x = norm2ab(CP.x, -1, 1);
pl.x = plot(ha(1), CP.outputs.xax, norm_x, 'Color', 'blue', 'LineWidth', 1.5 * lw);
ylim(ha(1), [-1.25 1.25])
ylabel(ha(1), '$x$')

% Anonymous functions to normalize data (called below) between:
% [0:1] for time-scale domain (absolute values)
% [-1:1] for time domain.
if strcmp(CP.domain, 'time-scale')
    normfunc = @(xx) norm2ab(abs(xx), 0, 1);

else 
    normfunc = @(xx) norm2ab(xx, -1, 1);
    
end

% AIC-pick  colors.
col.tsf =  [0 1 1]; 
col.tsm = [1 0 0]; 
col.tsl = [0.5 1 0]; 
col.t = [0.5 0 1];

% If 'time-scale' domain check if smoothed with 'fml' option, this
% changes how it's plotted.
if ~isempty(CP.inputs.fml)
    issmooth = true;
    
    % Per the color-scheme of Simon & Simons, 2019: start of smear is
    % blue; middle of smear is red; end of smear is green.    switch CP.inputs.fml
    switch CP.inputs.fml
      case 'first'
        Color =  col.tsf;
        
      case 'middle'
        Color = col.tsm;
        
      case 'last'
        Color = col.tsl;
        
    end
        
else
    issmooth = false;

end

ax_idx = 1;
for i = scales
    ax_idx = ax_idx + 1;
    ax = ha(ax_idx);  
    hold(ax, 'on')

    % Extract relevant data from changepoint structure.
    da = CP.outputs.da{i};
    aicj = CP.outputs.aicj{i};
    switch lower(cpar)
      case 'cp'
        vlsecs = CP.cpsecs{i};
        dabe = CP.cpsamp{i};

      case 'ar'
        vlsecs = CP.arsecs{i};
        dabe = CP.arsamp{i};

      otherwise
        error('Specify either ''cp'' for changepoint or ''ar'' for arrival for input: cpar')
        
    end

    % Normalize the data using the anonymous functions defined above loop.
    norm_da = normfunc(da);
    norm_aicj = normfunc(aicj);

    if strcmp(CP.domain, 'time-scale')
        if issmooth
            % Smoothing requested: smooth abe/dbe time smears to a single, 'representative' sample.
            smooth_xvals = CP.outputs.xax(CP.outputs.dabe{i});
            pl.da{i} = plot(ax, smooth_xvals, norm_da, 'Color', ...
                            [0.5 0.5 0.5], 'LineWidth', lw);
            pl.aicj{i} = plot(ax, smooth_xvals, norm_aicj, 'Color', ...
                              'k', 'LineWidth', lw);
            pl.vl{i} = plot(ax, [vlsecs vlsecs], [0 1.25], 'r', ...
                            'LineWidth', 1.5 * lw, 'Color', Color);

        else
            % No smoothing requested: twice-replicate the normalized data so that
            % they may be plotted over their representative time smear.
            yvals_da = repmat(norm_da, 1, 2);
            yvals_aicj = repmat(norm_aicj, 1, 2);
            xvals = CP.outputs.wtxax{i};

            % This switches marker type if the length of the time-smear is a
            % single point and not a line.
            for j = 1:length(da)
                if length(xvals(j, :)) == 1
                    linesty = '+';
  
              else
                    linesty = '-';

                end

                pl.da{i}(j) = plot(ax, xvals(j, :), yvals_da(j,:), ...
                                   'Color', [0.5 0.5 0.5], 'LineStyle', ...
                                   linesty, 'LineWidth', lw);
                
                pl.aicj{i}(j) = plot(ax, xvals(j,:), yvals_aicj(j,:), ...
                                     'Color', 'k', 'LineStyle', ...
                                     linesty, 'LineWidth', lw);

            end

            % Mark changepoint or arrival times with three vertical lines: the
            % left edge; middle; and right-edge of the time smear of
            % the specific detail/approx. coefficient.
            if ~isnan(vlsecs)
                left_secs = vlsecs(1);
                right_secs = vlsecs(2);

                % To compute seconds at middle of time-smear I am using the actual
                % samples of the time smear and not simply taking the mean
                % of the seconds -- the mean time may not actually
                % correspond to any given sample; hence I round to sample
                % first before converting to seconds.
                middle_sample = round(mean(dabe));  % See smoothscale.m
                middle_secs = CP.outputs.xax(middle_sample);

                pl.vl{i}(1) = plot(ax, repmat(left_secs, 1, 2), [0 1.25], ...
                                   'r', 'LineWidth', 1.5 * lw, 'Color', col.tsf);
                pl.vl{i}(2) = plot(ax, repmat(middle_secs, 1, 2), [0 ...
                                    1.25], 'r', 'LineWidth', 1.5 * lw, ...
                                   'Color', col.tsm);
                pl.vl{i}(3) = plot(ax, repmat(right_secs, 1, 2), [0 1.25], ...
                                   'r', 'LineWidth', 1.5 * lw, 'Color', col.tsl);           

            end
        end
        % Label the y-axis.
        if i == length(CP.outputs.da)
            lbl_str = sprintf('$a_{%i}$', i - 1);
            
        else
            lbl_str = sprintf('$d_{%i}$', i);
            
        end
        ylabel(ax, sprintf('%s', lbl_str))

    else 
        % Domain == 'time'.
        xvals = CP.outputs.xax;
        yvals_da = norm_da;
        yvals_aicj = norm_aicj;
        
        pl.da{i} = plot(ax, xvals, yvals_da, 'Color', [0.5 0.5 0.5], ...
                        'LineWidth', lw);
        pl.aicj{i} = plot(ax, xvals, yvals_aicj, 'Color', 'k', ...
                          'LineWidth', lw);

        % Mark changepoint or arrival time with single vertical line because
        % there is no time-scale smear in the case of a time-domain
        % changepoint estimation (this is not to say there is no
        % uncertainty!)
        pl.vl{i}(1) = plot(ax, [vlsecs(1) vlsecs(1)], [-1.25 1.25], ...
                           'r', 'LineWidth', 1.5 * lw, 'Color', col.t);

        % Label the y-axis.
        if i == length(CP.outputs.da)
            lbl_str = sprintf('$\\overline{x}_{%i}$', i - 1);
            
        else
            lbl_str = sprintf('$x_{%i}$', i);
            
        end
        ylabel(ax, sprintf('%s', lbl_str))


    end
    hold(ax, 'off')


end
set(ha, 'XLim', [CP.outputs.xax(1) CP.outputs.xax(end)])
set(ha, 'Box', 'on')
set(ha, 'TickDir', 'out')

if strcmp(CP.domain, 'time-scale')
    set(ha(2:end), 'YLim', [0 1.25])
    set(ha(2:end), 'YTick', [0 : 0.5 : 1])

else
    set(ha, 'YLim', [-1.25 1.25])
    set(ha, 'YTick', [-1 : 1])

end

latimes
F.ha = ha;
F.pl = pl;
shg
