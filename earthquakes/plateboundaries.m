function [lat, lon, lat_360, lon_360] = plateboundaries
% [lat, lon, lat_360, lon_360] = PLATEBOUNDARIES
%
% Return Earth's plate boundaries, contained in $IFILES/PLATES/plates.mtl.
%
% Input:
% N/A
%
% Output:
% lat/lon            Latitude/longitude, latter being between -180:180 degrees
% lat_360/lon_360    Latitude/longitude, latter being between 0:360 degrees
%
% Ex:
% [lat, lon, lat_360, lon_360] = PLATEBOUNDARIES
% figure; plot(lon, lat); xlim([-180 180]); ylim([-90 90]); box on
% figure; plot(lon_360, lat_360); xlim([0 360]); ylim([-90 90]); box on
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 10-Mar-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Wish list:
%
% *Average lat/lon around the edges so that the lines truly extended to the
%  map edges of [-180 180] or [0 360]

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

idx = find(lon > 180);
lon(idx) = lon(idx) - 360;

% Find where the longitudes wrap by a large amount (screwing up plot) and
% insert NaNs between those breaks.
wrap = find(abs(diff(lon)) >= 180);
lon = zipnanshift(lon, wrap, 'after');
lat = zipnanshift(lat, wrap, 'after');

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

        % Remove them if there is a sign flip (crosses 0 degrees)
        if (sign(left) ~= sign(right)) && abs(left-right) < maxdiff
            rm_idx = [rm_idx ; nidx];

        end
    end
end

lon(rm_idx) = [];
lat(rm_idx) = [];
