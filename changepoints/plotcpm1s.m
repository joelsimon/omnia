function f = plotcpm1s(del_km,del_kw)
% f = PLOTCPM1S(del_km,del_kw)
%
% Plots summary histogram of all cpm1.m experiments.
% 
% Input:          
% del_km/w    Outputs from cpm1.m, see there
%
% Output: 
% f           Struct of figure's handles and bits
%
% Ex: PLOTCPM1S here creates figure 2 (via cpm1.m)
%    PLOTCPM1S('demo')
%
% See also: plotcpm1.m, cpm1.m, cpm2.m, cpci.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 27-Feb-2018, Version 2017b

% Demo, maybe.
if ischar(del_km)
    demo
    return
end

% Defaults I like.
defs = stdplt;
[kmstr,kwstr] = kmkw(defs.Interpreter);

figure;
f.f = gcf;
f.ha = gca;
fig2print(gcf,'landscape')
[~,km_edges] = histcounts(del_km);
[~,kw_edges] = histcounts(del_kw);
if max(abs(km_edges)) >= max(abs(kw_edges));
    binedges = km_edges;
else
    binedges = kw_edges;
end
f.h1 = histogram(del_km,binedges,'Normalization','prob');
hold on
f.h2 = histogram(del_kw,binedges,'Normalization','prob'); 
hold off
f.h1.FaceColor = 'k';
f.h2.FaceColor = 'r';
maxy = max([max(f.h1.Values) max(f.h2.Values)]);
ylim([0 1.2*maxy]);
maxdiffh = max(abs([f.h1.BinEdges, f.h2.BinEdges]));
xlim([-maxdiffh maxdiffh])
f.xl = xlabel('Sample Error','FontName',defs.font.name,'FontSize', ...
              defs.font.sizeLabel,'FontWeight',defs.font.weight, ...
              'Interpreter',defs.Interpreter);
f.yl = ylabel('Probabilty','FontName',defs.font.name,'FontSize', ...
              defs.font.sizeLabel,'FontWeight',defs.font.weight, ...
              'Interpreter',defs.Interpreter);
meankm = mean(del_km);
stdkm = std(del_km);
meankw = mean(del_kw);
stdkw = std(del_kw);
f.kmstr = sprintf(' %s: %s = %3.2f, %s = %.2f',kmstr,'$\mu$', ...
                   meankm,'$\sigma$',stdkm);
f.kwstr = sprintf(' %s: %s = %3.2f, %s = %.2f',kwstr,'$\mu$', ...
                   meankw,'$\sigma$',stdkw);
f.lg = legend({f.kmstr,f.kwstr},'Interpreter',defs.Interpreter, ...
              'Location','NW','FontName', defs.font.name,'FontSize', ...
              defs.font.sizeBox, 'FontWeight',defs.font.weight);
f.ha.TickLength = defs.tickLength;
f.ha.TickDir = defs.tickDir;

% Bring km global hist to top of stack.
f.h1.FaceAlpha = 0;
f.h1.LineWidth = 2;
f.h2.FaceAlpha = 1;
f.h2.LineWidth = 2;
f.h2.EdgeColor = 'r';
uistack(f.h1,'top')

function demo
    % This function is figure 2.
    cpm1(1000,1000,500,'norm',{0 1},'norm',{0 sqrt(2)},false,false,true)


