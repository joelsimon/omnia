function [f, ax, tx, pl] = plotfirstarrival(s, ax, FontSize, EQ, ci, wlen, ...
                                            lohi, sacdir, evtdir, bathy, wlen2, ...
                                            fs, popas, hardcode_twosd) % last input hidden
% [f, ax, tx, pl] = PLOTFIRSTARRIVAL(s, ax, FontSize, EQ, ci, wlen, lohi, ...
%                                    sacdir, evtdir, bathy, wlen2, fs, popas)
%
% Plots the output of firstarrival.m, with a time-axis centered on
% theoretical first-phase-arrival time.
%
% s        SAC filename (def: '20180819T042909.08_5B7A4C26.MER.DET.WLT5.sac')
% ax       Axis handle, or [] to generate new (def: [])
% FontSize 1 x 2 array of large and small fonts (def: [14 12])
% EQ       EQ structure against which to compute travel time residuals,
%              or [] if event is reviewed and to be retrieved with
%              getevt.m (def: [])
% ci       logical true to estimate arrival time uncertainty via
%              1000 realizations of M1 method (def: false)*
% wlen     Window length [s] centered on the 'syn', the theoretical
%              first arrival, to consider for AIC pick (def: 30)
% lohi     1 x 2 array of corner frequencies, or NaN to skip
%              bandpass and use raw data (def: [1 5]])
% sacdir   Directory containing (possibly subdirectories)
%              of .sac files (def: $MERMAID/processed)
% evtdir   Directory containing (possibly subdirectories)
%              of .evt files (def: $MERMAID/events)
% bathy    logical true apply bathymetric travel time correction,
%              computed with bathtime.m (def: false)
% wlen2    Length of second window, starting at the 'dat', the time of
%              the first arrival, in which to search for maxc_y [s]
%              (def: 1)
% fs       Re-sampled frequency (Hz) after decimation, or []
%              to skip decimation (def: [])
% popas    1 x 2 array of number of poles and number of passes for bandpass
%              (def: [4 1])
%
% Output:
% f        Figure handle
% ax       Axis handle
% tx       textpatch.m handles where, e.g., tx.ul is 'upper left'
% pl       Handles to various lines plotted
%
% *AIC picker and uncertainty estimator from
% Simon, J. D. et al., (2020), BSSA, doi: 10.1785/0120190173
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu | joeldsimon@gmail.com
% Last modified: 22-Apr-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults.
defval('s', '20180819T042909.08_5B7A4C26.MER.DET.WLT5.sac')
defval('ax', [])
defval('FontSize', [14 12])
defval('EQ', [])
defval('ci', true)
defval('wlen', 30)
defval('lohi', [1 5])
defval('sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('bathy', true)
defval('wlen2', 1)
defval('fs', [])
defval('popas', [4 1])
defval('hardcode_twosd', []) % hidden input -- see note at bottom

% Generate new axis if one not supplied.
if isempty(ax)
    f = figure;
    ax = gca;

else
    f = ax.Parent;

end
hold(ax, 'on')

% Compute first-arrival statistics.
[tres, ~, syn, ~, ph, delay, twosd, xw1, xaxw1, maxc_x, maxc_y, SNR, EQ, W1] = ...
    firstarrival(s, ci, wlen, lohi, sacdir, evtdir, EQ, bathy, wlen2, fs, popas);

% Overwrite the uncertainty estimate, if one supplied as hidden input.
if ~isempty(hardcode_twosd)
    warning(sprintf('\n\n!! using hardcoded two-standard deviation error estimate !!\n\n'))
    twosd = hardcode_twosd;

end

% Plot time series (noise in gray).
% This is the ARRIVAL sample; not CHANGEPOINT sample (last sample of noise)
arsamp = find(xaxw1 == tres);

% Connect the noise to the arrival -- make the first sample of the arrival colored.
pl.noise = plot(ax, xaxw1(1:arsamp), xw1(1:arsamp), 'LineWidth', 1, 'Color', [0.6 0.6 0.6]);
pl.signal = plot(ax, xaxw1(arsamp:end), xw1(arsamp:end), 'LineWidth', 1, 'Color', 'blue');
ax.FontSize = FontSize(2);

% Adjust title if travel-time residual uses corrected theoretical (tstar) phase
% arrival time.
if bathy
    tstr = '$t^{\star}_\mathrm{res}$';

else
    tstr = '$t_\mathrm{res}$';

end

% Label the axis.
title(sprintf('%s = %.2f s [max. %.2f s later]', tstr, tres, delay), ...
      'FontWeight', 'Normal', 'FontSize', FontSize(1))
sacname = strippath(strrep(s, '_', '\_'));
ylabel(sprintf('Amplitude\n[max. %.1e]', maxc_y), 'FontSize', FontSize(1))
xlabel(sprintf('Time relative to \\textit{%s}-phase (s)\n[%s]', ph, ...
               sacname), 'FontSize', FontSize(1))

% Adjust the axis.
xlim([-wlen/2 wlen/2])
rangey = range(xw1) * 1.1;  % Expand by some multiple of the range of the windowed segment.
ylim([-rangey rangey])

% Force 5 ticks on x-axis.
numticks(ax, 'x', 5);

% I have already forced symmetry with ylim above so we know the median
% value is going to be 0.
ax.YTick = [ax.YTick(1) median(ax.YTick) ax.YTick(end)];

% Vertical lines marking theoretical and actual arrival times.
pl.syn = plot(ax, zeros(1, 2), ylim, 'k', 'LineStyle', '--', 'LineWidth', 0.1);

% Sampling interval.
DELTA = xaxw1(2) - xaxw1(1);

if ~isnan(twosd) && twosd > DELTA
    % Plus/minus twosd from the theoretical arrival time.
    pl.dat_minus = plot(ax, repmat(tres-twosd, 1, 2), ylim, 'r', 'LineStyle', '--', 'LineWidth', 0.1);
    pl.dat_plus = plot(ax, repmat(tres+twosd, 1, 2), ylim, 'r', 'LineStyle', '--', 'LineWidth', 0.1);
    pl.dat = plot(ax, repmat(tres, 1, 2), ylim, 'r', 'LineStyle', '-', 'LineWidth', 0.1);

    % As a patch.
    % yy = ylim;
    % px = [tres-twosd tres+twosd tres-twosd tres+twosd];
    % py = [yy(1) yy(1) yy(2) yy(2)]
    % pl.dat = patch(ax, px, py, 'red', 'FaceColor', 'red', 'EdgeColor', 'red');

else
    pl.dat = plot(ax, repmat(tres, 1, 2), ylim, 'r', 'LineStyle', '-', 'LineWidth', 0.1);

end

% Circle the maximum counts if it is within the time window plotted
% (W2 and thus the time of the maximum counts may extend beyond W1).
if maxc_x <=  W1.xrsecs
    pl.maxc = plot(ax, maxc_x - syn, maxc_y, 'ko', 'MarkerSize', 5);

end
hold(ax, 'off')
box on
longticks(ax, 1.5);

%% Annotations (clockwise from top left).
% Magnitude.
magtype = lower(EQ(1).PreferredMagnitudeType);
magtype(1) = upper(magtype(1)); % Capitalize only first letter of magnitude type.
magstr = sprintf('%s %.1f', magtype, EQ(1).PreferredMagnitudeValue);
tx.ul = textpatch(ax, 'NorthWest',  magstr, FontSize(2), 'Times', 'LaTeX');


% Depth & Distance.
depthstr = sprintf('%.1f km', EQ(1).PreferredDepth);
diststr = sprintf('%.1f$^{\\circ}$', EQ(1).TaupTimes(1).distance);
tx.ur = textpatch(ax, 'NorthEast',  [depthstr ', ' diststr], FontSize(2), ...
                 'Times', 'LaTeX');


% SNR.
tx.ll = textpatch(ax, 'SouthWest', sprintf('SNR = %.1e', SNR), ...
                 FontSize(2), 'Times', 'LaTeX');

if isnan(twosd)
    tx.lr = textpatch(ax, 'SouthEast', ['2$\cdot{\mathrm{SD}}_\mathrm{err}$ = ' ...
                        'NaN'], FontSize(2), 'Times', 'LaTeX');

else
    if twosd >= DELTA
        tx.lr = textpatch(ax, 'SouthEast', sprintf(['2$\\cdot{\\mathrm{SD}}_\' ...
                            '\mathrm{err}$ = %.2f s'], twosd), FontSize(2), ...
                          'Times', 'LaTeX');
    else
        tx.lr = textpatch(ax, 'SouthEast', ['2$\cdot{\mathrm{SD}}_\mathrm{err}$ ' ...
                            '$<$ 1/$f_s$'], FontSize(2), 'Times', 'LaTeX');

    end
end

% Adjust YAxis TickLabels so that they have a field length at most of 2.
max_ylim = max(abs(ax.YLim));
ax.YAxis.Exponent = log10(max_ylim) - 1;

% Tack textboxes to corners.
pause(0.01)
tack2corner(ax, tx.ul, 'NorthWest')
tack2corner(ax, tx.ur, 'NorthEast')
tack2corner(ax, tx.ll, 'SouthWest')
tack2corner(ax, tx.lr, 'SouthEast')

topz([pl.noise pl.signal])

latimes
f = gcf;

%_________________________________________________________________________________%
% hardcode_twosd
%
% Hidden input to supply a HARDCODED 2*std. dev. value, e.g., to
% ensure it is identical to a textfile matched to these seismograms.
% This is necessary because the random nature of the M1 method can
% result in minor differences in uncertainties, and the hackish nature
% of textpatch.m does not always allow string editing with the LaTeX
% interpreter.
