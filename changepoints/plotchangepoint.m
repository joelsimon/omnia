function F = plotchangepoint(CP, scales, cpar, normaleyes, symmetric)
% F = PLOTCHANGEPOINT(CP, scales, cpar, normaleyes, symmetric)
%
% PLOTCHANGEPOINT plots the output of changepoint.m, i.e., multiscale
% changepoint (or arrival-time) identifications for an input time series.
%
% Input:
% CP           Output of changepoint.m
% scales       An array of scales to plot, or 'all' (def: 'all'),
%                  where scale n+1 approximation at scale n.
% cpar         'ar': plot vertical lines at arsecs (def)
%              'cp': plot vertical lines at cpsecs
% normaleyes   true to normalize plots (def: true)
% symmetric    true to make y-axis symmetric about 0 (def: true)
%
%
% Output:
% F         Structure containing figure handles
%
% For all examples below first run:
%    sacf = 'm12.20130416T105310.sac';
%    [x, h] = readsac(sacf);
%    CPt = changepoint('time', x, 3, h.DELTA, h.B);
%    CPts = changepoint('time-scale', x, 3, h.DELTA, h.B);
%    CPtss = changepoint('time-scale', x, 3, h.DELTA, h.B, [], [], [], 'last');
%
% Ex:
%    PLOTCHANGEPOINT(CPt, 'all', 'cp', false, false)
%    PLOTCHANGEPOINT(CPt, 'all', 'cp', false, true)
%    PLOTCHANGEPOINT(CPt, [2:4], 'ar', true, true)
%    PLOTCHANGEPOINT(CPt, [1 3 4], 'ar', true, false)
%    PLOTCHANGEPOINT(CPts, [1 3 4], 'cp', false, false)
%    PLOTCHANGEPOINT(CPts, [2:4], 'cp', false, true)
%    PLOTCHANGEPOINT(CPts, 'all', 'ar', true, true)
%    PLOTCHANGEPOINT(CPts, 3, 'ar', true, false)
%    PLOTCHANGEPOINT(CPtss, 3, 'cp', false, true)
%    PLOTCHANGEPOINT(CPtss, 'all', 'ar', true, false)
%    PLOTCHANGEPOINT(CPtss, [4:-1:1], 'ar', true, true)
%
% See also: changepoint.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 28-Jan-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults.
defval('scales', 'all')
defval('cpar', 'ar')
defval('normaleyes', true)
defval('symmetric', true)

% Determine the number of subplots to make based on requested scales to plot.
if strcmpi(scales, 'all')
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
LineWidth = 1;

% Plot normalized time series in first subplot, ha(1).
x = CP.x;
if normaleyes
    x = norm2max(CP.x);

end
pl.x = plot(ha(1), CP.outputs.xax, x, 'Color', 'blue', 'LineWidth', 1.5 * LineWidth);
if symmetric
    symaxes(ha(1), 'y');

end
numticks(ha(1), 'y', 3);
ylabel(ha(1), '$x$')

% Generate empty axes so indexing is the same -- there will be two
% axes overlain on each other in each subplot; the second holds the
% AIC curve.  There is no AIC curve for the raw data, so just leave it
% empty.
ha2(1) = axes;
ha2(1).Visible = 'off';

% Anonymous functions to normalize data (called below) between:
% [0:1] for time-scale domain (absolute values)
% [-1:1] for time domain.
if strcmp(CP.domain, 'time-scale')
    da_normfunc = @(xx) norm2ab(xx, 0, 1);
    aic_normfunc = @(xx) norm2ab(xx, 0, 1);

else
    % The normalization of the data (da) and the AIC curve (aicj) differ
    % because, generally, the waveform (da) has both positive and
    % negative values and thus normalizing to the maximum
    % negative/positive value is sufficient while not artificially
    % moving the mean of the waveform away from 0 (which happens if
    % the waveform is very non-symmetric; i.e. a large negative and
    % small positive value are both assigned -1 and +1 and thus the
    % mean of the waveform plotted is shifting above 0).  The AIC
    % curve is much flatter and thus we want to normalize between -1
    % and +1; if we normalized to its maximum negative or positive
    % value the AIC curve would appear flat.
    da_normfunc = @(xx) norm2max(xx);
    aic_normfunc = @(xx) norm2ab(xx, -1, 1);

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

