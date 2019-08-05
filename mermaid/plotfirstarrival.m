function f = plotfirstarrival(wlen)

defval('s', [])
defval('ci', false)
defval('wlen', 30)
defval('lohi', [1 5])
defval('sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('nplot', 2)

if isempty(s)
    s = revsac(1, sacdir, evtdir);
    
end


f = figure;
fig2print(f, 'flandscape')

FontSize = 8;

switch nplot
  case 1
    [~, ha] = krijetem(subnum(3, 2));

  case 2
    [~, ha] = krijetem(subnum(4, 3));
    shrink(ha, 0.8, 1.25)
    moveh(ha(1:4), -0.05)
    moveh(ha(9:12), 0.05)
    
    axpos = linspace(-0.055, 0.085, 4);
    movev(ha([1 5 9]), axpos(4))
    movev(ha([2 6 10]), axpos(3))
    movev(ha([3 7 11]), axpos(2))
    movev(ha([4 8 12]), axpos(1))

  otherwise
    error('Specify either 1 or 2 for input: nplot');

end

latimes

for i = 1:length(ha)
    ax = ha(i);
    axes(ax)

    ridx = randi([1, length(s)]);

    [tres, dat, syn, ph, diffc, twosd, xw1, xaxw1, maxc_x, maxc_y, SNR, ...
     EQ, W1, xw2, W2] = firstarrival(s{ridx}, ci, wlen, lohi, sacdir, evtdir);
    

    plot(ax, xaxw1, xw1, 'LineWidth', 1)
    
    % Joel note: don't put dollar signs ($) around numbers because I
    % use %e for the exponential notation and it makes the 'e' look
    % weird.
    title(sprintf('tres. = %.2f s, delay = %.2f s', tres, diffc), ...
          'FontSize', ax.FontSize, 'FontWeight', 'Normal')
    sacname = strippath(strrep(s{ridx}, '_', '\_'));
    ylabel(sprintf('counts [%.1e]', maxc_y), 'FontSize', ax.FontSize)
    xlabel(sprintf('time relative to \\textit{%s}-phase (s)\n[%s]', ...
                   ph, sacname), 'FontSize', ax.FontSize)

    % xlabel(sprintf('time relative to %s \\textit{%s}-phase (s)\n%s', ...
    %                EQ(1).TaupTimes(1).model, ph, sacname), ...
    %        'FontSize', ax.FontSize)

    % Adjust the axes.
    xlim([-wlen/2 wlen/2])
    rangey = range(xw1) * 0.95;  % Expand axes by some multiple of the range of the windowed segment.
    ylim([-rangey rangey])
    if wlen == 30
        numticks(ax, 'x', 7);

    else
        numticks(ax, 'x', 6);

    end

    % Vertical lines marking theoretical and actual arrival times.
    hold(ax, 'on')
    plot(ax, repmat(0, 1, 2), ylim, 'k', 'LineStyle', '--');  
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
    txul = textpatch(ax, 'NorthWest',  magstr, FontSize);
    tack2corner(ax, txul, 'NorthWest')    
    
    % Depth & Distance.
    depthstr = sprintf('%.1f km', EQ(1).PreferredDepth);
    diststr = sprintf('%.1f$^{\\circ}$', EQ(1).TaupTimes(1).distance);
    txur = textpatch(ax, 'NorthEast',  [depthstr ', ' diststr], FontSize);
    tack2corner(ax, txur, 'NorthEast')    
    
    % SNR.
    txll = textpatch(ax, 'SouthWest', sprintf('SNR = %.1f', SNR), FontSize);
    tack2corner(ax, txll, 'SouthWest')    

    % Uncertainty estimate.
    txlr = textpatch(ax, 'SouthEast', sprintf('2$\\cdot$SD = %.2f s', twosd), FontSize);
    tack2corner(ax, txlr, 'SouthEast')    
    latimes

end

% *1 Use .arsecs (actual time at a sample) for plotting and .truearsecs for timing.
%
% *2 If offset_TT_arsamp = 10 and W.xlsamp = 1, we want the offset = 10. 
%    If we just subtracted W.xlsamp the offset would be 9.
%
% *3 See changepoint.m to understand why I do not need to remove 1
%    sample from M1 before multiplying it by the sampling interval.