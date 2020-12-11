function  F = ploteqcp(EQ, CP, sac)
% F = PLOTEQCP(EQ, CP, sac)
%
% Plots time series in CP, and annotates with phase-arrival times in EQ.
%
% Useful for annotation based using a single (e.g., the reviewed), or multiple
% (e.q., the raw) EQ structure(s), as is latter case in cpsac2evt.m
%
% Input:
% EQ      EQ structure(s), e.g. from cpsac2evt.m
% CP      CP structure, e.g. from cpsac2evt.m
% sac     SAC file used to generated EQ and CP
%
% Output:
% F       Struct of figure bits
%
% Ex: (only plot phases kept after manual review in reviewevt.m)
%    sac = '20180819T042909.08_5B7A4C26.MER.DET.WLT5.sac';
%    EQ = getevt(sac); % first output is reviewed EQ structure
%    CP = getcp(sac);
%    F = PLOTEQCP(EQ, CP, sac)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 11-Dec-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Some plotting defaults.
LineWidth = 1;

% Plot arrival times for all scales -- in case of time-scale domain,
% smooth by setting abe/dbe to central point of the time smear.
F.fig = figure;
F.f = plotchangepoint(CP, 'all', 'ar', false, true);

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
        movev(F.f.ha(l), multiplier * 0.015)

    end
    movev(F.f.ha, -0.1)

  otherwise
    % Add to this list with trial and error given more examples with
    % differing sampling frequencies.
    warning('No figure formatting scheme available for %i %s', CP.n, ...
            plurals('scale', CP.n))

end

% Remove x-tick labels from all but last plot and label the lower x-axis.
set(F.f.ha(1:end-1), 'XTickLabel', '')

if ~isempty(EQ)
    % Title the seismogram (first subplot).
    ax = F.f.ha(1);
    hold(ax, 'on')
    F.tl = title(ax, titlecase(EQ(1).FlinnEngdahlRegionName), 'FontSize', ...
                    17, 'FontWeight', 'normal');
    F.tl.Position(2) = ax.YLim(2) + 0.4*range(ax.YLim);

    % Mark all arrivals on the seismogram (first subplot).
    for j = 1:length(EQ)
        for k = 1:length(EQ(j).TaupTimes)
            tp = EQ(j).TaupTimes(k);
            tparr = tp.truearsecs;

            if tparr >= CP.outputs.xax(1) && ...
                        tparr <= CP.outputs.xax(end)
                F.tp{j}{k} = plot(ax, repmat(tparr, [1, 2]), ...
                                     ax.YLim, 'k--', 'LineWidth', LineWidth);
                phstr = sprintf('\\textit{%s}$_{%i}$', tp.phaseName, j);
                F.tx{j}{k} = text(ax, tparr, 0, phstr, ...
                                     'HorizontalAlignment', 'Center');
                F.tx{j}{k}.Position(2) = ax.YLim(2) + 0.2*range(ax.YLim);

            else
                F.tp{j}{k} = [];
                F.tx{j}{k} = [];

            end
        end
    end
    hold(ax, 'off')

    % Highlight the first-arriving phase associated with the largest event.
    if ~isempty(F.tp{1}{1})
        F.tp{1}{1}.Color = 'r';
        F.tp{1}{1}.LineStyle = '-';
        F.tp{1}{1}.LineWidth = 2*LineWidth;
        F.tx{1}{1}.Position(2) = ax.YLim(2) + 0.3*range(ax.YLim);
        F.tx{1}{1}.FontSize = 25;
        F.tx{1}{1}.FontWeight = 'bold';

    end

    % Make the magnitude string.
    magtype = lower(EQ(1).PreferredMagnitudeType);
    if ~strcmpi(magtype(1:2), 'mb')
        magstr = sprintf('\\textit{%s}$_{\\mathrm{%s}}$ %2.1f', upper(magtype(1)), ...
                         lower(magtype(2)), EQ(1).PreferredMagnitudeValue);

    else
        magstr = sprintf('\\textit{%s}$_{\\mathrm{%s}}$ %2.1f', lower(magtype(1)), ...
                         lower(magtype(2:end)), EQ(1).PreferredMagnitudeValue);

    end
    depthstr = sprintf('%.2f~km', EQ(1).PreferredDepth);
    diststr = sprintf('%.2f$^{\\circ}$', EQ(1).TaupTimes(1).distance);

    [F.f.lgmag, F.f.lgmagtx] = textpatch(ax, 'NorthWest', magstr);
    [F.f.lgdist, F.lgdisttx] = textpatch(ax, 'SouthWest', [diststr ', ' depthstr]);

end

% This time is w.r.t. the reference time in the SAC header, NOT
% seisdate.B. CP.xax has the time of the first sample (input:
% pt0) assigned to h.B, meaning it is an offset from some
% reference (in this case, the reference time in the SAC
% header).  The time would be relative to seisdate.B if I had
% input pt0 = 0, because seisdate.B is EXACTLY the time at the
% first sample, i.e., we start counting from 0 at that time.
[~, h] = readsac(sac);
[~, ~, ~, refdate] = seistime(h);
F.f.ha(end).XLabel.String = sprintf('Time relative to %s UTC (s)\n[%s]', ...
                                       datestr(refdate), ...
                                       strrep(strippath(sac), '_', '\_'));
longticks(F.f.ha, 3);
latimes(F.fig);

%  The axes have been shifted due to adjusting the font, interpreter, tick
% lengths etc. -- need to adjust the second (AIC) adjust and re-tack2corner the
 % annotations.
for l = 1:length(F.f.ha)
    F.f.ha2(l).Position = F.f.ha(l).Position;
    F.f.ha2(l).YAxis.TickLabelFormat = '%#.2g';
    numticks(F.f.ha(l), 'y', 3);
    numticks(F.f.ha2(l), 'y', 3);

end

% Ensure vertical lines extend minmax adjusted axes (don't wrap into loop above;
% there is one less .vl than axes handle, ha).
for j = 1:length(F.f.pl.vl)
    F.f.pl.vl{j}.YData = F.f.pl.vl{j}.Parent.YLim;

end

if ~isempty(EQ)
    tack2corner(F.f.ha(1), F.f.lgmag, 'NorthWest');
    tack2corner(F.f.ha(1), F.f.lgdist, 'SouthWest');

    for l = 1:length(F.f.lgSNR)
        tack2corner(F.f.ha(l+1), F.f.lgSNR(l), 'SouthWest');

    end
end