% Axis index: starts at 1 because we have already plotted the raw input, CP.x, in ha(1).
ax_idx = 1;
sc_idx = 0;
for i = scales
    % Update the axes and scale indices.
    ax_idx = ax_idx + 1;
    sc_idx = sc_idx + 1;

    % Make current axes active.
    ax = ha(ax_idx);
    ha2(ax_idx) = axes;
    ax2 = ha2(ax_idx);
    hold(ax2, 'on')

    % Extract relevant data from changepoint structure.
    da = CP.outputs.da{i};
    aicj = CP.outputs.aicj{i};

    % Are we plotting the changepoint or the arrival?
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

    %% Time-scale domain
    %__________________________________________________________________________%
    if strcmp(CP.domain, 'time-scale')
        % In the time-scale domain plot the absolute values of the detail and
        % approximation coefficients (e.g., like a scalogram).
        da = abs(da);

        if normaleyes
            da = da_normfunc(da);
            aicj = aic_normfunc(aicj);
            ax.YLim = [0 1];
            ax2.YLim = [0 1];

        end

        hold(ax, 'on')
        if issmooth
            % Smoothing requested: smooth abe/dbe time smears to a single, 'representative' sample.
            smooth_xvals = CP.outputs.xax(CP.outputs.dabe{i});

            pl.da{sc_idx} = plot(ax, smooth_xvals, da, 'Color', ...
                            [0.5 0.5 0.5], 'LineWidth', LineWidth);

            pl.aicj{sc_idx} = plot(ax2, smooth_xvals, aicj, 'Color', ...
                              'k', 'LineWidth', LineWidth);

            pl.vl{sc_idx} = plot(ax2, [vlsecs vlsecs], ax2.YLim, ...
                            'LineWidth', 1.5 * LineWidth, 'Color', Color);

            set(pl.da{sc_idx}, 'Color', [0.5 0.5 0.5], 'LineWidth', LineWidth);
            set(pl.aicj{sc_idx}, 'Color', 'k', 'LineWidth', LineWidth);

        else
            % No smoothing requested: twice-replicate the normalized data so that
            % they may be plotted over their representative time smear.
            yvals_da = repmat(da, 1, 2);
            yvals_aicj = repmat(aicj, 1, 2);
            xvals = CP.outputs.wtxax{i};

            % This switches marker type if the length of the time-smear is a
            % single point and not a line.
            for j = 1:length(da)
                if length(xvals(j, :)) == 1
                    LineStyle = '+';

                else
                    LineStyle = '-';

                end

                pl.da{sc_idx}(j) = plot(ax, xvals(j, :), yvals_da(j,:), ...
                                   'Color', [0.5 0.5 0.5], 'LineStyle', ...
                                   LineStyle, 'LineWidth', LineWidth);
                pl.aicj{sc_idx}(j) = plot(ax2, xvals(j,:), yvals_aicj(j,:), ...
                                     'Color', 'k', 'LineStyle', ...
                                     LineStyle, 'LineWidth', LineWidth);

            end

            if ~isnan(vlsecs)
                % Mark changepoint or arrival times with three vertical lines: the
                % left edge; middle; and right-edge of the time smear
                % of the specific detail/approx. coefficient.
                left_secs = vlsecs(1);
                right_secs = vlsecs(2);

                % To compute seconds at middle of time-smear I am using the actual
                % samples of the time smear and not simply taking the
                % mean of the seconds -- the mean time may not
                % actually correspond to any given sample; hence I
                % round to sample first before converting to seconds.
                middle_sample = smoothscale({dabe}, 'middle');
                middle_secs = CP.outputs.xax(middle_sample{:});

            else
                left_secs = NaN;
                right_secs = NaN;
                middle_secs = NaN;

            end
            pl.vl{sc_idx}(1) = plot(ax2, repmat(left_secs, 1, 2), ax2.YLim, ...
                                    'LineWidth', 1.5 * LineWidth, 'Color', col.tsf);
            pl.vl{sc_idx}(2) = plot(ax2, repmat(middle_secs, 1, 2), ax2.YLim, ...
                                    'LineWidth', 1.5 * LineWidth, 'Color', col.tsm);
            pl.vl{sc_idx}(3) = plot(ax2, repmat(right_secs, 1, 2), ax2.YLim, ...
                                    'LineWidth', 1.5 * LineWidth, 'Color', col.tsl);
        end

        % Label the y-axis.
        if i == length(CP.outputs.da)
            lbl_str = sprintf('$a_{%i}$', i - 1);

        else
            lbl_str = sprintf('$d_{%i}$', i);

        end
        ylabel(ax, sprintf('%s', lbl_str))
        hold(ax, 'off')

    %__________________________________________________________________________%
    %% Time domain
    else
        if normaleyes
            da = da_normfunc(da);
            aicj = aic_normfunc(aicj);
            ax.YLim = [-1 1];
            ax2.YLim = [-1 1];

        end

        xvals = CP.outputs.xax;
        yvals_da = da;
        yvals_aicj = aicj;

        pl.da{sc_idx} = plot(ax, xvals, yvals_da, 'Color', [0.5 0.5 0.5], ...
                        'LineWidth', LineWidth);
        pl.aicj{sc_idx} = plot(ax2, xvals, yvals_aicj, 'Color', 'k', ...
                          'LineWidth', LineWidth);

        % Mark changepoint or arrival time with single vertical line because
        % there is no time-scale smear in the case of a time-domain
        % changepoint estimation (this is not to say there is no
        % uncertainty!)
        pl.vl{sc_idx}(1) = plot(ax2, [vlsecs(1) vlsecs(1)], ax2.YLim, ...
                           'LineWidth', 1.5 * LineWidth, 'Color', col.t);

        % Label the y-axis.
        if i == length(CP.outputs.da)
            lbl_str = sprintf('$\\overline{x}_{%i}$', i - 1);

        else
            lbl_str = sprintf('$x_{%i}$', i);

        end
        ylabel(ax, sprintf('%s', lbl_str))

        if symmetric && ~normaleyes
            symaxes(ax, 'y');

        end
    end
    hold(ax2, 'off')
    numticks(ax, 'y', 3);

    set(ax, 'YColor', [0.5 0.5 0.5]);
    set(ax2, 'Position', ax.Position, 'Visible', 'off', 'YAxisLocation', 'right', ...
             'TickDir', 'out');
    ylabel(ax2, '$\mathcal{A}$');
    ax2.YAxis.Visible = 'on';

