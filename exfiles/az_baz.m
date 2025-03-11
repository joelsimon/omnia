function az_baz(latA, lonA, latB, lonB)
% AZ_BAZ(latA, lonA, latB, lonB)
%
% Proves the (not intuitive to me, at least) result that, generally, the back
% azimuth calculated at point B, relative to an azimuth from B to A, is not the
% azimuth from A to B, calculated at point A.
%
% Input:
% latA,lonA     Latitude and longitude at point A
% latB,lonB     Latitude and longitude at point B
%
% Output:
% A printout of azimuths and back azimuths at points A and B
%
% Ex:
%    P0045_lat = -25.295;
%    P0045_lon = -165.846;
%    HTHH_lat = -20.546;
%    HTHH_lon = -175.390;
%    AZ_BAZ(HTHH_lat, HTHH_lon, P0045_lat, P0045_lon)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 11-Mar-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

% Compute on unit sphere so there's no funny business introduced by flattening.
ellipsoid = [1 0];

% azA_A2B => "Azimuth from A to B, computed at point A"
azA_A2B = azimuth(latA, lonA, latB, lonB, ellipsoid);
bazA_A2B = back_azimuth(azA_A2B);

azB_B2A = azimuth(latB, lonB, latA, lonA, ellipsoid);
bazB_B2A = back_azimuth(azB_B2A);

fprintf('     Azimuth, at A, for azimuth from A to B: %6.1f deg\n', azA_A2B)
fprintf('Back azimuth, at A, for azimuth from A to B: %6.1f deg\n\n', bazA_A2B)

fprintf('     Azimuth, at B, for azimuth from B to A: %6.1f deg\n', azB_B2A)
fprintf('Back azimuth, at B, for azimuth from B to A: %6.1f deg\n', bazB_B2A)

% https://www.nwcg.gov/course/ffm/location/63-back-azimuth-and-backsighting
% "A back azimuth is calculated by adding 180 [deg] to the azimuth when the
% azimuth is less than 180 [deg], or by subtracting 180 [deg] from the azimuth
% if it is more than 180 [deg]."
function baz = back_azimuth(az)
if az < 180
    baz = az + 180;

else
    baz = az - 180;

end
