% Figure 8
%
% Cite: Simon, J. D. et al., (2020), BSSA, doi: 10.1785/0120190173
%
% plotcpm1s.m (a local version) with some formatting.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 01-Apr-2019, Version 2017b

clear
close all

% This probably shouldn't be changed from true, but just so we know
% it's here; we are using the BIASED the sample variance, normalized
% by N, not N-1, because that's what falls out of the math.
bias = true;

% % %%%%%%%%%%%%%%%%%%% Comment this....
% %% (1) Either run anew...
% % I want to control exactly what x is plotted on zoom in, so I'm
% % loading a static x that has same parameters but looks pretty zoomed.
% load 'Static/x_01_0sqrt2.mat' % for p1, p2 parameters.
% iters = 1e6;
% abso = false;
% dtrnd = false;
% plt = false;

% if bias == true
%     bias_str = 'biased';
% else
%     bias_str = 'unbiased';
% end

% % 01-Nov-2018: I split the del_km and del_kw into TWO tests (as
% % opposed to [del_km, del_kw] = cpm1(...)) so that the different error
% % estimates are not taken on the same time series.  I am certain this
% % doesn't matter (especially over 1e6 iters) but just to be safe I'm
% % testing it here.  I find it doesn't matter though I saved the
% % current samphist_biased with this set up anyway.  Note that I do the
% % same thing in alphasummary_biased.mat, where the four tests (km,kw and
% % restricted/unrestricted) are all split into there own test with
% % their own time series. Again, statistics tell us it doesn't matter
% % but I'm running each test on it's own time series simply for hyper
% % vigilance.  Note that samphist_unbiased.mat has not been rerun with
% % this new split setup.

% del_km = cpm1(iters, lx, bp, dist1, p1, dist2, p2, abso, dtrnd, plt, [], bias);

% [~, del_kw] = cpm1(iters, lx, bp, dist1, p1, dist2, p2, abso, dtrnd, ...
%                    plt, [], bias);


% save(sprintf('samphist_%s', bias_str), 'del_km', 'del_kw', 'iters');
% % %%%%%%%%%%%%%%%%%%% Comment this...


% %%%%%%%%%%%%%%%%%%% -OR- Comment this....
% (2) .... Or, after running once and saving, load data.
if bias == true
    load 'Static/samphist_biased.mat';
else
    load 'Static/samphist_unbiased.mat';
end
% %%%%%%%%%%%%%%%%%%% -OR- Comment this....

% Plot it.
f = plotcpm1s_local(del_km, del_kw, bias);
ha = f.ha;

% Vertline.
%% Do not try to put this vertline below the blue and red theoretical
%% pdf curves.  It screws up the alignment of the histograms and is
%% more work than it is worth to fix it (I tried).
hold(ha, 'on')
plvl = plot(ha, [0 0], [0 0.1], 'k');
hold off

xticks([-50:25:50]);

% Inset qqplot.
qqax = axes;
qqax.Position = [.65 .67 .23 .23]
hold(qqax, 'on')
qref = plot(qqax, [-50 50], [-50 50], 'k', 'LineWidth', 0.25);
qqax.XLim = [-50 50];
qqax.YLim = [-50 50];

%% Note about qqplot(X, pd):
%%
%% "Hypothesized probability distribution, specified as a probability
%% distribution object. qqplot plots the quantiles of the input data x
%% versus the theoretical quartiles of the distribution specified by
%% pd."
%%
%% i.e., X is plotted on the Y-Axis; confusing
%%
%% Also, here I plot a 1:1 line and delete the red dashed line that
%% MATLAB auto-generates that passes through the first and third quartiles.

qm = qqplot(del_km, makedist('normal', 'mu', mean(del_km), 'sigma', ...
                             std(del_km, 1)));

qw = qqplot(del_kw, makedist('normal', 'mu', mean(del_kw), 'sigma', ...
                             std(del_kw, 1)));
hold(qqax, 'off')

