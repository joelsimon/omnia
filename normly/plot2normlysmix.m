function f = plot2normlysmix(perc, trusigmas, lx, cp, axlim, npts, ntests, meth)
% f = PLOT2NORMLYSMIX(perc,trusigmas,lx,cp,axlim,npts,ntests,meth)
%
% Like plot2normlystest.m, except this function includes some
% percentage of noise/signal included in each test.
%
% In keeping with notation of simon+2019.pdf, standard deviation and
% variance statistics are returned in their biased forms:
%
%                       1/N; not 1/(N-1)
% Input:
% perc        Percentage of lx mixed between noise, signal (def: 10)
% trusigmas   2 standard deviations of noise, signal segments
%                 (def: [1 sqrt(2)])
% lx          Length random time series generated here (def: 1000)
% cp          Sample index of changepoint that separates noise, signal
%                 (def: 500)
% axlim       x-axis limits of likelihood plots,
%                ('normvars' in normlysmix.m) (def: [.5 1.5])
% npts        Number of x-axis points (e.g., number of likelihood
%                 calculations per time series tested) (def: 100)
% ntests      Number of likelihood curves plotted (def: 100)
% meth        1: Sum log-likelihoods same normalized variance
%             2: Sum log-likelihoods using single value of correctly
%                mixed section: its maximum log-likelihood (def)
%             3: Sum log-likelihoods using single value of correctly
%                mixed section: its log-likelihood at the sigma tested
%                which is nearest the trusigma of generating
%                distribution
% Output:
% f           Struct with relevant figure handles
%                 NOTE: f.ha1 through f.ha(4) are linked;
%                 f.ha(5) and f.ha(6) are linked.
%
% Ex:
%    f = PLOT2NORMLYSMIX(25,[1 sqrt(2)],1000,500,[0.1 10],100,25,1)
%
% See also: normlysmix.m, plotnormlysmix.m, plotnormlysmixsum.m.
%
% Cite: Simon, J. D. et al., (2020), BSSA, doi: 10.1785/0120190173
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 10-Jan-2020, Version 2017b on GLNXA64

% Defaults.
defval('perc', 10)
defval('trusigmas', [1 sqrt(2)])
defval('lx', 1000)
defval('cp', 500)
defval('axlim', [.5 1.5])
defval('npts', 100)
defval('ntests', 100)
defval('meth', 1)

% Set up figure window
f.fig = figure;
fig2print(f.fig, 'flandscape')
f.ha(1) = subplot(4,6, [1 2 7 8 ]);
f.ha(2) = subplot(4,6, [3 4 9 10]);
f.ha(3) = subplot(4,6, [5 6 11 12]);
f.ha(4) = subplot(4,6, [13 14 19 20]);
f.ha(5) = subplot(4,6, [15:18]);
f.ha(6) = subplot(4,6, [21:24]);

% Shrink everything so there is more space to work with.
shrink(gaa(f.fig), 1.1, 1.1);
movev([f.ha(4) f.ha(5) f.ha(6)], -0.01)

% Shift stuff around.
pica = .01;
moveh(f.ha(1), -2*pica);
moveh(f.ha(2), pica);
moveh(f.ha(3), -pica);
moveh(f.ha(4), -2*pica);

% Align plot 5 and 6.
f.pos2 = axpos(f.ha(2));
f.pos3 = axpos(f.ha(3));
f.pos4 = axpos(f.ha(4));
height4 = f.ha(4).Position(4);

% Set gap between 5/6 equal to gap between 2/3, adjust for
% paper size (.1 vertically is not .1 horizontally)
gap = (f.pos3.ll(1) - f.pos2.lr(1)) * (f.fig.PaperSize(1)/f.fig.PaperSize(2));
height56 = .5*height4 - .5*gap;

f.ha(5).Position(1) = f.ha(2).Position(1);
f.ha(5).Position(2) = f.pos4.rightmid(2) + .5*gap;
f.ha(5).Position(3) = f.pos3.lr(1) - f.pos2.ll(1);
f.ha(5).Position(4) = height56;

f.ha(6).Position(1) = f.ha(2).Position(1);
f.ha(6).Position(2) = f.ha(4).Position(2);
f.ha(6).Position(3) = f.pos3.lr(1) - f.pos2.ll(1);
f.ha(6).Position(4) = height56;

% And for completeness hold onto other positions.
f.pos1 = axpos(f.ha(1));
f.pos5 = axpos(f.ha(5));
f.pos6 = axpos(f.ha(6));

% Run normlysmix.m to generate MLE sigma^2 values and likelihood
% curves at every sigma tested.
[enk, esk, lnk, lsk, y] = normlysmix(perc, trusigmas, axlim, npts, ...
                                     lx, cp, ntests);

%% Begin plotting.
%%_____________________________________________________%%
% First plot: joint log-likelihood curves where the CHANGEPOINT is LATE.

ax = f.ha(1);
f.f1 = plotnormlysmixsum(lnk, lsk, false, ax, meth);

ylabel(ax, 'Summed log likelihood $\ell$', 'Interpreter', 'Latex');
xlabel(ax, 'Normalized variance $\hat\sigma^2/\sigma_{\circ}^2$', 'Interpreter', ...
       'Latex');

f.f1.hl = fx(horzline(f.f1.meany, ax, 'k'), 1);

%%_____________________________________________________%%
% Second plot: the noise, n(k), when the CHANGEPOINT is LATE
ax = f.ha(2);
f.f2 = plotnormlysmix(lnk, false, ax,1);

