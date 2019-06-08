function f = plotmodelaic(x, cp, aicx, km, kw);
% f = PLOTMODELAIC(x, cp, aicx, km,kw)
%
% Subplots a model 'x' and its AIC function 'aicx'. Highlights both
% 'km', 'kw' picks in relation to the true changepoint, 'cp'.
% Performs no formatting and thus requires exterior work to make
% pretty.
%
% Inputs:        
% x              A model time series with a 'true' (known) changepoint
% cp             The model's true changepoint
% aicx,...,kw    Outputs of cpest.m
%
% Output: 
% f              Struct with figure/axes handles and other bits
%
% Ex:
%    x = normcpgen(1000, 500, 2);
%    [kw, km, aicx] = cpest(x);
%    PLOTMODELAIC(x, 500, aicx, km, kw)
%
% See also: cpest.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 27-Feb-2018, Version 2017b

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
f.vl1 = fx(vertline(cp, ax, 'k'), 1);
ax.TickDir = 'out';
ax.XTick = [1 ax.XTick];

%______________________________________________________________%
% Subplot 2: the AIC function
ax = f.ha(2);
f.plaicx = plot(ax, aicx, 'k');
axis(ax, 'tight');

% Vertlines.
f.vltru = fx(vertline(cp, ax, 'k'), 1);
f.vlmin = fx(vertline(km, ax, 'b'), 1);
f.vlkw = fx(vertline(kw, ax, 'r'), 1);

% Legend
lg_entries = [f.vltru f.vlmin f.vlkw];
lg_str = {'$k_{\circ}$','$k_m$','$k_w$'};
f.lg = legend(ax, lg_entries, lg_str, 'Location', 'SW', 'Interpreter', ...
              'Latex', 'Box', 'off');


% Labels, limits, cosmetics.
f.xl2 = xlabel(ax, 'sample index $k$', 'Interpreter', 'Latex');
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
