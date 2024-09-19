function perc = occlperc(z, tz, dummy) % see dummy* note below
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
% perc     Occlusion percentage at every test depth [m]
%
% Ex:
%    z = [-10 -5 0; -25 -15 -20; -10 0 -5]
%    tz = [0:-10:-30]'
%    OCCLPERC(z, tz)
%
% See also: occlfspl1, occfspl2
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 19-Sep-2024, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

% dummy note*: this variable is unused; here only to match input list-length
% of occlfspl*

fprintf('%s\n', mfilename)

% Must convert test depths to rows so that ">" comparison works as expected for matrix.
trow = true;
if ~isrow(tz)
    trow = false;
    tz = tz';

end

% Vectorize elevation matrix (slide next column to start where last ends).
z = z(:);

% Tally number of actual elevations (excluding NaNs).
numz = sum(~isnan(z));

% Tally number of elevations greater than the test elevation.  This works for
% arrays of `tz` because, "Arrays with compatible sizes are implicitly expanded
% to be the same size during execution of the calculation." (Essentially `z` is
% copied `tz`-number of times for us).
numo = sum(z > tz);

% The output percentage is just the number of elevations greater than the
% test elevations divided by the total number of non-NaN elevations.
perc = 100 * (numo / numz);

% Return output with same dimension as input test depth.
if ~trow
    perc = perc';

end
