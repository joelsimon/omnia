% FIGURE 1
%
% Cite: Simon, J. D. et al., (2020), BSSA, doi: 10.1785/0120190173
%
% plot2normlystest.m with some formatting.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 09-Jan-2020, Version 2017b on GLNXA64

clear
close all

% Presets
trusigmas = [1 sqrt(2)];
axlim = [.5 1.5];
npts = 100;
lx = 1e3;
bp = 500;
ntests = 25;
nglog = false;

% Plot it.
f = plot2normlystest(trusigmas,axlim,npts,lx,bp,ntests);

% Set patches to 'on'.
set([f.f1.bh f.f2.bh f.f3.bh],'Visible','on')

set(f.ha,'FontSize',10)
latimes
sizelabel = 11;

% Label axes.
[lax,th] = labelaxes([f.ha(1:3) f.ha(5)],'ul',true, 'FontName', ...
                     'Helvetica','FontSize',14, 'Interpreter', ...
                     'tex','FontWeight','normal');
movev(lax,0.03)
moveh(lax,-0.01)

% Set up crosshair transformation matrix.
matrx = makehgtform('translate', [0 -150 0]);

% First plot.
ax = f.ha(1);
f.f1.bh.Vertices = [0.55 -650;
                    1.25 -650;
                    1.25 -850;
                    0.55 -850];

f.f1.th.Position = [.9 -755];
f.f1.th.FontSize = sizelabel;

ax.XLabel.FontSize = sizelabel;
ax.YLabel.FontSize = sizelabel;

ax.XTick = [.5:.25:1.5];
ax.XTickLabels{1} = [];
ax.XTickLabels{end} = [];

ax.YLim = [-1800 -600];
f.f1.xhairhg.Matrix = matrx;

% Same ticks for other two.
sameticks(f.ha(1), f.ha(2:3))

% Second plot
ax = f.ha(2);
ax.XLabel.FontSize = sizelabel;
ax.YLabel.FontSize = sizelabel;

f.f2.bh.Vertices = [0.55 -1550;
                    1.25 -1550;
                    1.25 -1750;
                    0.55 -1750];

f.f2.th.FontSize = f.f1.th.FontSize;
f.f2.th.Position = [0.9 -1655];
f.f2.xhairhg.Matrix = matrx;

% Third plot
ax = f.ha(3);
ax.XLabel.FontSize = sizelabel;
ax.YLabel.FontSize = sizelabel;
ax.YTickLabels = [];

f.f3.bh.Vertices = f.f2.bh.Vertices;
f.f3.th.FontSize = f.f2.th.FontSize;
f.f3.th.Position = f.f2.th.Position;

f.f3.xhairhg.Matrix = matrx;

% Fourth plot.
ax = f.ha(4);
tstr = sprintf('Shown are %i tests:', ntests);
kstr = sprintf('$k = [1, ... ,1000],~k_{\\circ} = %i$,', bp);
nstr = sprintf(['$n(k)\\sim\\mathcal{N}(\\mu_{1_\\circ}=0,\\sigma_{1_\\' ...
                'circ}^2=%.0f$),'],trusigmas(1)^2);
sstr = sprintf(['$s(k)\\sim\\mathcal{N}(\\mu_{2_\\circ}=0,\\sigma_{2_\\' ...
                'circ}^2=%.0f),$'],trusigmas(2)^2);
xstr = sprintf('$x(k) = n(k) + s(k).$');
f.f4.th.String = sprintf('%s\n%s\n%s\n%s\n%s', tstr, kstr, nstr, sstr, xstr);

f.f4.th.FontSize = 14;
f.f4.th.Position = [0 0.5];

% Fifth/sixth plot: time series.
ax = f.ha(5);
ylim(ax, [-6 6]);
yticks(ax, [-6:3:6]);

ax.XLabel.FontSize = sizelabel;
ax.YLabel.FontSize = sizelabel;

text(ax, 500, 7, '$k_{\circ}$', 'Interpreter', 'Latex', ...
     'FontSize', sizelabel)

% This is the mean of (a), the correct changepoint model.
fprintf('The mean of the summed log-likelihoods in (a) is %i\n', round(f.f1.meany))

% Save it.
savepdf(mfilename)
