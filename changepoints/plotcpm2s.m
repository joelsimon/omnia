function [f1,f2] = plotcpm2s(alphas,km_count,kw_count, ...
                                      iters,km_range,kw_range);
% [f1,f2] = PLOTCPM2S(alphas,km_count,kw_count,iters,km_range,kw_range);
%
% Plots cpm2.m summary curves, alpha level vs. probability
% truth at or below alpha level.
%
% Inputs:         
% alphas,...,kw_range  I/O from cpm2.m, see there
%
% Output: 
% f1/2                 Struct of figures' handles and bits
%
% Ex: PLOTCPM2S here creates figures 2 and 3 (via cpm2.m)
%    PLOTCPM2S('demo')
%
% See also: cpm2.m, plotcpm2.m, plotcpm2s2.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 27-Feb-2018, Version 2017b

% Demo, maybe.
if ischar(alphas)
    demo
    return
end

% Defaults I like.
defs = stdplt;
[kmstr,kwstr,alfa] = kmkw(defs.Interpreter);

% Two separate plots; one for km and one for kw.
for i = 1:2
    f(i).f = figure;
    f(i).ha = gca;
    fig2print(f(i).f,'landscape')
    
    % First go around is min (km); second is kw (kw).
    if i == 1
        % min (km) specific switches. Spans nab the sample span
        % that corresponds to each alpha level.
        f(i).pl = plot(alphas,(km_count/iters)*100,'k-','MarkerFaceColor', ...
                          'k','MarkerSize',6,'LineWidth',defs.lineWidth);
        titstr = sprintf('Confidence Interval Estimation Summary, %s',kmstr);
        cptype = kmstr;
    else
        % kw (kw) specific switches
        f(i).pl = plot(alphas,(kw_count/iters)*100,'r-','MarkerFaceColor', ...
                          'r','MarkerSize',6,'LineWidth',defs.lineWidth);
        titstr = sprintf('Confidence Interval Estimation Summary, %s',kwstr);
        cptype = kwstr;
    end        
    grid on
    oldticks = get(f(i).ha,'XTick');

    
    % X and Y labels.
    f(i).yl(i) = ylabel(sprintf(['Experiments where changepoint below ' ...
                        '%s (%s of 100)'],alfa,'%'),'FontSize',defs.font.sizeLabel,...
                        'FontName',defs.font.name,'FontWeight', ...
                        defs.font.weight,'Interpreter',defs.Interpreter);
    f(i).xl(i) = xlabel(sprintf(['%s: Percentage of AIC range searched ' ...
                        'above %s'],alfa,cptype), 'FontSize', ...
                        defs.font.sizeLabel, 'FontName', ...
                        defs.font.name,'FontWeight', ...
                        defs.font.weight,'Interpreter',defs.Interpreter);

    shrink(gca,1.2,1.2)
    ylim(f(i).ha,[0 100])
    xlim(f(i).ha,[0 alphas(end)])

    % Add a title.
    f(i).tl = title(titstr,'Interpreter',defs.Interpreter);
    f(i).tl.FontSize = defs.font.sizeTitle;
    f(i).tl.FontWeight = defs.font.weight;
    f(i).tl.FontName = defs.font.name;

    bxstr = sprintf('%i %s per %s',iters,plurals('iteration',iters),alfa);

    [f(i).bx,f(i).tx] = boxtex('lr',f(i).ha,bxstr, ...
                               defs.font.sizeLabel,[],[],[],[],[],defs.Interpreter);
    f(i).bx.Visible = 'off';
    f(i).tx.FontWeight = defs.font.weight;

    % Get indicies for of old XTicks and collect sample spans that
    % correspond to each alpha level plotted.
    for j = 1:length(oldticks)
        [~,idxs(j)] = min(abs(alphas - oldticks(j)));
    end

    if i == 1
        spans = arrayfun(@(x) sprintf('%3.1f',x),km_range(idxs),'UniformOutput',false);

    else
        spans = arrayfun(@(x) sprintf('%3.1f',x),kw_range(idxs),'UniformOutput',false);
    end
    % Add the axis.
    [f(i).xtra,f(i).xtraxl] = xtraxis(gca,oldticks,spans,'Samples spanned');
    f(i).xtraxl.FontSize = defs.font.sizeLabel;
    f(i).xtraxl.FontWeight = defs.font.weight;
    f(i).xtraxl.FontName = defs.font.name;
    f(i).xtraxl.Interpreter = defs.Interpreter;
    
    % Restore tick marks on top/right and final cosmetics.
    f(i).ha.Box = 'on';
    f(i).ha.TickLength = defs.tickLength;
    f(i).ha.TickDir = defs.tickDir;
    f(i).xtra.TickLength = defs.tickLength;
    f(i).xtra.TickDir = defs.tickDir;
end

% Collect outputs
f1 = f(1);
f2 = f(2);

function demo
    cpm2([0:10],1000,1000,500,'norm',{0 1},'norm',{0 sqrt(2)},false,false,false,true)






