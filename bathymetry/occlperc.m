function perc = occlperc(z, tz)
% perc = OCCLPERC(z, tz)
%
% Compute occlusion percentage where occlusion is defined to be any elevation
% (`z`) that is HIGHER (less deep) than a test elevation (`tz).
%
% Think
%
% Input:
% z        Elevation array or matrix, e.g., from gebco.m [m]
% tz       Test elevation array [m]
%
% Output:
% perc     Occlusion percentage
%
% Ex:
%    z = [-10 -5 0; -25 -15 -20; -10 0 -5]
%    tz = [0:-10:-30]
%    OCCLPERC(z, tz)
%
% See also: gebco.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 19-Mar-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

if ~isrow(tz)
    tz = tz';

end
z = z(:);
numz = sum(~isnan(z));
numo = sum(z > tz);
perc = 100 * (numo / numz);
