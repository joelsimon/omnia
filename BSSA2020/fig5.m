% Figure 5
%
% Cite: Simon, J. D. et al., (2020), BSSA, doi: 10.1785/0120190173
%
% plotmodelaic.m (a local version) with some formatting.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 22-May-2018, Version 2017b

clear
close all

% I want to control exactly what x is plotted on zoom in, so I'm
% loading a static x that has same parameters but looks pretty zoomed.
load 'Static/x_01_0sqrt2.mat'

% This probably shouldn't be changed from true, but just so we know
% it's here; we are using the BIASED the sample variance, normalized
% by N, not N-1, because that's what falls out of the math.
bias = true;

% Run cpest.m on the x time series I just loaded.
[kw, km, aicx] = cpest(x, 'fast', false, bias);

% Run basic plotting function.
f = plotmodelaic_local(x, bp, aicx, km, kw);

% And the rest is just all cosmetics.

% Axes 1.
ax = f.ha(1);
ylim(ax, [-6 6]);
yticks(ax, [-6:3:6]);
k0 = text(ax, bp, 7, '$k_{\circ}$', 'Interpreter', 'latex');

% Axes 2.
ax = f.ha(2);
ylim(ax, [370 450])
yticks(ax, [370:20:450]);

% Shift.
moveh(f.ha(1).YLabel, -25)
movev(f.ha(2), 0.05);

% Latex for everything
latimes

% Label the axes.
[lax, th] = labelaxes(f.ha,'ul', true, 'FontName', 'Helvetica', ...
                      'InterPreter', 'tex','FontWeight','normal');

movev(th, 15);
moveh(th, -60);

% Make all latex, set universal fontsize.
axesfs(f.f, 9, 13);
longticks(f.ha, 3);
f.yl2.Position(1) = f.yl1.Position(1);

% Save it.
if bias == true
    warning('bias is TRUE, normalized by 1/N')
    savepdf(mfilename)
else
    warning('bias is FALSE, normalized by 1/(N-1)')
    savepdf([mfilename '_unbiased'])
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f = plotmodelaic_local(x, bp, aicx, km, kw);
%
% Subplots a model (x) and its AIC function (aicx). Highlights both
% km, kw picks in relation to the true changepoint, bp.  Does no
% formatting. Requires exterior work to make pretty.
%
% Inputs:
% x              A model time series with a 'true' (known) changepoint
% bp             The model's true changepoint
% aicx,...,kw    Outputs of cpest.m
%
% Output:
% f              Struct with figure/axes handles and other bits
%
% See also: cpest.m
%
% Last modified in Ver. 2017a by jdsimon@princeton.edu, 27-Feb-2018.

% Create figure.
[~,f.ha] = krijetem(subnum(2,1));
f.f = gcf;
fig2print(f.f, 'landscape');

% Subplot 1: the model.
ax = f.ha(1);
f.plx = plot(ax, x, 'k');

% Limits.
axis(ax, 'tight')
ax1 = openup(ax, 6 ,10);
newylim = max(abs(ax1(3:4)));
ylim(ax, [-newylim newylim]);

% Vertline, labels, ticks.
f.vl1 = fx(vertline(bp, ax, 'k'), 1);
ax.TickDir = 'out';
ax.XTick = [1 ax.XTick];

%______________________________________________________________%
% Subplot 2: the AIC function
ax = f.ha(2);
f.plaicx = plot(ax, aicx, 'k');
axis(ax, 'tight');

% Vertlines.
f.vltru = fx(vertline(bp, ax, 'k'), 1);
f.vlmin = fx(vertline(km, ax, 'b'), 1);
f.vlkw = fx(vertline(kw, ax, 'r'), 1);

% Legend
lg_entries = [f.vltru f.vlmin f.vlkw];
lg_str = {'$k_{\circ}$','$k_\mathrm{m}$','$k_\mathrm{w}$'};
f.lg = legend(ax, lg_entries, lg_str, 'Location', 'SW', 'Interpreter', ...
              'Latex', 'Box', 'off');


% Labels, limits, cosmetics.
f.xl2 = xlabel(ax, 'Sample index $k$', 'Interpreter', 'Latex');
f.yl1 = ylabel('$x$', 'Interpreter', 'Latex');
f.yl2 = ylabel(ax, '$\mathcal{A}$', 'Interpreter', 'Latex');
finx = aicx(isfinite(aicx));
rangex = range(finx);
minx = min(finx);
maxx = max(finx);
ylim(ax,[minx-(0.1*rangex) maxx+(0.1*rangex)]);

% Same x-axis for both; delete tick labels on top subplot, flip y ticks.
sameticks(f.ha(1), f.ha(2), 'x')
ax.TickDir = 'out';
f.ha(1).XTickLabel = [];
end
