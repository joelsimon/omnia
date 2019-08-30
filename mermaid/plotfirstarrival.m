function [f, ax, tx] = plotfirstarrival(s, ax, FontSize, EQ)
% NEEDS HEADER

defval('s', '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac')
defval('ax', [])
defval('FontSize', [14 12])
defval('EQ', [])
defval('ci', true)
defval('wlen', 30)
defval('lohi', [1 5])
defval('sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))

if isempty(ax)
    f = figure;
    ax = gca;

end

[tres, dat, syn, ph, delay, twosd, xw1, xaxw1, maxc_x, maxc_y, SNR, ...
 EQ, W1, xw2, W2] = firstarrival(s, ci, wlen, lohi, sacdir, evtdir, EQ);

plot(ax, xaxw1, xw1, 'LineWidth', 1.5, 'Color', 'Blue')
ax.FontSize = FontSize(2);


% Joel note: don't put dollar signs ($) around numbers because I
% use %e for the exponential notation and it makes the 'e' look
% weird.

title(sprintf('$\\mathrm{t}_\\mathrm{res}$ = %.2f s, delay = %.2f s', ...
              tres, delay), 'FontWeight', 'Normal', 'FontSize', FontSize(1))
sacname = strippath(strrep(s, '_', '\_'));

ylabel(sprintf('counts [%.1e]', maxc_y), 'FontSize', FontSize(1))
xlabel(sprintf('time relative to \\textit{%s}-phase (s)\n[%s]', ph, ...
               sacname), 'FontSize', FontSize(1))

% xlabel(sprintf('time relative to %s \\textit{%s}-phase (s)\n[%s]', ...
%                EQ(1).TaupTimes(1).model, ph, sacname), 'FontSize', FontSize(1))

% Adjust the axes.
xlim([-wlen/2 wlen/2])
rangey = range(xw1) * 1.1;  % Expand axes by some multiple of the range of the windowed segment.
ylim([-rangey rangey])

% Force 7 ticks on x-axis.
numticks(ax, 'x', 7);

% Force 3 ticks on y axis.
if length(ax.YTick) > 3
    % I have already forced symmetry with ylim above so we know the median
    % value is going to be 0.
    ax.YTick = [ax.YTick(1) median(ax.YTick) ax.YTick(end)];

end

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
tx.ur = textpatch(ax, 'NorthEast',  [depthstr ', ' diststr], FontSize(1), ...
                 'Times', 'LaTeX');


% SNR.
tx.ll = textpatch(ax, 'SouthWest', sprintf('SNR = %.1f', SNR), ...
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
