function baz = backazimuth(az)
% baz = BACKAZIMUTH(az)
%
% Returns back azimuth given an azimuth.
%
% Input:
% az      Azimuth in degrees from 0 -> 360
%
% Output:
% baz     Back azimuth in degrees from 0 -> 360
%
% Ex:
%     baz = BACKAZIMUTH([0:45:360])
%
% See also: az_baz
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 12-Mar-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

% Sanity.
if any(az<0) || any(az>360)
    error('Azimuths must be between [0:360], inclusive')

end

% https://www.nwcg.gov/course/ffm/location/63-back-azimuth-and-backsighting
% "A back azimuth is calculated by adding 180 [deg] to the azimuth when the
% azimuth is less than 180 [deg], or by subtracting 180 [deg] from the azimuth
% if it is more than 180 [deg]."
baz = zeros(size(az));
for i = 1:length(az)
    if az(i) < 180
        baz(i) = az(i) + 180;

    else
        baz(i) =  az(i) - 180;


    end
end
