function km = londeg2km(lat, deg)
% km = LONDEG2KM(lat, deg)
%
% Convert distance from longitude degrees to kilometers at a constant latitude.
%
% Input:
% lat     Degree of constant latitude [deg]
% deg     Degrees of longitude (east-west distance) [deg]
%
% Output:
% km      Distance spanned by degrees of longitude [km]
%
% Ex: (Distance of 1 degree of longitude from North Pole to equator)
%    LONDEG2KM([90 60 45 15 0]', 1)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 13-Mar-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('deg', 1)
km = deg2km(distance(lat, 0, lat, deg));
