function F = plotchangepoint(CP, scales, cpar)
% F = PLOTCHANGEPOINT(CP, scales, cpar)
%
% PLOTCHANGEPOINT plots the output of changepoint.m
%
% Input:
% CP        Output of changepoint.m
% scales    An array of scales to plot, or 'all' (def: 'all')
%                   1 = highest detail resolution (d1)
%                   n = lowest detail resolution (dn)
%               n + 1 = approximation 
% cpar      'cp': plot vertical lines at cpsecs (def: 'cp')
%           'ar': plot vertical lines at arsecs
%
% Output:
% F         Structure containing figure handles
%
% For both examples, first run:
%    sacf = 'm12.20130416T105310.sac';
%    [x, h] = readsac(sacf);
%    CP = changepoint('time', x, 3, h.DELTA, h.B)%
%
% Ex1: Plot all changepoints
%    F = plotchangepoint(CP, 'all', 'cp')
%
% Ex2: Plot arrival times at for the details at scale 1, 
%      and the approximation
%    F = plotchangepoint(CP, [1 4], 'ar')
%
% See also: changepoint.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 14-Feb-2019, Version 2017b

% Defaults.
defval('scales', 'all')
defval('cpar', 'cp')

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
pl.x = plot(ha(1), CP.outputs.xax, norm_x, 'b', 'LineWidth', 1.5 * lw);
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

% If 'time-scale' domain check if smoothed with 'fml' option, this
% changes how it's plotted.
if ~isempty(CP.inputs.fml)
    issmooth = true;

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

      case 'ar'
        vlsecs = CP.arsecs{i};
        
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
                            'k', 'LineWidth', lw);
            pl.aicj{i} = plot(ax, smooth_xvals, norm_aicj, 'Color', ...
                              purp, 'LineWidth', lw);
            pl.vl{i} = plot(ax, [vlsecs vlsecs], [0 1.25], 'r', 'LineWidth', 1.5 * lw);

        else
            % No smoothing requested: twice-replicate the normalized data so that
            % they may be plotted over their representative time
            % smear.
            yvals_da = repmat(norm_da, 1, 2);
            yvals_aicj = repmat(norm_aicj, 1, 2);
            xvals = CP.outputs.wtxax{i};

            for j = 1:length(da)
                if length(xvals(j, :)) == 1
                    linesty = '+';

                else
                    linesty = '-';

                end
                
                pl.da{i}(j) = plot(ax, xvals(j, :), yvals_da(j,:), ...
                                   'k', 'LineStyle', linesty, 'LineWidth', lw);
                
                pl.aicj{i}(j) = plot(ax, xvals(j,:), yvals_aicj(j,:), ...
                                     'Color', purp, 'LineStyle', ...
                                     linesty, 'LineWidth', lw);

            end
            % Mark changepoint or arrival times with two vertical lines bracketing
            % the total time smear of the changepoint/arrival time-scale
            % index.
            pl.vl{i}(1) = plot(ax, [vlsecs(1) vlsecs(1)], [0 1.25], 'r', 'LineWidth', 1.5 * lw);
            pl.vl{i}(2) = plot(ax, [vlsecs(2) vlsecs(2)], [0 1.25], 'r', 'LineWidth', 1.5 * lw);
            
        end
    else 
        xvals = CP.outputs.xax;
        yvals_da = norm_da;
        yvals_aicj = norm_aicj;
        
        pl.da{i} = plot(ax, xvals, yvals_da, 'k', 'LineWidth', lw);
        pl.aicj{i} = plot(ax, xvals, yvals_aicj, 'Color', purp, 'LineWidth', lw);

        % Mark changepoint or arrival time with single vertical line because
        % there is no time-scale smear in the case of a time-domain
        % changepoint estimation (this is not to say there is no
        % uncertainty!)
        pl.vl{i}(1) = plot(ax, [vlsecs(1) vlsecs(1)], [-1.25 1.25], 'r', 'LineWidth', 1.5 * lw);

    end
    hold(ax, 'off')

    % Label the y-axis.
    if i == length(CP.outputs.da)
        info_str = 'approximation';
        lbl_str = sprintf('$a_{%i}$', i - 1);
        
    else
        info_str = 'detail';
        lbl_str = sprintf('$d_{%i}$', i);
        
    end
    ylabel(ax, sprintf('%s', lbl_str))

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
