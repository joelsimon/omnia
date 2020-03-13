% Figure 12
%
% Cite: Simon, J. D. et al., (2020), BSSA, doi: 10.1785/0120190173
%
% domaintest.m (a local version) with some formatting.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 06-Mar-2019, Version 2017b


% DOMAINTESTCURVES generates a 5x2 subplot of the output of
% domaintest.m with the defaults listed below
%
% Defaults used in domaintest.m
% defval('lx', 4000)
% defval('cp', 2000)
% defval('varsnr', [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024])
% defval('iters', 1000)
% defval('n', 5)
% defval('inputs', cpinputs)
%
% Where 'inputs' is defaulted with:
%   For wtrmedge.m
%        tipe: 'CDF'
%         nvm: [2 4]
%         pph: 4
%       intel: 0
%      rmedge: 1

%   For wtsnr.m
%        meth: 1

%   For cpest.m
%        algo: 'fast'
%       dtrnd: 0
%        bias: 1
%      cptype: 'kw'
%      snrcut: 1
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 06-Mar-2019, Version 2017b

clear
close all

% Load data generated with domaintest.m
load('Static/domaintest.mat')

f = figure;
fig2print(f, 'flandscape')

ha = krijetem(subnum(2, 5));
col.tsf =  [0 1 1];
col.tsm = [1 0 0];
col.tsl = [0.5 1 0];
col.t = [0.5 0 1];

xvals = linspace(-50, 50, 1e6);
px = [1 1 4 4];
py = [175 125 125 175];

