function f = plotfirstarrival(wlen)

defval('s', [])
defval('wlen', 30)
defval('colo', 1)
defval('cohi', 5);
defval('sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('revdir', fullfile(getenv('MERMAID'), 'events'))
defval('nplot', 2)

if isempty(s)
    s = revsac(1, sacdir, revdir);
    
end


f = figure;
fig2print(f, 'flandscape')

FontSize = 8;

switch nplot
  case 1
    [~, ha] = krijetem(subnum(3, 2));

  case 2
    [~, ha] = krijetem(subnum(4, 3));
    shrink(ha, 0.8, 1)
    moveh(ha(1:4), -0.05)
    moveh(ha(9:12), 0.05)
    
    movev(ha([1 5 9]), 0.06)
    movev(ha([2 6 10]), 0.02)    
    movev(ha([3 7 11]), -0.02)    
    movev(ha([4 8 12]), -0.06)    

  otherwise
    error('Specify either 1 or 2 for input: nplot');

end

for i = 1:length(ha)
    ax = ha(i);
    axes(ax)

    ridx = randi([1, length(s)]);
    [x, h] = readsac(s{ridx});
    EQ = getevt(s{ridx}, revdir);

    % Ensure time at first sample (pt0) is the same in both the EQ
    % structure and the SAC file header.
    if ~isequal(EQ(1).TaupTimes(1).pt0, h.B)
        ridx
        keyboard
        error('EQ(1).TaupTimes(1).pt0 ~= h.B')

    end

    % Bandpass filter the time series and select a windowed segment.
    xf = bandpass(x, 1/h.DELTA, colo, cohi);
    [xw, W] = timewindow(xf, wlen, EQ(1).TaupTimes(1).arsecs, 'middle', h.DELTA, h.B); % *1

    % Changepoint estimate.
    cp = cpest(xw, 'fast', false, true);  % w.r.t xw

    % The travel time residual is defined as the arrival-time estimate 
    % (cp + 1) of the windowed segment, mapped to the appropriate index in
    % the complete segment, minus the theoretical arrival time defined
    % in the complete time segment.
    tres =  W.xax(cp + 1) - EQ(1).TaupTimes(1).truearsecs;
    
    % Maximum amplitude (counts).
    mmx = minmax(xw');
    [~, mmx_idx] = max(abs(mmx));
    max_counts = mmx(1);

    % The offset values: xaxis
    offset_xax = W.xax - EQ(1).TaupTimes(1).arsecs;
    plot(offset_xax, xw, 'LineWidth', 1)

   % Joel note: don't put dollar signs ($) around numbers because I
   % use %e for the exponential notation and it makes the 'e' look
   % weird.

   % IDEA: have ridx be equal to the line number of firstarrival.txt;
   % i.e., you may look up the SAC file with the line number.
    title(sprintf('%i: tres. = %.2f s', ridx, tres), 'FontSize', ...
          ax.FontSize, 'FontWeight', 'Normal')
    sacname = strippath(strrep(s{ridx}, '_', '\_'));
    ylabel(sprintf('counts [%.1e]', max_counts), 'FontSize', ax.FontSize)
    xlabel(sprintf('time relative to %s \\textit{%s}-phase (s)', ...
                   EQ(1).TaupTimes(1).model, EQ(1).TaupTimes(1).phaseName), ...
           'FontSize', ax.FontSize)

    % Adjust the axes.
    xlim([-wlen/2 wlen/2])
    rangey = range(xw) * 0.95;  % Expand axes by some multiple of the range of the windowed segment.
    ylim([-rangey rangey])
    if wlen == 30
        numticks(ax, 'x', 7);

    else
        numticks(ax, 'x', 6);

    end
    hold(ax, 'on')

    % Vertical lines marking theoretical and actual arrival times and max counts.
    offset_TT_arsamp = EQ(1).TaupTimes(1).arsamp - (W.xlsamp - 1); % *2
    plot(ax, repmat(offset_xax(offset_TT_arsamp), 1, 2), ylim, 'k', 'LineStyle', '--');

    offset_CP_arsamp = cp + 1;  % cp is already in reference to the offset, windowed segment
    plot(ax, repmat(offset_xax(offset_CP_arsamp), 1, 2), ylim, 'r', 'LineStyle', '-');
    
    % Maximum amplitude (counts).
    plot(ax, offset_xax(find(xw == max_counts)), max_counts, 'ko', 'MarkerSize', 5)
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
    SNR = wtsnr({xw}, cp, 1);
    txll = textpatch(ax, 'SouthWest', sprintf('SNR = %.1f', SNR), FontSize);
    tack2corner(ax, txll, 'SouthWest')    

    % Uncertainty estimate.
    ci = true; 
    %ci = false;  
    if ci 
        M1 = cpci(xw, 'kw', 1000, [], 'fast', false, true);

    else
        M1.twostd = -999;
    
    end
    M1_secs = M1.twostd * h.DELTA; % *3 
    txlr = textpatch(ax, 'SouthEast', sprintf('2$\\cdot$SD = %.2f s', M1_secs), FontSize);
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