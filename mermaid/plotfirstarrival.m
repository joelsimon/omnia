function [f, ax, tx] = plotfirstarrival(s, ax, FontSize, EQ, ci, wlen, lohi, sacdir, evtdir, bathy)
% [f, ax, tx] = PLOTFIRSTARRIVAL(s, ax, FontSize, EQ, ci, wlen, lohi, sacdir, evtdir, bathy)
%
% Plots output of firstarrival.m centered on theoretical
% first-phase-arrival time.
%
% s        SAC filename (def: '20180819T042909.08_5B7A4C26.MER.DET.WLT5.sac')
% ax       Axis handle, or [] to generate new (def: [])
% FontSize 1 x 2 array of large and small fonts (def: [14 12])
% EQ       EQ structure against which to compute travel time residuals,
%              or [] if event is reviewed and to be retrieved with
%              getevt.m (def: [])
% ci       true to estimate arrival time uncertainty via
%              1000 realizations of M1 method (def: false)*
% wlen     Window length [s] (def: 30)
% lohi     1 x 2 array of corner frequencies, or NaN to skip
%              bandpass and use raw data (def: [1 5]])
% sacdir   Directory containing (possibly subdirectories)
%              of .sac files (def: $MERMAID/processed)
% evtdir   Directory containing (possibly subdirectories)
%              of .evt files (def: $MERMAID/events)
% bathy    logical true apply bathymetric travel time correction,
%              computed with bathtime.m (def: false)
%
% Output:
% f        Figure handle
% ax       Axis handle
% tx       textpatch.m handles where, e.g., tx.ul is 'upper left'
%
% *See paper??
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 26-Oct-2019, Version 2017b on GLNXA64

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

% Generate new axis if one not supplied.
if isempty(ax)
    f = figure;
    ax = gca;

else
    f = ax.Parent;

end

% Compute first-arrival statistics.
[tres, dat, syn, tadj, ph, delay, twosd, xw1, xaxw1, maxc_x, maxc_y, ...
 SNR, EQ, W1, xw2, W2, incomplete] = firstarrival(s, ci, wlen, lohi, sacdir, evtdir, EQ, bathy);

% Plot time series.
plot(ax, xaxw1, xw1, 'LineWidth', 1, 'Color', 'Blue')
ax.FontSize = FontSize(2);

% Adjust title if travel-time residual uses corrected theoretical
% (tstar) phase arrival time.
if bathy
    tstr = '$t^{\star}_\mathrm{res}$';

else
    tstr = '$t_\mathrm{res}$';

end

% Label the axis.
title(sprintf('%s = %.2f s [max. %.2f s later]', tstr, tres, delay), ...
      'FontWeight', 'Normal', 'FontSize', FontSize(1))
sacname = strippath(strrep(s, '_', '\_'));
ylabel(sprintf('counts\n[max. %.1e]', maxc_y), 'FontSize', FontSize(1))
xlabel(sprintf('time relative to \\textit{%s}-phase (s)\n[%s]', ph, ...
               sacname), 'FontSize', FontSize(1))

% Adjust the axis.
xlim([-wlen/2 wlen/2])
rangey = range(xw1) * 1.1;  % Expand by some multiple of the range of the windowed segment.
ylim([-rangey rangey])

% Force 7 ticks on x-axis.
numticks(ax, 'x', 7);

% I have already forced symmetry with ylim above so we know the median
% value is going to be 0.
ax.YTick = [ax.YTick(1) median(ax.YTick) ax.YTick(end)];

% Vertical lines marking theoretical and actual arrival times.
hold(ax, 'on')
plot(ax, zeros(1, 2), ylim, 'k', 'LineStyle', '--');
plot(ax, repmat(tres, 1, 2), ylim, 'r', 'LineStyle', '-');

% Circle the maximum counts if it is within the time window plotted
% (W2 and thus the time of the maximum counts may extend beyond W1).
if maxc_x <=  W1.xrsecs
    plot(ax, maxc_x - syn, maxc_y, 'ko', 'MarkerSize', 5)

end
hold(ax, 'off')
box on
longticks(ax, 1.5);

%% Annotations (clockwise from top left).
% Magnitude.
magtype = lower(EQ(1).PreferredMagnitudeType);
magtype(1) = upper(magtype(1)); % Capitalize only first letter of magnitude type.
magstr = sprintf('M%.1f %s', EQ(1).PreferredMagnitudeValue, magtype);
tx.ul = textpatch(ax, 'NorthWest',  magstr, FontSize(2), 'Times', 'LaTeX');


% Depth & Distance.
depthstr = sprintf('%.1f km', EQ(1).PreferredDepth);
diststr = sprintf('%.1f$^{\\circ}$', EQ(1).TaupTimes(1).distance);
tx.ur = textpatch(ax, 'NorthEast',  [depthstr ', ' diststr], FontSize(2), ...
                 'Times', 'LaTeX');


% SNR.
tx.ll = textpatch(ax, 'SouthWest', sprintf('SNR = %.1e', SNR), ...
                 FontSize(2), 'Times', 'LaTeX');

% Uncertainty estimate.
tx.lr = textpatch(ax, 'SouthEast', sprintf('2$\\cdot$SD = %.2f s', ...
                                          twosd), FontSize(2), ...
                 'Times', 'LaTeX');

pause(0.01)
tack2corner(ax, tx.ul, 'NorthWest')
tack2corner(ax, tx.ur, 'NorthEast')
tack2corner(ax, tx.ll, 'SouthWest')
tack2corner(ax, tx.lr, 'SouthEast')

latimes
f = gcf;
