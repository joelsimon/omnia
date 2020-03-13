% FIGURE 2
%
% Cite: Simon, J. D. et al., (2020), BSSA, doi: 10.1785/0120190173
%
% plot2normlysmix.m with some formatting.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 09-Jan-2020, Version 2017b on GLNXA64

clear
close all

% Presets
perc = 25;
trusigmas = [1 sqrt(2)];
axlim = [.5 1.5];
npts = 100;
lx = 1e3;
bp = 500;
ntests = 25;
nglog = false;
meth = 1;

% Plot it.
f = plot2normlysmix(perc, trusigmas, lx, bp, axlim, npts, ntests, meth);

% Set patches to 'on'.
set([f.f1.bh f.f2.bh f.f3.bh f.f4.bh], 'Visible', 'on')

set(f.ha, 'FontSize', 10)
latimes;
sizelabel = 11;

% % Label the axes.
[lax,th] = labelaxes(f.ha, 'ul', true,'FontName','Helvetica','FontSize',14, ...
                     'InterPreter','tex','FontWeight','Normal');

movev(lax, 0.03);
moveh(lax(1:4), -0.01);
moveh(lax(5:6), -0.04);

% Set up crosshair transformation matrix.
matrx = makehgtform('translate', [0 -150 0]);

% First plot.
ax = f.ha(1);
ax.XLim = axlim;
ax.XTick = [.5:.25:1.5];
ax.XTickLabels{1} = [];
ax.XTickLabels{end} = [];

ax.YLim = [-2000 -1000];
ax.YTick = [-2000:200:-1000];

ax.XLabel.FontSize = sizelabel;
ax.YLabel.FontSize = sizelabel;

f.f1.bh.Vertices = [0.55 -1050;
                    1.25 -1050;
                    1.25 -1250;
                    0.55 -1250];

f.f1.th.FontSize = sizelabel;
f.f1.th.Position = [0.9 -1150];

f.f1.xhairhg.Matrix = matrx;

f.f1.thk = text(ax, .91, -1950, '$k > k_{\circ}$', 'Interpreter', ...
                'latex', 'FontSize', sizelabel);
% Copy ticks.
sameticks(f.ha(1), f.ha(2:4))

% Second plot.
ax = f.ha(2);
ax.XLabel.FontSize = sizelabel;
ax.YLabel.FontSize = sizelabel;

f.f2.bh.Vertices = [0.55 -1750;
                    1.25 -1750;
                    1.25 -1950;
                    0.55 -1950];

f.f2.th.FontSize = f.f1.th.FontSize;
f.f2.th.Position = [0.9 -1850];
f.f2.xhairhg.Matrix = matrx;

f.f2.thk = text(ax, .91, -1050, '$k > k_{\circ}$', 'Interpreter', ...
                'latex', 'FontSize', sizelabel);


% Third plot.
ax = f.ha(3);
ax.XLabel.FontSize = sizelabel;
ax.YLabel.FontSize = sizelabel;
ax.YTickLabels = [];

f.f3.bh.Vertices = f.f2.bh.Vertices;
f.f3.th.FontSize = f.f2.th.FontSize;
f.f3.th.Position = f.f2.th.Position;

f.f3.xhairhg.Matrix = matrx;

f.f3.thk = text(ax, 0, 0, '$k < k_{\circ}$', 'Interpreter', 'latex', ...
                'FontSize', sizelabel);
f.f3.thk.Position = f.f2.thk.Position;

% Fourth plot.
ax = f.ha(4);
ax.XLabel.FontSize = sizelabel;
ax.YLabel.FontSize = sizelabel;

f.f4.bh.Vertices = f.f1.bh.Vertices;
f.f4.th.FontSize = f.f1.th.FontSize;
f.f4.th.Position = f.f1.th.Position;

f.f4.xhairhg.Matrix = matrx;

f.f4.thk = text(ax, 0, 0, '$k < k_{\circ}$', 'Interpreter', ...
                'latex', 'FontSize', sizelabel);
f.f4.thk.Position = f.f1.thk.Position;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Axes are linked so this updates 5 and 6.
ax = f.ha(5);
text(ax, 500, 7.25, '$k_{\circ}$', 'Interpreter', 'Latex', ...
     'FontSize', sizelabel)
ylim(ax, [-6 6]);
yticks(ax, [-6:3:6]);

f.f5.thk = text(ax, 80, 4, '$k > k_{\circ}$', 'Interpreter', ...
                'latex', 'FontSize', sizelabel);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Sixth plot.
% Can't do both because same ticks deletes x axis...
ax = f.ha(6);
ax.XLabel.FontSize = f.ha(1).XLabel.FontSize;

sameticks(f.ha(5), f.ha(6), 'y');


f.f6.thk = text(ax, 80, 4, '$k < k_{\circ}$', 'Interpreter', ...
                'latex', 'FontSize', sizelabel);

set(f.ha, 'Title', [])

% Save it
fprintf('The mean of the summed log-likelihoods in (a) is %i\n', round(f.f1.meany))
fprintf('The mean of the summed log-likelihoods in (d) is %i\n', round(f.f4.meany))

savepdf(mfilename)
