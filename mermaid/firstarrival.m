function f = firstarrival

defval('s', [])
defval('wlen', 30)
defval('colo', 1)
defval('cohi', 3);
defval('sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('revdir', fullfile(getenv('MERMAID'), 'events'))
defval('nplot', 2)

if isempty(s)
    s = revsac(1, sacdir, revdir);
    
end

f = figure;
fig2print(f, 'flandscape')

switch nplot
  case 1
    [~, ha] = krijetem(subnum(3, 2));

  case 2
    [~, ha] = krijetem(subnum(4, 3));
    shrink(ha, 0.8, 1)

  otherwise
    error('Specify either 1 or 2 for input: nplot');

end

% Verify every event input/randomly selected has an identified arrival
for i = 1:length(ha)
    ridx = randi([1, length(s)]);
    axes(ha(i))

    [x, h] = readsac(s{ridx});
    EQ = getevt(s{ridx}, revdir);

    % Ensure time at first sample (pt0) is the same in both the EQ
    % structure and the SAC file header.
    if ~isequal(EQ(1).TaupTimes(1).pt0, h.B)
        ridx
        keyboard
        error('EQ(1).TaupTimes(1).pt0, h.B')

    end

    xf = bandpass(x, 1/h.DELTA, colo, cohi);
    [xw, W] = timewindow(xf, wlen, EQ(1).TaupTimes(1).arsecs, 'middle', h.DELTA, h.B); % *1
    
    offset_xax = W.xax - EQ(1).TaupTimes(1).arsecs;
    offset_TT_arsamp = EQ(1).TaupTimes(1).arsamp - (W.xlsamp - 1); % *2
    

    cp = cpest(xw, 'fast', false, true);
    offset_CP_cpsamp = cp - (W.xlsamp - 1); % *2
    
    % The estimated arrival is 1 sample after the changepoint.
    offset_CP_arsamp = cp + 1; 

    plot(offset_xax, xw)
    title(sprintf('%i', ridx))
    symaxes(ha(i), 'y');

    vertline(offset_xax(offset_TT_arsamp), [], 'k', 'LineStyle', '--');
    vertline(offset_xax(offset_CP_arsamp), [], 'r', 'LineStyle', '-');

    xlim([-wlen/2 wlen/2])
    xticks([-15:5:15])
    box on
    
end

% *1 Use .arsecs (actual time at a sample) for plotting and .truearsecs for timing.
%
% *2 If offset_TT_arsamp = 10 and W.xlsamp = 1, we want the offset = 10. 
%    If we just subtracted W.xlsamp the offset would be 9.
