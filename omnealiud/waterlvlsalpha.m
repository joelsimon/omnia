function [xl_ur,xr_ur,xl_r,xr_r,y_exact] = waterlvlsalpha(y,alfa,xidx)
% [xl_ur,xr_ur,xl_r,xr_r,y_exact] = WATERLVLSALPHA(y,alfa,xidx)
%
% Like waterlvlalpha.m but returns both restricted (contiguity
% enforced) and unrestricted (contiguity not enforced) x-axis limits.
% Faster if performing both tests.  
%
% Inputs:
% y             The time series
% alfa          Percentage of total range of y to set water level
%                   above global minimum, from 0:100.  E.g., 17 is 17%
% xidx          x index to use as base to add alfa
%
% Outputs:
% xl_ur,xr_ur   First/last (left/right) x-values whose
%                   corresponding y-values are at or below water level,
%                   UNRESTRICTED test
% xl_r,xr_r     First/last (left/right) x-values whose
%                   corresponding y-values are at or below water level,
%                   RESTRICTED test
% y_exact       The exact Y-value of y(xidx) + alfa
%
% See also: waterlvlalpha.m, waterlvl.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 18-Jan-2018, Version 2017b

% Defaults
defval('xidx',[])

% Sanity.
if alfa < 0 || alfa > 100
    error('alfa = %.1f.  Must be between 0 and 100, inclusive.',alfa)
end

% Data prep.
fy = isfinite(y);
rangey = range(y(fy));

% Here's switch for optional input; if no xidx supplied, the waterlvl
% is taken from the minimum of the function y. If xidx supplied, the
% alfa percentage is added to whatever value the function y attains at
% xidx.
if isempty(xidx)
    miny = min(y(fy));
else
    miny = y(xidx);
end

%% UNRESTRICTED
% Find waterline and apply to h20lvl.m.
y_exact = miny + (rangey * alfa/100);
[xl_ur, xr_ur, ~, ~, ~, xraw] =  waterlvl(y, y_exact);

%% RESTRICTED
% offset is the x-index to start contiguity search -- the x index to
% look forward and backward to check if contiguity is broken.
offset = find(xraw == xidx);
[xl_r, xr_r] = contiguous(xraw, offset, 'both');

