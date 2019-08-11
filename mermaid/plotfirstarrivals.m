function [f, ha, lax, th, tx] = plotfirstarrivals(wlen, label)


defval('s', [])
defval('ci', true)
defval('wlen', 30)
defval('label', true)
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

% Generate subplot.
[ha, hav] = krijetem(subnum(4, 3));
shrink(hav, 0.78, 1.25)
moveh(hav(1:4), -0.06)
moveh(hav(9:12), 0.06)

axpos = linspace(-0.055, 0.07, 4);
movev(hav([1 5 9]), axpos(4))
movev(hav([2 6 10]), axpos(3))
movev(hav([3 7 11]), axpos(2))
movev(hav([4 8 12]), axpos(1))

if label
    [lax, th] = labelaxes(ha);
    moveh(lax, -0.02)
    movev(lax, 0.03)        

else
     lax = [];
     th = [];

end

for i = 1:length(ha)
    ax = ha(i);
    axes(ax)
    ridx = randi([1, length(s)]);
    [~, ~, tx(i)] = plotfirstarrival(s{ridx}, ax, FontSize);

end

f = gcf;