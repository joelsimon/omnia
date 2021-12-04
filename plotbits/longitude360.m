function lon = longitude360(lon)
% lon = LONGITUDE360(lon)
%
% Converts longitude from [-90:90] to [0:360] degree system.
%
% Input:
% lon      Longitude in [-90:90] degree system
%
% Output:
% lon      Longitude in [0:360] degree system
%
% Example:
%    LONGITUDE360(-90)
%    LONGITUDE360(-45)
%    LONGITUDE360(+45)
%    LONGITUDE360(+90)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 03-Dec-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

lon(find(lon < 0)) = lon(find(lon < 0)) + 360;
