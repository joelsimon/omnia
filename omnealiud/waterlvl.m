function [xl,xr,yl,yr,alpha,xidx] = waterlvl(y,waterline)
% [xl,xr,yl,yr,alpha,xidx] = WATERLVL(y,waterline)
%
% WATERLVL returns the first ('xl') and last ('xr') indices in 'y'
% whose corresponding values fall equal to or below 'waterline'.  No
% concept of 'restrikt' as in waterlvlalpha.  This merely asks if
% above/below waterline and enforces no contiguity.
%
% ** Returns NaN output if function starts/ends above waterline.
% Ignores +-Inf but maintains those indices.
%
% Inputs:
% y                The time series
% waterline        The y value of the water level
%
% Outputs:
% xl/r             First/last (left/right) x-values whos
%                       corresponding y-values are just below waterline
% yl/r             y-values connected to xl/xr
% alpha            Percentage of range(y) that waterlvl lies above global minimum of x
% xidx             Complete series of x indices whos y values are
%                      below waterline (useful for contiguity enforcement)
% 
% Ex: WATERLVL('demo')
% 
% Ex2: 
%     y = [-Inf -Inf 2 3 1 -inf 2 3 4 NaN]
%     [xl,xr] = WATERLVL(y,3)
%     >> xl = 3, xr = 8  
%     ** Ignores -Inf; doesn't assume that's below waterline
% 
% See also: waterlvlalpha.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 19-Jun-2017, Version 2017b

% Run demo and exit.
if ischar(y)
    demo
    return
end

% Values at or below waterline.
underwater = find(y <= waterline);

% Ignore non-finite values.  No need to worry about maintaining proper
% indices with unzipnan.m because 'underwater' is already a series of
% indices.  We just want to know the first and last values of the
% index series.  If the first or last value is nonfinite, we want to
% remove it.
fy = isfinite(y);
dne = intersect(underwater,find(~fy));;
underwater(dne) = [];

% Make sure entire signal isn't above waterline.
if isempty(underwater) 
    xl = NaN; 
    xr = NaN; 
    yl = NaN; 
    yr = NaN;
    xidx = NaN;
    alpha = NaN;
    warning(sprintf('y never dips below waterline of %+.2f',waterline))
else
    % And collect output.
    xl = underwater(1);
    xr = underwater(end);
    yl = y(xl);
    yr = y(xr);
    xidx = underwater;
end

% Calculate percentage above xval.
alpha = ((waterline-min(fy))/range(fy)) * 100;
 
% Demo.
function demo 
    [~,~,y] = cpest(cpgen(1000,500));
    waterline = y(250);
    [xl,xr,yl,yr] = waterlvl(y,waterline);
    plot(y,'-ok','MarkerSize',4)
    horzline(waterline);
    hold on
    plot(xl,yl,'or','MarkerSize',8,'MarkerFaceColor','r')
    plot(xr,yr,'or','MarkerSize',8,'MarkerFaceColor','r')
    hold off
    shg



