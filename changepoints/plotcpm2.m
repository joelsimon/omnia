function f = plotcpm2(alphas,cp,aicx,km,ykm,kw,ykw,restrikt,lvls)
% f = PLOTCPM2(alphas,cp,aicx,km,ykm,kw,ykw,restrikt,lvls)
% 
% Plots the output of one test iteration of cpm2 -- zoom-in on aicx,
% highlighting some alpha levels above the changepoint estimators. Will
% definitely require some massaging of the alphalvl string positions.
%
% Inputs:    
% alphas        Alpha levels (percentages) to test 
% cp            Index of changepoint where distribution changes
% aicx          AIC curve of the input time series
% km            Changepoint estimate: x index of AIC global minimum 
% ykm           AIC value at km, aicx(km)
% kw            Changepoint estimate: weighted average of Akaike weights
% ykm           AIC value at kw, aicx(kw)
% restrikt      Enforce contiguity? 
% lvls          Array specifying alpha lvls to be plotted
%
% Output: 
% f             Struct of figure's handles and bits
%
% Ex1: PLOTCPM2 here creates figure 1 (via cpm2.m)
%    PLOTCPM2('demo')
%
% Ex2: True cp at index 500 of length 1000 time series
%    cp = 500;
%    x = cpgen(1000, cp);
%    [kw,km,aicx] = cpest(x);
%    f = PLOTCPM2([0:2:10],cp,aicx,km,aicx(km),kw,aicx(kw),false,[0:2:10])
% 
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 27-Feb-2018, Version 2017b

% Demo, maybe.
if ischar(alphas)
    demo
    return
end

% Default to plot 4 equally spaced alpha lvls.
defval('lvls',linspace(0,max(alphas),4))

% Set up figure and plot the AIC function.
f.f = figure;
f.ha = gca;
fig2print(f.f,'landscape')
hold on

f.plaicx = plot(aicx,'k-o','MarkerFaceColor','w');
f.pl_km = plot(km,ykm,'bo','MarkerFaceColor','b');
f.pl_kw = plot(kw,ykw,'ro','MarkerFaceColor','r');
ytru = aicx(cp);
f.pl_tru = plot(cp,ytru,'ko','MarkerFaceColor','k');
f.vl_tru = vertline(cp,[],'k');
hold off

% Plot some example waterlvls.
for i = 1:length(lvls)
    % Find waterlvls.
    [xl_kw(i),xr_kw(i),yl_kw(i),yr_kw(i),y_exact_kw(i)] = ...
        waterlvlalpha(aicx, lvls(i),kw,restrikt);
    [xl_km(i),xr_km(i),yl_km(i),yr_km(i),y_exact_km(i)] = ...
        waterlvlalpha(aicx, lvls(i),km,restrikt);

    % And plot them.
    hold on
    f.hl_kw(i) = plot([xl_kw(i) xr_kw(i)],[y_exact_kw(i) y_exact_kw(i)],'r:');
    f.hl_km(i) = plot([xl_km(i) xr_km(i)],[y_exact_km(i) y_exact_km(i)],'b:');
    hold off
    % Format switch for integer alpha levels (looks cleaner).
    if isint(lvls(i)) == true
        fmt = '%i';
    else
        fmt = '%.1f';
    end
    
    % Add add annotated boxes.
    tstr = sprintf(['+' sprintf('%s',fmt) '%s'],lvls(i),'%');

    [f.bh_km(i),f.th_km(i)] = boxtex([mean(f.hl_km(i).XData) ...
                        f.hl_km(i).YData(1)],gca,tstr);
    
    [f.bh_kw(i),f.th_kw(i)] = boxtex([mean(f.hl_kw(i).XData) ...
                        f.hl_kw(i).YData(1)],gca,tstr);

    f.bh_km(i).Visible = 'off';
    f.bh_kw(i).Visible = 'off';

    f.th_km(i).Color = 'b';
    f.th_kw(i).Color = 'r';
end
% Plot horizontal line at true y-value.
f.hl_tru = horzline(ytru,[],'k','LineStyle',':');

% Use the largest waterlvl for the recentering (it has largest spread)
maxdiff = max([abs(min(xl_kw)-cp) abs(max(xr_kw)-cp)]);
lx = length(aicx);
xliml = max((cp-maxdiff) - (0.01*lx),1);
xlimr = min((cp+maxdiff) + (0.01*lx),lx);
xlim([xliml xlimr]);
rangex = range(aicx(isfinite(aicx)));
f.vl_tru = vertline(cp,[],'k');

% Make a more verbose waterlvl label for 0 percent; highlight
% range. I'm just guessing on how to center justify the second line
% here; may have to adjust the number of tildes.
tstr = 'k_m +0%s of AIC range\n(spread = 0 samples)';
f.th_km(1).String = sprintf(tstr,'%');

tstr = 'k_w +0%s of AIC range\n (spread = %i %s)';
tstr = sprintf(tstr,'%',xr_kw(1)-xl_kw(1),plurals('sample',xr_kw(1)-xl_kw(1)));
f.th_kw(1).String = tstr;

% Cosmetics
f.xl = xlabel('sample (k)');
f.yl = ylabel('AIC');

[f.bx,f.bxt] = boxtex('lr',gca,sprintf('AIC range = %.1f',rangex));
f.bx.Visible = 'off';

lg_entries = [f.pl_tru f.pl_km f.pl_kw];
lg_str = {'true changepoint','k_m','k_w'};
f.lg = legend(lg_entries,lg_str,'Location','NW');

f.ha.Box = 'on';
f.ha.TickDir = 'out';

% Ensure red and blue points are at top of stack.
topz(f.plaicx);
topz(f.pl_tru);
topz(f.pl_km);
topz(f.pl_kw);

function demo
    cpm2([0:10],1000,1000,500,'norm',{0 1},'norm',{0 sqrt(2)},false,false,false,true)
