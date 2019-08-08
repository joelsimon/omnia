function f = plotfirstarrivals(wlen)

defval('s', [])
defval('ci', false)
defval('wlen', 30)
defval('lohi', [1 5])
defval('sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('nplot', 2)

if isempty(s)
    s = psac(1, sacdir, evtdir);
    
end


f = figure;
fig2print(f, 'flandscape')

FontSize = [10 8];

switch nplot
  case 1
    [~, ha] = krijetem(subnum(3, 2));

  case 2
    [~, ha] = krijetem(subnum(4, 3));
    shrink(ha, 0.78, 1.25)
    moveh(ha(1:4), -0.06)
    moveh(ha(9:12), 0.06)
    
    axpos = linspace(-0.055, 0.085, 4);
    movev(ha([1 5 9]), axpos(4))
    movev(ha([2 6 10]), axpos(3))
    movev(ha([3 7 11]), axpos(2))
    movev(ha([4 8 12]), axpos(1))

  otherwise
    error('Specify either 1 or 2 for input: nplot');

end


for i = 1:length(ha)
    ax = ha(i);
    axes(ax)
    ridx = randi([1, length(s)]);
    plotfirstarrival(s{ridx}, ax, FontSize);

end
keyboard