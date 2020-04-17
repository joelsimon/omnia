% Figures 14-17 and S3
%
% Cite: Simon, J. D. et al., (2020), BSSA, doi: 10.1785/0120190173
%
% plotchangepoint.m (a local version) with travel-time-residual
% annotations and some formatting.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu | joeldsimon@gmail.com
% Last modified: 08-Apr-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
clear
close all

% This is a flag to re-generate the changepoint files for the
% TIME-SCALE case (the time domain cases are loaded from the
% MERMAID/geoazur/rematch directory).  TIME-SCALE are saved locally in
% ./Static.
makenew = false;
thisdir = fileparts(mfilename('fullpath'));

s = {'m16.20141030T121822.sac', ...
     'm31.20161028T200310.sac', ...
     'm32.20140623T193749.sac', ...
     'm12.20140614T111438.sac', ...
     'm13.20130524T060205.sac', ...
    };

filename = {'fig14', ...
            'fig15', ...
            'fig16', ...
            'fig17', ...
            'figS3', ...
            };

%% This just prints the event/station locations.
% for i = 1:length(s)
%     sac = mermaid_sacf(s{i});
%     [~, h] = readsac(mermaid_sacf(sac));
%     [ereg, ecode] = feregion(h.EVLA, h.EVLO);
%     [sreg, scode] = feregion(h.STLA, h.STLO);
%     fprintf('SAC filename: %s\n', strippath(sac))
%     fprintf('event location: %s [%s]\n', ereg, ecode)
%     fprintf('station location: %s [%s]\n\n\n', sreg, scode)

% end

