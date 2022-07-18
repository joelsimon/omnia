function lon = longitude360(lon)
% lon = LONGITUDE360(lon)
%
% Converts longitude from [-180:+180] to [0:360] degree system.
%
% Input:
% lon      Longitude in [-180:+180] degree system
%
% Output:
% lon      Longitude in [0:360] degree system
%
% Example: (heading east from Prime Meridian)
%    LONGITUDE360(0)
%    LONGITUDE360(1)
%    LONGITUDE360(45)
%    LONGITUDE360(90)
%    LONGITUDE360(135)
%    LONGITUDE360(180)
%    LONGITUDE360(-135)
%    LONGITUDE360(-90)
%    LONGITUDE360(-45)
%    LONGITUDE360(-1)
%    LONGITUDE360(360)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 18-Jul-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

if lon < -180 || lon > 360
    error('Longitude must be within [-180:180], inclusive')

end

lon(find(lon < 0)) = lon(find(lon < 0)) + 360;