xlabel(ax, 'Normalized variance $\hat\sigma_1^2/\sigma_{1_\circ}^2$', 'Interpreter', ...
       'Latex');
ylabel(ax, 'Log likelihoods $\ell_1,~\ell_2$', 'Interpreter', 'Latex');

set(f.f2.ly, 'Color', 'b')
set(f.f2.MLE, 'Color', 'k', 'MarkerFaceColor', 'k')

f.f2.hl = fx(horzline(f.f2.meany, ax, 'k'), 1);

%%_____________________________________________________%%
% Third plot: the signal, s(k), when the CHANGEPOINT is EARLY
ax = f.ha(3);
f.f3 = plotnormlysmix(esk, false, ax,2);

xlabel(ax, 'Normalized variance $\hat\sigma_2^2/\sigma_{2_\circ}^2$', ...
       'Interpreter', 'Latex');

set(f.f3.ly, 'Color', 'r')
set(f.f3.MLE, 'Color', 'k', 'MarkerFaceColor', 'k')

f.f3.hl = fx(horzline(f.f3.meany, ax, 'k'), 1);
%%_____________________________________________________%%
% Fourth plot: joint log-likelihood curves where the CHANGEPOINT is EARLY.
ax = f.ha(4);
f.f4 = plotnormlysmixsum(enk, esk, false, ax, meth);

set(f.f4.xhair.c, 'ZData', f.f4.MLE(1).ZData + 1);

ax.XLabel.String = f.ha(1).XLabel.String;
ax.YLabel.String = f.ha(1).YLabel.String;

f.f4.hl = fx(horzline(f.f4.meany, ax, 'k'), 1);
%%_____________________________________________________%%
% Fifth plot: example time series where CHANGEPOINT is LATE.
ax = f.ha(5);

mixsamps = round(lx*perc/100);
late_ynum = randi(length(y),1);
late_y = y{late_ynum};

latenksamps = late_y(1:cp+mixsamps);
latesksamps = late_y(cp+mixsamps+1:end);

hold(ax, 'on')
f.f5.nk = plot(ax, [1:cp+mixsamps], latenksamps, 'b');
f.f5.sk = plot(ax, [cp+mixsamps+1:lx], latesksamps, 'r');

% Vertical line.
f.f5.vltru = fx(vertline(cp, ax, 'k'), 1);
f.f5.vlest = fx(vertline(cp+mixsamps, ax, 'k:'), 1);
hold(ax,'off')

xlim(ax,[1 lx]);
add1XTick(ax);
xticklabels(ax, [])

ylabel(ax, '$x$', 'Interpreter', 'latex');

axis(ax, 'tight')
box(ax, 'on');
longticks(ax, 4)

%%_____________________________________________________%%
% Sixth plot: example time series where CHANGEPOINT is EARLY.
ax = f.ha(6);

early_ynum = randi(length(y),1);
early_y = y{early_ynum};

earlynksamps = early_y(1:cp-mixsamps);
earlysksamps = early_y(cp-mixsamps+1:end);

hold(ax,'on')
f.f6.nk = plot(ax, [1:cp-mixsamps], earlynksamps, 'b');
f.f6.sk = plot(ax, [cp-mixsamps+1:lx], earlysksamps, 'r');

% Vertical lines
hold(ax,'on')

f.f6.vltru = fx(vertline(cp, ax, 'k'), 1);
f.f6.vlest = fx(vertline(cp-mixsamps, ax, 'k:'), 1);

xlabel(ax, 'Sample index $k$', 'Interpreter', 'latex');
ylabel(ax, '$x$', 'Interpreter', 'latex');

xlim(ax,[1 lx]);
add1XTick(ax);

ylabel(ax, '$x$');

axis(ax, 'tight')
box(ax, 'on');
longticks(ax, 4)

%%_____________________________________________________%%
% Put all on the same axes; open up first then link.
linkaxes([f.ha(1) f.ha(2) f.ha(3) f.ha(4)])

% Link 5/6 and make y-axis symmetrical (only have to call symaxes.m
% once because 5 and 6 are now linked).
linkaxes([f.ha(5) f.ha(6)])
symaxes(f.ha(5), 'y');

% Delete YTicks on ha(3).
ylabel(f.ha(3), []);
yticklabels(f.ha(3), []);

set(f.ha, 'TickDir', 'out')

%%_____________________________________________________%%
% Return sorted structure.
f = orderfields(f);
return

% To highlight a random time series --
f.f1.hily = f.f1.ly(late_ynum);
f.f1.hily.Color = 'k';
f.f1.hily.LineWidth = defs.lineWidth;
f.f1.hily.ZData = ...
    repmat(f.f1.xhair.c.ZData,size(f.f1.hily.YData));

f.f2.hily = f.f2.ly(late_ynum);
f.f2.hily.Color = 'k';
f.f2.hily.LineWidth = defs.lineWidth;
f.f2.hily.ZData = ...
    repmat(f.f2.xhair.c.ZData,size(f.f2.hily.YData));

f.f3.hily = f.f3.ly(early_ynum);
f.f3.hily.Color = 'k';
f.f3.hily.LineWidth = defs.lineWidth;
f.f3.hily.ZData = ...
    repmat(f.f3.xhair.c.ZData,size(f.f3.hily.YData));


f.f4.hily = f.f4.ly(early_ynum);
f.f4.hily.Color = 'k';
f.f4.hily.LineWidth = defs.lineWidth;
f.f4.hily.ZData = ...
    repmat(f.f4.xhair.c.ZData,size(f.f4.hily.YData));
