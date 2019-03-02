function [xl,xr,yl,yr] = waterbar(x,xidx,alpha,plt)
% [xl,xr,yl,yr] = WATERBAR(x,xidx,alpha,plt)
%
% Like waterlvl.m, waterlvlalpha.m, but instead of specifiying a
% value/alpha above the global min of a function, it finds the x/y
% spread ABOUT a point. So if you put in a function, x value of
% interest, and alpha = 10, it will look 10% above and 10% below the x
% value, and return the spread of values contained CONTIGUOUSLY. I.e.,
% won't cross an AIC branch.
%
% Input:
% x                   The time series
% xidx                x index about which to +/- alpha
% alpha               Percentage to return +/- value of function at xidx
% plt                 1 to plot [def = 0]
% 
% Output:
% xl,yl               Leftmost x/y pair within waterbar
% xr,xr               Rightmost x/y pair within waterbar
% yl_alpha            True percentage above global minimum of yl
% yr_alpha            Same, for yr
%
% Ex: waterbar('demo')
%
% See also: waterlvl.m, waterlvlalpha.m, cpest.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 02-Dec-2016, Version 2017b

% Defaults
defval('plt',0)

% Demo
if ischar(x)
    [~,~,x] = cpest(cpgen(1000,500));
    xidx = 250;
    alpha = 7.8;
    [xl,xr,yl,yr] = waterbar(x,xidx,alpha,1);
end

% If alpha = 0%, just return the inputs
if alpha == 0
    xl = xidx; xr = xidx;
    yl = x(xidx); yr = yl;
    exact_hi = yl; exact_lo = exact_hi;
    if plt
        warning('Nothing to plot when alpha = 0')
    end
    return
end

% Data prep
yval = x(xidx);
fx = isfinite(x);
rangex = range(x(fx));
minx = min(x(fx));
maxx = max(x(fx));

% +/- half of alpha
plus_minus = rangex * (alpha/100);

% Find waterline and apply to  waterlvl.m
waterline_lo = yval - plus_minus;
waterline_hi = yval + plus_minus;

lo = find(x < waterline_lo);
hi = find(x > waterline_hi);

% Nab indices contained within hi and lo waterline
withinbar = setdiff(find(fx),[lo(:);hi(:)]);
if isempty(withinbar)
    xl = [];
    xr = []; 
    yl = []; 
    yr = [];
    return
end

% Very innefficient way to do this. Maybe do something with
% find(diff == 1) as opposed to two separate loops. Not worth the
% time; this works
lx = length(x);

% Going backwards
for i = [xidx:-1:1]
    if intersect(i,withinbar)
        if xidx == 1
            xl = 1;
        end
        continue
    else
        xl = i + 1;
        break
    end
end

% Going forwards
for i = xidx:lx
    if intersect(i,withinbar)
        if i == lx
            xr = lx;
        end
        continue
    else
        xr = i - 1;
        break
    end
end

% Collect outputs
yl = x(xl);
yr = x(xr);

% Plot it, maybe
if plt 
    plx = plot(x,'k-+');
    axis tight
    hl = horzline(waterline_lo);
    hh = horzline(waterline_hi);
    hold on
    plbar = plot(xl,yl,'ro',xr,yr,'bo');
    hold off
    hold on
    lg_entries = [plx,hl{1},plbar(1),plbar(2)];
    lg_str = {'The Signal',sprintf('+/- %3.2f%s about sample %i',...
                                   alpha,'%',xidx),...
              'Leftmost sample at or below alpha','Rightmost sample at or below alpha'};

    legend(lg_entries,lg_str,'AutoUpdate','off')
    longticks(gca,4)
end