diro = '~/mermaid/geoazur/rematch';
for i = 1:length(s)
    sac = mermaid_sacf(s{i});
    [x, h] = readsac(sac);
    EQ = getevt(sac, diro);

    switch efes(h)
      case 5
        n = 3;

      otherwise
        n = 5;

    end

    %CPt = changepoint('time', x, n, h.DELTA, h.B, 1, [], 1);
    CPt = getcp(sac, diro);
    Ft = ploteqcp_local(EQ, CPt, h);

    set([Ft.f.ha Ft.f.ha2], 'YLim', [-1.25 1.25], 'YTick', [-1:1])
    set(Ft.f.ha2, 'YLabel', [], 'YTickLabel', [])
    for j = 1:length(Ft.f.ha)
        Ft.f.ha(j).YAxis.Color = [0 0 0];
        Ft.f.ha2(j).XLim = Ft.f.ha(j).XLim;

    end

    Ft.f.ha(end).XTick = [0:25:Ft.f.ha(end).XLim(2)];

    tlsize = Ft.tl.FontSize;
    tht = text(Ft.f.ha(1), 0, Ft.f.ha(1).YLim(2), '(a)', 'FontName', 'Helvetica', ...
               'InterPreter','tex', 'FontWeight','Normal');
    tht.FontSize = tlsize + 4;
    movev(tht, 2.1);
    moveh(tht, -20);
    set(Ft.f.ha, 'FontSize', 13)
    Ft.tl.FontSize = tlsize;

    %% Adjust phase-name locations and text.
    if strcmp(strippath(sac),  'm12.20140614T111438.sac')
        moveh(Ft.tx{1}{3}, -2)
        moveh(Ft.tx{1}{4}, 2)

    end

    % Add note to unlikely PKiKP phase (actually: PKIKP)
    if strcmp(strippath(sac), 'm13.20130524T060205.sac')
        Ft.tx{1}{1}.String =  sprintf('Likely \\textit{PKIKP}\n(reported as \\textit{PKiKP})');
        Ft.tx{1}{1}.Position(2) = 2;

    end

    %% Update the vertical line limits so they match the expanded axes.

    % Vertical line(s) for ak135 theoretical arrival-time estimates; axis
    % 1.  Ft.tp{1} corresponds first EQ; Ft.tp{1}{2} corresponds to
    % the second phase plotted associated with first EQ.  Here we only
    % allow single EQ matches so I only have to loop over Ft.tp{1}.
    for j = 1:length(Ft.tp{1})
        Ft.tp{1}{j}.YData = Ft.f.ha(1).YLim;

    end

    % Vertical lines for AIC arrival time estimates; axes [2:end].
    for j = 1:length(Ft.f.pl.vl)
        if ~isempty(Ft.f.pl.vl{j})
            set(Ft.f.pl.vl{j}, 'YData', Ft.f.ha(j+1).YLim);

        end
    end

    %% Final lgSNR shifts because they just won't behave.
    Ft.lg(1).Position(1) = 0.1310;
    Ft.lg(2).Position(1) = 0.1310;
    for j = 1:length(Ft.f.lgSNR)
        Ft.f.lgSNR(j).Position(1) = 0.1310;

    end

    if strcmp(filename{i}, 'fig19')
        Ft.f.lgSNR(1).Position(2) =  0.7090;
        tht.Position(2) = 3.5;

    end

    savepdf(sprintf('%sa', filename{i}))
    close

    %_______________________________________________________________%
    if makenew
        fname = strippath(strrep(sac, '.sac', ''));
        writechangepoint(fname, fullfile(thisdir, 'Static'), 'time-scale', x, n, h.DELTA, h.B, 1, [], 1, []);

    end
    CPts = getcp(sac, thisdir);
    Fts = ploteqcp_local(EQ, CPts, h);

    set([Fts.f.ha(1) Fts.f.ha2(1)], 'YLim', [-1.25 1.25], 'YTick', [-1:1])
    set([Fts.f.ha(2:end) Fts.f.ha2(2:end)], 'YLim', [0 1.25], 'YTick', [-1:1])
    set(Fts.f.ha2, 'YLabel', [], 'YTickLabel', [])
    for j = 1:length(Fts.f.ha)
        Fts.f.ha(j).YAxis.Color = [0 0 0];
        Fts.f.ha2(j).XLim = Fts.f.ha(j).XLim;

    end

    Fts.f.ha(end).XTick = [0:25:Fts.f.ha(end).XLim(2)];

    tlsize = Fts.tl.FontSize;
    thts = text(Fts.f.ha(1), 0, Fts.f.ha(1).YLim(2), '(b)', 'FontName', ...
                'Helvetica', 'InterPreter','tex', 'FontWeight','Normal');
    thts.FontSize = tlsize + 4;
    movev(thts, 2.1);
    moveh(thts, -20);
    set(Fts.f.ha, 'FontSize', 13)
    Fts.tl.FontSize = tlsize;

    if strcmp(strippath(sac),  'm12.20140614T111438.sac')
        % They are both P waves (doesn't match with pP).
        moveh(Fts.tx{1}{2}, 2)
        delete(Fts.tx{1}{3})

    end

    for j = 1:length(Fts.tp{1})
        Fts.tp{1}{j}.YData = Fts.f.ha(1).YLim;

    end

    if strcmp(strippath(sac), 'm13.20130524T060205.sac')
        Fts.tx{1}{1}.String =  sprintf('Likely \\textit{PKIKP}\n(reported as \\textit{PKiKP})');
        Fts.tx{1}{1}.Position(2) = 2;

    end

    for j = 1:length(Fts.f.pl.vl)
        if ~isempty(Fts.f.pl.vl{j})
            set(Fts.f.pl.vl{j}, 'YData', Fts.f.ha(j+1).YLim);

        end
    end


    %% Final lgSNR shifts because they just won't behave.
    Fts.lg(1).Position(1) = 0.1310;
    Fts.lg(2).Position(1) = 0.1310;
    for j = 1:length(Fts.f.lgSNR)
        Fts.f.lgSNR(j).Position(1) = 0.1310;

    end
    if strcmp(filename{i}, 'fig19')
        Fts.f.lgSNR(1).Position(2) =  0.7090;
        thts.Position(2) = 3.5;

    end

    savepdf(sprintf('%sb', filename{i}));
    close

end

%__________________________________________________________%

% Local version of function this calls so this script runs in perpetuity.

function F = ploteqcp_local(EQ, CP, h)
% F = ploteqcp(EQ, CP, h)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 21-Jun-2019, Version 2017b
%% This assumes a single EQ. %%

defval('diro', fullfile(getenv('MERMAID'), 'processed'))

% Some plotting defaults.
LineWidth = 1;

%% PLOT CHANGEPOINT

% Plot arrival times for all scales -- in case of time-scale domain,
% smooth by setting abe/dbe to central point of the time smear.
F.fig = figure;
F.f = plotchangepoint_local(CP, 'all', 'ar', true, true);

%% PLOT THEORETICAL ARRIVAL TIMES.

% Title the seismogram (first subplot).
ax = F.f.ha(1);
hold(ax, 'on')
F.tl = title(ax, EQ(1).FlinnEngdahlRegionName, 'FontSize', ...
             17, 'FontWeight', 'normal');
F.tl.Position(2) = 2;

% Mark arrivals matched with the residuals.
[tres_time, tres_phase, tres_EQ, tres_TT] = tres(EQ, CP, false, 'middle');
unique_res = unique(tres_TT(~isnan(tres_TT)));

% Only plot phase labels for unique phases (the same phase may be the
% tres match across multiple scales).
for j = 1:1%length(EQ)
    for k = unique_res
        tp = EQ(j).TaupTimes(k);
        tparr = tp.arsecs;

        if tparr >= CP.outputs.xax(1) && ...
                    tparr <= CP.outputs.xax(end)
            F.tp{j}{k} = plot(ax, repmat(tparr, [1, 2]), ...
                              ax.YLim, 'k', 'LineWidth', 2*LineWidth);
            phstr = sprintf('\\textit{%s}', tp.phaseName);
            F.tx{j}{k} = text(ax, tparr, 1.7, phstr, ...
                              'HorizontalAlignment', 'Center', ...
                              'FontSize', F.tl.FontSize, 'FontWeight', 'Normal');

        else
            F.tp{j}{k} = [];
            F.tx{j}{k} = [];

        end
    end
end
hold(ax, 'off')

%% Annotate the seismogram with the largest event info.

magtype = EQ(1).PreferredMagnitudeType;
magstr = sprintf('\\textit{%s}$_{\\mathrm{%s}}$ %2.1f', upper(magtype(1)), lower(magtype(2)), ...
                 EQ(1).PreferredMagnitudeValue);
depthstr = sprintf('%.2f~km', EQ(1).PreferredDepth);
diststr = sprintf('%.2f$^{\\circ}$', EQ(1).TaupTimes(1).distance);

% Order clockwise from upper left.
ax = F.f.ha(1);
[F.lg(1), F.lgtx(1)] = textpatch(ax, 'NorthWest', magstr, F.f.lgSNR(1).FontSize);
[F.lg(2), F.lgtx(2)] = textpatch(ax, 'NorthEast', [diststr ', ' depthstr], F.f.lgSNR(1).FontSize);

set([F.f.pl.aicj{:}], 'LineWidth', LineWidth)
set([F.f.pl.da{:}], 'LineWidth', LineWidth)

% Shrink the distance between each subplot -- 'multiplier' is adjusted
% depending on the number of subplots (the number of wavelet scales
% plotted).
multiplier = 0;
switch CP.inputs.n
  case 3
    shrink(F.f.ha, 1, 1.53)
    for l = 1:length(F.f.ha)
        multiplier = multiplier + 1;
        movev(F.f.ha(l), multiplier * 0.08)

    end
    movev(F.f.ha, -0.1)

  case 5
    for l = 1:length(F.f.ha)
        multiplier = multiplier + 1;
        movev(F.f.ha(l), multiplier * 0.02)

    end
    movev(F.f.ha, -0.1)

  otherwise
    % Add to this list with trial and error given more examples with
    % differing sampling frequencies.
    warning('No figure formatting scheme available for %i %s', ...
            CP.n, plurals('scale', CP.n))

end

% Remove x-tick labels from all but last plot and label the lower x-axis.
set(F.f.ha(1:end-1), 'XTickLabel', '')
F.f.ha(1).YTick = [-1:1];

seisdate = seistime(h);

F.f.ha(end).XLabel.String = sprintf(['Time relative to %s UTC ' ...
                    '(s)\n[%s]'], datestr(seisdate.B), ...
                                    strrep(EQ(1).Filename, '_', '\_'));
F.f.ha(end).XLabel.FontSize = 13;
longticks(F.f.ha, 3)

% The axes have been shifted -- need to adjust the second (AIC) adjust and re-tack2corner the annotations.
for l = 1:length(F.f.ha)
    F.f.ha2(l).Position = F.f.ha(l).Position;

end

% Add the scale-specific SNR, tres, and fatten CP arrival marks.
for j = 1:length(CP.SNRj)
    if CP.SNRj(j) > CP.inputs.snrcut % CP.arsecs = NaN
        tres_str = sprintf(['tres. [\\textit{%s}] = %.1f s\n2$\\cdot$SD = %.1f ' ...
                            's'], tres_phase{j}, tres_time(j), ...
                           CP.ci.M1(j).twostd);

        xl = F.f.ha(j+1).XLim;
        xl = xl(2);
        yl = F.f.ha(j+1).YLim;
        F.tres{j} = text(F.f.ha(j+1), xl*1.15, mean(yl),  tres_str, ...
                         'FontSize', F.f.ha(end).XLabel.FontSize, ...
                         'HorizontalAlignment', 'Center');
        set(F.f.pl.vl{j}, 'LineWidth', 2*LineWidth)

    end
    tack2corner(F.f.ha(j+1), F.f.lgSNR(j),'SouthWest');
    F.f.ha(j+1).XLim = [0 F.f.ha(j+1).XLim(2)];

end

latimes

% Tack all legends to corners.
tack2corner(F.f.ha(1), F.lg(1), 'NorthWest')
tack2corner(F.f.ha(1), F.lg(2), 'SouthWest')
end

%_____________________________________________________%

function F = plotchangepoint_local(CP, scales, cpar, normaleyes, symmetric)
% F = PLOTCHANGEPOINT(CP, scales, cpar, normaleyes, symmetric)
%
% PLOTCHANGEPOINT plots the output of changepoint.m, i.e., multiscale
% arrival-time identifications for an input time series.
%
% Input:
% CP        Output of changepoint.m
% scales    An array of scales to plot, or 'all' (def: 'all')
% cpar      'ar': plot vertical lines at arsecs (def)
%           'cp': plot vertical lines at cpsecs
% normaleyes
% symmetric
%
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
% Last modified: 21-Jun-2019, Version 2017b

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

% Plot normalized time series in first subplot.
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
    % These two differ because, generally, the waveform (da) has both
    % positive and negative values and thus normalizing to the maximum
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

for i = scales
    ax = ha(i+1);
    ha2(i+1) = axes;
    ax2 = ha2(i+1);
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

            pl.da{i} = plot(ax, smooth_xvals, da, 'Color', ...
                            [0.5 0.5 0.5], 'LineWidth', LineWidth);

            pl.aicj{i} = plot(ax2, smooth_xvals, aicj, 'Color', ...
                              'k', 'LineWidth', LineWidth);


            pl.vl{i} = plot(ax2, [vlsecs vlsecs], ax2.YLim, ...
                            'LineWidth', 1.5 * LineWidth, 'Color', Color);

            set(pl.da{i}, 'Color', [0.5 0.5 0.5], 'LineWidth', LineWidth);
            set(pl.aicj{i}, 'Color', 'k', 'LineWidth', LineWidth);

        else
            % Now we work with exactly with the detail and approximation subspace
            % projections -- not their absolute values.
            if normaleyes
                da = da_normfunc(da);
                aicj = aic_normfunc(aicj);

            end

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

                pl.da{i}(j) = plot(ax, xvals(j, :), yvals_da(j,:), ...
                                   'Color', [0.5 0.5 0.5], 'LineStyle', ...
                                   LineStyle, 'LineWidth', LineWidth);
                pl.aicj{i}(j) = plot(ax2, xvals(j,:), yvals_aicj(j,:), ...
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

            pl.vl{i}(1) = plot(ax2, repmat(left_secs, 1, 2), ax2.YLim, ...
                               'LineWidth', 1.5 * LineWidth, 'Color', col.tsf);
            pl.vl{i}(2) = plot(ax2, repmat(middle_secs, 1, 2), ax2.YLim, ...
                               'LineWidth', 1.5 * LineWidth, 'Color', col.tsm);
            pl.vl{i}(3) = plot(ax2, repmat(right_secs, 1, 2), ax2.YLim, ...
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

    else
        % Domain == 'time'.
        if normaleyes
            da = da_normfunc(da);
            aicj = aic_normfunc(aicj);
            ax.YLim = [-1 1];
            ax2.YLim = [-1 1];

        end

        xvals = CP.outputs.xax;
        yvals_da = da;
        yvals_aicj = aicj;

        pl.da{i} = plot(ax, xvals, yvals_da, 'Color', [0.5 0.5 0.5], ...
                        'LineWidth', LineWidth);
        pl.aicj{i} = plot(ax2, xvals, yvals_aicj, 'Color', 'k', ...
                          'LineWidth', LineWidth);

        % Mark changepoint or arrival time with single vertical line because
        % there is no time-scale smear in the case of a time-domain
        % changepoint estimation (this is not to say there is no
        % uncertainty!)
        pl.vl{i}(1) = plot(ax2, [vlsecs(1) vlsecs(1)], ax2.YLim, ...
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
for i = 1:length(ha2) - 1
    set(ha2(i+1), 'Position', ha(i+1).Position, 'XLim', ha(i+1).XLim);
    numticks(ha2(i+1), 'y', 3);

    % Add SNR annotation in bottom left corner
    [lgSNR(i), txSNR(i)] = textpatch(ax2, [], sprintf('$\\mathrm{SNR}~=~%.1f$', CP.SNRj(i)));
    tack2corner(ha2(i+1), lgSNR(i), 'll');

    for j = 1:length(pl.vl{i})
        pl.vl{i}(j).YData = ha2(i+1).YLim;

    end
end
F.ha = ha;
F.ha2 = ha2;
F.pl = pl;
F.lgSNR = lgSNR;
F.txSNR = txSNR;
shg
end