qxl = xlabel(qqax, 'Normal quantiles');
qyl = ylabel(qqax, 'Sample quantiles');
qqax.Title = [];
set(qm, 'Marker', 'o', 'MarkerSize', 0.25, 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b')
delete(qm([2 3]))  % *See note at bottom

set(qw, 'Marker', 'o', 'MarkerSize', 0.25, 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r')
delete(qw([2 3]))

box(qqax, 'on')
qqax.TickDir = 'out';

numticks(qqax, 'x', 5);
numticks(qqax, 'y', 5);

axes(ha)
ha.TickDir = 'out';
box on
latimes
axesfs(f.f, 9, 13)
qqax.FontSize = 10;
f.lg.FontSize = 10;

% Reorder plot objects.
uistack(qqax, 'top')

% Save it.
if bias == true
    warning('bias is TRUE, normalized by 1/N')
    savepdf(mfilename)
else
    warning('bias is FALSE, normalized by 1/(N-1)')
    savepdf([mfilename '_unbiased'])
end

%___________________________________________________________________%

function f = plotcpm1s_local(del_km, del_kw, bias)
% LOCAL VERISON of plotcpm1s; here so I can change the original and
% not affect this paper figure.

figure;
f.f = gcf;
f.ha = gca;
fig2print(f.f,'landscape')

edgecol = [0.8 0.8 0.8];
facecol = [0.8 0.8 0.8];


hold on
f.h1 = histogram(del_km, 'BinMethod', 'Integer', 'Normalization', ...
                 'probability');
xlim([-50 50]);
ylim([0 0.1]);
f.h2 = histogram(del_kw, 'BinMethod', 'Integer', 'Normalization', ...
                 'probability');
uistack(f.h1, 'top')

meankm = mean(del_km);
stdkm = std(del_km, 1);
meankw = mean(del_kw);
stdkw = std(del_kw, 1);

% Best fitting normals.
xvals = linspace(-50, 50, 1e6);
pdkm = normpdf(xvals, meankm, stdkm);
pdkw = normpdf(xvals, meankw, stdkw);

% Want to put them in f.h1 axes, that's put on top.
ax = f.h1.Parent;
f.pdkm = plot(ax, xvals, pdkm, 'b', 'LineWidth', 1);
f.pdkw = plot(ax, xvals, pdkw, 'r', 'LineWidth', 1);

hold off

f.h1.FaceColor = 'k';
f.h2.FaceColor = facecol;

f.xl = xlabel('Changepoint estimation error (samples)');
f.yl = ylabel('Normalized frequency over $10^6$ realizations');

lg_entries = [f.h1 f.h2];
f.kmstr = '$k_{\mathrm{m}}-k_{\circ}\hspace{-0.25em}:\mathrm{M}=4,\mathrm{SD}=25$';
f.kwstr = '$k_{\mathrm{w}}-k_{\circ}\hspace{-0.25em}:\mathrm{M}=0,\mathrm{SD}=21$';

lg_str = {f.kmstr, f.kwstr};
f.lg = legend(lg_entries, lg_str, 'Interpreter', 'Latex', 'Location', ...
              'NW', 'AutoUpdate', 'off');

% Bring km global hist to top of stack.
f.h1.FaceAlpha = 0;
f.h1.EdgeColor = 'k';
f.h2.FaceAlpha = 1;
f.h2.EdgeColor = edgecol;
end

%______________________________________________________%

% *Concerning the output handle of qqplot, from the online
% documentation --
%
% "Graphics handles for line objects, returned as a vector of Line
% graphics handles. Graphics handles are unique identifiers that you
% can use to query and modify the properties of a specific line on the
% plot. For each column of x, qqplot returns three handles:
%
% The line representing the data points. qqplot represents each data
% point in x using plus sign ('+') markers.
%
% The line joining the first and third quartiles of each column of x,
% represented as a solid line.
%
% The extrapolation of the quartile line, extended to the minimum and
% maximum values of x, represented as a dashed line."
