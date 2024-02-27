function lon = longitude360(lon)
% lon = LONGITUDE360(lon)
%
% Convert longitude from [-180:+180] to [0:360] degree system.
%
% NB: -180 is converted to 180; 360 is unattainable
%   LONGITUDE360(-180) == LONGITUDE360(180) % 180
%   LONGITUDE360(-0.1) == 359.9000
%   LONGITUDE360(0) == 0 % not 360
%   LONGITUDE360(0.1) == 0.1
%
% Input:
% lon      Longitude in [-180:+180] degree system
%
% Output:
% lon      Longitude in [0:360] degree system
%
% Ex: (heading east from Prime Meridian)
%    LONGITUDE360(+0)
%    LONGITUDE360(+1)
%    LONGITUDE360(+45)
%    LONGITUDE360(+90)
%    LONGITUDE360(+135)
%    LONGITUDE360(+180)
%    LONGITUDE360(-180)
%    LONGITUDE360(-135)
%    LONGITUDE360(-90)
%    LONGITUDE360(-45)
%    LONGITUDE360(-1)
%    LONGITUDE360(-0)
%
% See also: longitude180
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 20-Oct-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

%% RECURSIVE.
if ~isvector(lon)
    % Work down each column in the case of an input matrix.

    %% (lazy) RECURSION.
    for i = 1:size(lon, 2)
        lon(:, i) = longitude360(lon(:, i));

    end
    return

end

if any(lon < -180) || any(lon > 180)
    error('Longitude must be within [-180:180], inclusive')

end

lon(find(lon < 0)) = lon(find(lon < 0)) + 360;
