function [lat, lon, lat_360, lon_360] = plateboundaries(left_lon)
% [lat, lon, lat_360, lon_360] = PLATEBOUNDARIES(left_lon)
%
% Return Earth's plate boundaries, contained in $IFILES/PLATES/plates.mtl.
%
% Input:
% left_lon            Longitude at left of map; longitude between [-180:0] (def: -180)
%
% Output:
% lat/lon            Latitude/longitude; longitude between [left_lon:360-left_lon]
% lat_360/lon_360    Latitude/longitude, longitude between [0:360]
%
% Ex:
% [lat, lon, lat_360, lon_360] = PLATEBOUNDARIES
% figure; plot(lon, lat, 'r'); xlim([-180 180]); ylim([-90 90]); box on
% figure; plot(lon_360, lat_360, 'b'); xlim([0 360]); ylim([-90 90]); box on
% [lat_neg20, lon_neg20] = PLATEBOUNDARIES(-20)
% figure; plot(lon_neg20, lat_neg20, 'k'); xlim([-20 340]); ylim([-90 90]); box on
% figure; hold on; plot(lon, lat, 'r'); plot(lon_neg20, lat_neg20, 'k'); plot(lon_360, lat_360, 'b')
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 10-Mar-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Wish list:
%
% *Average lat/lon around the longitude wrap so that the plate truly extended to
%  the edges of the map

% Default left edge at longitude: -180 degrees (180 W).
defval('left_lon', -180)
if left_lon < -180 || left_lon > 0
    error('Input must be between 0 and 180')

end

%% Lifted from '$OMNIA/notmycode/fjs/plotplates.m'
pathname = getenv('IFILES');
fid = fopen(fullfile(pathname, 'PLATES', 'plates.mtl'), 'r', 'b');
plates = fread(fid, [1692 2], 'uint16');
plates(plates == 0) = NaN;
plates = plates/100 - 90;
lon_360 = plates(:,1);
lat_360 = plates(:,2);
%% Lifted from '$OMNIA/notmycode/fjs/plotplates.m'

% Convert longitudes from 0:360 to -180:180.
lon = lon_360;
lat = lat_360;

% Rotate longitudes from 0:360 to -180:180, or some other custom rotation.
wrap_deg = 360+left_lon;
idx = find(lon > wrap_deg);
lon(idx) = lon(idx) - 360;

% Locate the indices where the rotation caused longitudes to wrap and slide
% NaNs between them to break up the lines.
wrap_idx = find(abs(diff(lon)) >= wrap_deg);
lon = zipnanshift(lon, wrap_idx, 'after');
lat = zipnanshift(lat, wrap_idx, 'after');

% Find and remove all occurrences where longitude goes [-, NaN, +], or [+, NaN, -]
% (crosses the Prime Meridian) because those are set as NaN on FJS' original
% 0-centered map and thus do not connect properly.  The following loop could(?)
% be accomplished more efficiently with `diff`, but I think preserving the
% indexing would be more complex, and this will be easier to read in a year.

rm_idx = [];
nan_idx = find(isnan(lon));
maxdiff = max(abs(diff(lon_360)));

for i = 1:length(nan_idx)
    nidx = nan_idx(i);

    % Collect values before / after the NaN longitude.
    if nidx ~= 1 && nidx ~= length(lon)
        left = lon(nidx-1);
        right = lon(nidx+1);

        % Remove the middle NaN if it there is a sign flip on either side of it,
        % signaling that the plate crosses 0 degrees and should connect.
        if (sign(left) ~= sign(right)) && abs(left-right) < maxdiff
            rm_idx = [rm_idx ; nidx];

        end
    end
end

lon(rm_idx) = [];
lat(rm_idx) = [];
