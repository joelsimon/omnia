function f = plotcpm1(cp, x, aicx, km, ykm, kw, ykw)
% f = PLOTCPM1(cp,x,aicx,km,ykm,kw,ykw);
%
% Plots output of one test iteration of cpm1.m -- the zoom-in on aicx,
% highlighting sample error from true changepoint.
%
% Input:         
% cp            Index of changepoint where distribution changes
% x             The time series
% aicx          AIC curve of the time series
% km            Changepoint estimate: x index of AIC global minimum 
% ykm           AIC value at km, aicx(km)
% kw            Changepoint estimate: weighted average of Akaike weights
% ykm           AIC value at kw, aicx(kw)
%
% Output:        
% f              Struct of figure's handles and bits
%
% Ex1: PLOTCPM1 here creates figure 1 (via cpm1.m)
%    PLOTCPM1('demo')
%
% Ex2: True cp at index 500 of length 1000 time series
%    cp = 500;
%    x = cpgen(1000, cp);
%    [kw,km,aicx] = cpest(x);
%    f = PLOTCPM1(cp,x,aicx,km,aicx(km),kw,aicx(kw))
%
% See also: plotcpm1s.m, cpm1.m, cpm2.m, cpci.m
% 
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 23-Apr-2018, Version 2017b

% Demo, maybe.
if ischar(cp)
    demo
    return
end

% The sample errors and truth.
del_km = km - cp;
del_kw = kw - cp;
ytru = aicx(cp);

% Zoom in on AIC spread, rescale to center.
figure;
f.ha = gca;
fig2print(gcf, 'landscape')
hold on

f.plaicx_line = plot(aicx,'k');
f.plaicx_circ = plot(aicx,'o','Color','k','MarkerFaceColor','w');
topz(f.plaicx_circ);
f.pl_tru = plot(cp,ytru,'ko','MarkerFaceColor','k');
f.pl_km = plot(km,ykm,'bo','MarkerFaceColor','b');
f.pl_kw = plot(kw,ykw,'ro','MarkerFaceColor','r');

f.km_errLine = plot([km cp],[ykm ykm],'b-');
f.kw_errLine = plot([kw cp],[ykw ykw],'r-');
[xl_kw,xr_kw,yl_kw,yr_kw] = waterlvl(aicx,ykw);
[xl_tru,xr_tru,yl_tru,yr_tru] = waterlvl(aicx,ytru);

maxdiff = max(abs([xl_tru xr_tru xl_kw xr_kw km]-cp));
lx = length(x);
xliml = max((cp-maxdiff) - (0.01*lx),1);
xlimr = min((cp+maxdiff) + (0.01*lx),lx);
xlim([xliml xlimr]);
f.vl_tru = vertline(cp,[],'k');

% Make invisible line/marker setup for truth for legend.
f.pl_km_lg = plot(NaN,'b-o','MarkerFaceColor','b');
f.pl_kw_lg = plot(NaN,'r-o','MarkerFaceColor','r');
lg_entries = [f.pl_tru f.pl_km_lg f.pl_kw_lg];

lg1 = {'$k_{\circ}$'};
lg2 = {sprintf('$k_m~\\mathrm{error} = %+i~\\mathrm{%s}$',del_km,plurals('sample',del_km))};
lg3 = {sprintf('$k_m~\\mathrm{error} = %+i~\\mathrm{%s}$',del_kw,plurals('sample',del_kw))};

lg_str = [lg1 lg2 lg3];
f.lg = legend(lg_entries,lg_str,'Location','NW', 'Interpreter', 'latex');
f.xl = xlabel('sample index $k$','Interpreter','Latex');
f.yl = ylabel('$\mathcal{A}$','Interpreter','Latex');

f.ha.Box = 'on';
f.ha.TickDir = 'out';
hold off

% Ensure red and blue points are at top of stack.
topz([f.pl_kw f.pl_km f.pl_tru]);


function demo
    % This function is figure 1.
    cpm1(1000,1000,500,'norm',{0 1},'norm',{0 sqrt(2)},false,false,true)



