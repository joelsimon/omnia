% Figure 7
%
% Cite: Simon, J. D. et al., (2020), BSSA, doi: 10.1785/0120190173
%
% plotcpm1.m (a local version) with some formatting.
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

% Run cpest.m on the STATIC x time series.
[kw, km, aicx] =  cpest(x, 'fast', false, bias);
ykm = aicx(km);
ykw = aicx(kw);

% Run basic plotting function.
f = plotcpm1_local(bp, x, aicx, km, ykm, kw, ykw);

% And simply update the axes and marker sizes.
if bias == true
    % biased estimate of variance.
    f.ha.YLim = [375 400];
else
    % unbiased estimate of variance.
    f.ha.YLim = [376 402];
end

f.ha.XLim = [460 540];
f.plaicx_circ.MarkerSize = 4;

latimes
axesfs(gcf, 9, 13)
f.lg.FontSize = 10;

% Save it.
if bias == true
    warning('bias is TRUE, normalized by 1/N')
    savepdf(mfilename)
else
    warning('bias is FALSE, normalized by 1/(N-1)')
    savepdf([mfilename '_unbiased'])
end

%____________________________________________________________%
function f = plotcpm1_local(bp, x, aicx, km, ykm, kw, ykw)
% f = PLOTCPM1(bp,x,aicx,km,ykm,kw,ykw);
%
% Plots output of one test iteration of cpm1.m -- the zoom-in on aicx,
% highlighting sample error from true changepoint.
%
% Inputs:         Outputs from cpm1.m
%
% Output: f       Struct of figure's handles and bits
%
% Ex: PLOTCPM1('demo'), this function creates figure 1 via cpm1.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 23-Apr-2018, Version 2017b

% The sample errors and truth.
del_km = km - bp;
del_kw = kw - bp;
ytru = aicx(bp);

% Zoom in on AIC spread, rescale to center.
figure;
f.ha = gca;
fig2print(gcf, 'landscape')
hold on

f.plaicx_line = plot(aicx,'k');
f.plaicx_circ = plot(aicx,'o','Color','k','MarkerFaceColor','w');
topz(f.plaicx_circ);
f.pl_tru = plot(bp,ytru,'ko','MarkerFaceColor','k');
f.pl_km = plot(km,ykm,'bo','MarkerFaceColor','b');
f.pl_kw = plot(kw,ykw,'ro','MarkerFaceColor','r');

f.km_errLine = plot([km bp],[ykm ykm],'b-');
f.kw_errLine = plot([kw bp],[ykw ykw],'r-');
[xl_kw,xr_kw,yl_kw,yr_kw] = waterlvl(aicx,ykw);
[xl_tru,xr_tru,yl_tru,yr_tru] = waterlvl(aicx,ytru);

maxdiff = max(abs([xl_tru xr_tru xl_kw xr_kw km]-bp));
lx = length(x);
xliml = max((bp-maxdiff) - (0.01*lx),1);
xlimr = min((bp+maxdiff) + (0.01*lx),lx);
xlim([xliml xlimr]);

% Make invisible line/marker setup for truth for legend.
f.pl_km_lg = plot(NaN,'b-o','MarkerFaceColor','b');
f.pl_kw_lg = plot(NaN,'r-o','MarkerFaceColor','r');
lg_entries = [f.pl_tru f.pl_km_lg f.pl_kw_lg];

lg1 = {'$k_{\circ}$'};
lg2 = {sprintf('$k_\\mathrm{m} - k_{\\circ} = %+i~\\mathrm{%s}$', ...
               del_km, plurals('sample', del_km))};
lg3 = {sprintf('$k_\\mathrm{w} - k_{\\circ} = %+i~\\mathrm{%s}$', ...
               del_kw, plurals('sample', del_kw))};

lg_str = [lg1 lg2 lg3];
f.lg = legend(lg_entries,lg_str,'Location','NW', 'Interpreter', 'latex', 'autoupdate', 'off');
f.xl = xlabel('Sample index $k$','Interpreter','Latex');
f.yl = ylabel('Akaike information criterion $\mathcal{A}$', ...
              'Interpreter', 'Latex');

plot([500 500], ylim, 'k');
f.ha.Box = 'on';
f.ha.TickDir = 'out';
hold off

% Ensure red and blue points are at top of stack.
topz([f.pl_kw f.pl_km f.pl_tru]);
end