end
set(ha, 'XLim', [CP.outputs.xax(1) CP.outputs.xax(end)])
set(ha, 'Box', 'on')
set(ha, 'TickDir', 'out')

latimes

% Realign axes after adjusting fonts, set YTick positions equal to
% each other using numticks, and ensure proper YLim of vertical lines,
% which were likely adjusted when the axes were tacked together.
ax_idx = 1;
sc_idx = 0;
for i = scales
    % Loop over the scales updating the axis and scale indices.
    ax_idx = ax_idx + 1;
    sc_idx = sc_idx + 1;

    set(ha2(ax_idx), 'Position', ha(ax_idx).Position, 'XLim', ha(ax_idx).XLim);
    numticks(ha2(ax_idx), 'y', 3);

    % Add SNR annotation in bottom left corner
    [lgSNR(sc_idx), txSNR(sc_idx)] = textpatch(ax2, [], sprintf('$\\mathrm{SNR}~=~%.1f$', CP.SNRj(i)));
    tack2corner(ha2(ax_idx), lgSNR(sc_idx), 'SouthWest');

    for j = 1:length(pl.vl{sc_idx})
        pl.vl{sc_idx}(j).YData = pl.vl{sc_idx}(j).Parent.YLim;

    end
end
F.ha = ha;
F.ha2 = ha2;
F.pl = pl;
F.lgSNR = lgSNR;
F.txSNR = txSNR;
shg
