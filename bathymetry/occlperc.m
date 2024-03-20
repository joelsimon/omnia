function [perc, tz] = occlperc(z, tz)
% [perc, tz] = OCCLPERC(z, tz)
%
% Compute occlusion percentage where occlusion is defined to be any elevation
% (`z`) that is HIGHER (less deep) than a test elevation (`tz).
%
% Think
%
% Input:
% tz       Test elevation array [m]
% z        Elevation array or matrix, e.g., from gebco.m [m]
%
% Output:
% perc     Occlusion percentage at test depths, returned as column [m]
% tz       Test elevation array, returned as column [m]
%
% Ex:
%    z = [-10 -5 0; -25 -15 -20; -10 0 -5]
%    tz = [0:-10:-30]'
%    OCCLPERC(z, tz)
%
% See also: gebco.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 20-Mar-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

if ~isrow(tz)
    tz = tz';

end
z = z(:);
numz = sum(~isnan(z));
numo = sum(z > tz);
perc = 100 * (numo / numz);

tz = tz';
perc = perc';
