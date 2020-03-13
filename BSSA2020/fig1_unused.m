% Original FIGURE 1
%
% Cite: Simon, J. D. et al., (2020), BSSA, doi: 10.1785/0120190173
%
% S simple representation of a seismogram as a "noise" segment which
% precedes a "signal" segment.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 16-Jan-2018, Version 2017b

clear 
close all

% Figure window.
figure
[~,ha]=krijetem(subnum(3,1));
f = ha(1).Parent;
fig2print(f, 'landscape');

% Time series length and changepoint.
lx = 1000;
bp = 500;

% Color and fontsize defaults.
ncol = [.6 .6 .6];
xax = [1:lx];

% Noise and signal components
noise = [.125*randn(1,bp) zeros(1,lx-bp)];
signal = [zeros(1,bp) .25*randn(1,lx-bp)];

% Shift axes.
movev(ha(2),.03)
movev(ha(3),.06)

% First: Noise.
ax = ha(1);
p1 = plot(ax,xax,noise,'Color',ncol);
yl1 = ylabel(ax,'$n$');
k0 = text(ha(1),bp,ha(1).YLim(2),'$k_{\circ}$');

% Second: signal.
ax = ha(2);
p2 = plot(ax,xax,signal,'Color','k');
yl2 = ylabel(ax,'$s$');

% Third: combination.
ax = ha(3);
hold(ax,'on');
p3n = plot(ax,xax(1:bp),noise(1:bp),'Color',ncol);
p3s = plot(ax,xax(bp+1:lx),signal(bp+1:lx),'Color','k');
hold(ax,'off')
xl3 = ylabel(ax,'$x$');
yl3 = xlabel(ax,'Sample index $k$');

% Vertlines.
vl = vertline(bp,ha,'k');

% Ensure proper x and y axes, ensure axis box, swap tick direction.
set(ha, 'TickDir', 'out')
set(ha, 'Box', 'on')
set(ha, 'YLim', [-1 1])
set(ha, 'YTick', [-1:.5:1])
set(ha, 'XTick', [1 100:100:1000])
set(ha, 'XLim', [1 xax(end)])

% Delete the first and second axes tick marks.
ha(1).XTickLabel = [];
ha(2).XTickLabel = [];

latimes(f);

% Label the axes.
[lax,th] = labelaxes(ha,'ul', true, 'FontName', 'Helvetica', ...
                         'InterPreter', 'tex','FontWeight','normal');
movev(lax, 0.02)
moveh(lax, -0.09)


% Final cosmetics.
k0.Position(2) = 1.3;
uistack(ha(2), 'top')
uistack(ha(1), 'top')
longticks(ha,3)
axesfs(f, 9, 13)

% Use times font for EVERYTHING, Latex interpreter for text.
savepdf(mfilename)
