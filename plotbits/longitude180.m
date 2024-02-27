function lon = longitude180(lon)
% lon = LONGITUDE180(lon)
%
% Convert longitude from [0:360] to [-180:+180] degree system.
%
% Works down columns if matrix input.
%
% Input:
% lon      Longitude in [0:360] degree system
%
% Output:
% lon      Longitude in [-180:+180] degree system
%
% Ex1: (heading east from Prime Meridian)
%    LONGITUDE180(0)
%    LONGITUDE180(1)
%    LONGITUDE180(45)
%    LONGITUDE180(90)
%    LONGITUDE180(135)
%    LONGITUDE180(180)
%    LONGITUDE180(225)
%    LONGITUDE180(270)
%    LONGITUDE180(315)
%    LONGITUDE180(359)
%    LONGITUDE180(360)
%
% Ex2: (matrix input)
%    lon = [0 45 90; 135 180 225; 270 315 360]
%    LONGITUDE180(lon)
%
% See also: longitude360
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 27-Feb-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

%% RECURSIVE.
if ~isvector(lon)
    % Work down each column in the case of an input matrix.

    %% (lazy) RECURSION.
    for i = 1:size(lon, 2)
        lon(:, i) = longitude180(lon(:, i));

    end
    return

end

if any(lon < 0) || any(lon > 360)
    error('Longitude must be within [0:360], inclusive')

end

lon(find(lon > 180)) = lon(find(lon > 180)) - 360;