% Loop backwards over SNR, from high to low.
num = 0;
for i = 10:-1:1
    num = num + 1;
    ax = ha(num);
    axis(ax, 'square')
    grid(ax, 'on')
    hold(ax, 'on')

    % Don't  adjust this  plotting order;  I was  having trouble  using topz  to
    % manually adjust  after the  fact. Have  to plot things  in order  you want
    % them.
    [mtsf{i}, stsf{i}, pltsf(i)] = plotstats(ax, tsf_err, i, col.tsf, 'o', col.tsf);
    [mtsl{i}, stsl{i}, pltsl(i)] = plotstats(ax, tsl_err, i, col.tsl, 'o', col.tsl');
    [mtsm{i}, stsm{i}, pltsm(i)] = plotstats(ax, tsm_err, i, col.tsm, 'o', col.tsm);
    [mt{i}, st{i}, plt(i)] = plotstats(ax, t_err, i, col.t, 'd', col.t);

    % NOTE: plt.std only  returns the last of  6 std bars plotted  below; ergo I
    % can't use topz on them because it only affects the last one plotted (a_5).
    % Therefore, I just plot  them in the order I want them  stacked and do topz
    % in the loop below.  Quick and dirty but effective.

    plot(ax, ax.XLim, [0 0], 'k')
    hold(ax, 'off')

    topz(pltsf(i).m);
    topz(pltsl(i).m);
    topz(pltsm(i).m);
    maxz = topz(plt(i).m);

    % SNR text box.
    pa(i) = patch(ax, px, py, repmat(maxz * 2, [4, 1]), 'w');
    tx(i) = text(ax, 1.1, 147, (maxz + 1) * 3, sprintf('$\\mathrm{SNR}=%i$', ...
                                                      varsnr(i)));


end

% These are fake lines to plot for the legend so that they don't have the marker
% (which represents the  mean); I think I  just want to note  the color (because
% there are also std. bars)
hold(ax, 'on')
pt = plot(ax, NaN, NaN, 'Color', col.t, 'LineWidth', 1, 'Marker', 'd', 'MarkerFaceColor', col.t);
ptsl = plot(ax, NaN, NaN, 'Color', col.tsl, 'LineWidth', 1, 'Marker', 'o', 'MarkerFaceColor', col.tsl);
ptsm = plot(ax, NaN, NaN, 'Color', col.tsm, 'LineWidth', 1, 'Marker', 'o', 'MarkerFaceColor', col.tsm);
ptsf = plot(ax, NaN, NaN, 'Color', col.tsf, 'LineWidth', 1, 'Marker', 'o', 'MarkerFaceColor', col.tsf);
hold(ax, 'off')

% In the order I label them (not the order I plotted them).
kwj = '$~~k_{\mathrm{w}_j}~~\mathrm{or}~~\overline{k_{\mathrm{w}}}_{_J}\quad$';
ksf = ['$~~\acute{k}^{\bot}_{j,l_\mathrm{w}}~~\mathrm{or}~~\' ...
       'acute{k}^{\bot}_{J,\overline{l_{\mathrm{w}}}}$\quad'];
ksm = ['$~~\acute{k}^{\mid}_{j,l_\mathrm{w}}~~\mathrm{or}~~\' ...
       'acute{k}^{\mid}_{J,\overline{l_{\mathrm{w}}}}$\quad'];
ksl = ['$~~\acute{k}^{\top}_{j,l_\mathrm{w}}~~\mathrm{or}~~\' ...
       'acute{k}^{\top}_{J,\overline{l_{\mathrm{w}}}}$'];

lgp = [pt, ptsf, ptsm, ptsl];
lgstr = {kwj ksf ksm ksl};

lg = legend(lgp, lgstr);
lg.Orientation = 'horizontal';
lg.Position = [0.3 0.31 0.4 0.1];
lg.Box ='off';

set(ha,'Box', 'on')
set(ha, 'TickDir', 'out')
set(ha, 'XLim', [0.5 6.5])
set(ha, 'XTick', [1:6])
set(ha, 'XTickLabel', {'$1$' '$2$' '$3$' '$4$' '$5$' '$\overline{5}$'})
for i = [6:10]
    xlabel(ha(i), 'scale')

end
set(ha(1:5), 'XTickLabel', [])

set(ha, 'YLim', [-200 200])
set(ha, 'YTick', [-200:50:200])

yl = ylabel(ha(1), sprintf('Multiscale changepoint estimation error\n(time domain samples)'));
yl.Position = [-0.9608 -229.9998];
ha(1).YTickLabel(1:2:end) = {[]};
ha(6).YTickLabel(1:2:end) = {[]};
set(ha([2:5 7:end]), 'YTickLabels', [])

shrink(ha, 0.85, 1)
longticks(ha, 0.8)
movev(ha(6:end), .25)
axesfs(f, 10, 10)
latimes

% Label axes.
[lax,th] = labelaxes(ha, 'ul', true,'FontName','Helvetica','FontSize',14, ...
                     'InterPreter','tex','FontWeight','Normal');
movev(lax, -0.057);
moveh(lax, -0.015)

savepdf(mfilename)

%____________________________________________________%

function [m, s, pl] = plotstats(ax, error_matrix, i, color, marker, markerfacecolor)

% Don't pull this out of loop (even though nanmean will work across
% all wavelet scales outside of a loop) because I want the j index as
% an x-axis location to plot the point and standard deviation bars.
for j = 1:6
    % Pull out the specific errors, over all test iterations, for the test
    % provided, at SNR index i, scale j.
    err = error_matrix(:, i, j);

    m(j) = nanmean(err);
    s(j) = nanstd(err, 1);

    stdlinex = [j j];
    stdliney = [m(j) - s(j) m(j) + s(j)];

    stdbarx = [j-0.2 j+0.2];
    stdbary1 = [m(j) + s(j) m(j) + s(j)];
    stdbary2 = [m(j) - s(j) m(j) - s(j)];

    % This plots the error bars.
    pl.std = plot(ax, stdlinex, stdliney, stdbarx, stdbary1, stdbarx, ...
                  stdbary2, 'Color', color);
    topz(pl.std);


end
% This plots the line.
pl.m = plot(ax, m, 'Color', color, 'Marker', marker, 'MarkerFaceColor', ...
            markerfacecolor, 'MarkerSize', 5);

end
