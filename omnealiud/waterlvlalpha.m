function varargout = waterlvlalpha(y,alfa,xidx,restrikt,plt)
% [xl,xr,yl,yr,y_exact] = WATERLVLALPHA(y,alfa,xidx,restrikt,plt)
%
% Exactly like waterlvl.m, but works based on percentages instead of
% absolute values above the minimum of the signal. Defaults to use
% global minimum of function y as point above which to add alfa
% percentage, but if xidx supplied, will use that instead.
%
% Inputs:
% y                   The time series
% alfa                Percentage of total range of y to set water
%                         level above global minimum, from 0:100.
%                         E.g., 17 is 17%
% xidx                x index to use as base to add alfa
% restrikt            Enforce contiguity? (def: false)*
% plt                 Plot it? (def: false)
% 
% Output:
% xl/r                First/last (left/right) x-values whose
%                         corresponding y-values at or below waterline
% yl/r                Y-values connected to y(xl) and y(xr)
% y_exact             The exact Y-value of y(xidx) + alfa
%
% * see waterlvlsalpha.m to perform both tests concurrently.
%
% Ex: WATERLVLALPHA('demo')
%
% See also: waterlvlsalpha.m, waterlvl.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 08-Jan-2018, Version 2017b

% Defaults
defval('xidx',[])
defval('restrikt',false)
defval('plt',false)

% Run demo and exit.
if ischar(y)
    demo
    return
end

% Sanity.
if alfa < 0 || alfa > 100
    error('alfa = %.1f.  Must be between 0 and 100 inclusive.',alfa)
end

% Data prep.
fy = isfinite(y);
rangey = range(y(fy));

% Here's switch for optional input; if no xidx supplied, the
% waterlvl is taken from the minimum of the function y. If xidx
% supplied, the alfa percentage is added to whatever value the
% function y attains at xidx.
if isempty(xidx)
    miny = min(y(fy));
else
    miny = y(xidx);
end

% Find waterline and apply to waterlvl.m.
y_exact = miny + (rangey * alfa/100);
[xl,xr,yl,yr,~,xraw] = waterlvl(y,y_exact);

% Enfore contiguity?
if restrikt
    % offset is the x-index to start contiguity search -- the x index to
    % look forward and backward to check if contiguity is broken.
    offset = find(xraw == xidx);
    [xl,xr] = contiguous(xraw,offset,'both');
    yl = y(xl);
    yr = y(xr);
end
    
% Collect outputs
varns = {xl,xr,yl,yr,y_exact};
varargout = varns(1:nargout);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot it, maybe
if plt
    py = plot(y,'k');
    y_exact = miny + rangey*(alfa/100);
    hl = fx(horzline(y_exact),1);
    hold on
    plr = plot(xl,yl,'ro',xr,yr,'bo');
    longticks(gca,4)
    bx = boxtex('ll',gca,sprintf('%i %s below alfa',length(xl:xr),...
                                 plurals('sample',length(xl:xr))),15);
    bx.Visible = 'off';
    hold off
    lgentries = [py hl plr'];
    lgstr = {'Time Series', ...
             sprintf('Requested water level of %.2f%s',alfa,'%'), ...
             sprintf('Leftmost x/y at or below %.2f%s',alfa,'%'), ...
             sprintf('Rightmost x/y at or below %.2f%s',alfa,'%')};
    legend(lgentries, lgstr)
end

function demo
    [~,~,y] = cpest(cpgen(1000,500,'norm',{0 1},'norm',{0 sqrt(2)}));
    alfa = .75;
    % Unrestricted
    subplot(2,1,1);
    waterlvlalpha(y,alfa,350,false,true);
    % Restricted
    subplot(2,1,2)
    waterlvlalpha(y,alfa,350,true,true);
    ha = gaa;
    ha(1).Title.String = 'Restricted: Contiguity Enforced';
    ha(2).Title.String = 'Unrestricted: Contiguity Not Enforced';
    shg
