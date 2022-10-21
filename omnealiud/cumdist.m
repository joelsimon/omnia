function cd = cumdist(lat, lon)
% cd = CUMDIST(lat, lon)
%
% Computes cumulative distances in degrees along path defined by latitude and
% longitude column vectors.  If lat/lon are matrices the columns are matched to
% form lat/lon paths.
%
% Input:
% lat        Latitudes along paths, defined by columns,
%                either as vector or matrix [deg]
% lon        Longitudes along paths, defined by columns,
%                either as vector or matrix [deg]
%
% Output:
% cd         Cumulative-distance matrix of equal size as lat/lon [deg]
%
% Ex: Cumulative distance along five paths
%    lat = randi(90, 5)
%    lon = randi(90, 5)
%    CUMDIST(lat, lon)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 20-Oct-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

if size(lat) ~= size(lon)
    error('Latitude and longitude arrays must be equal size')

end

% I'm sure there is a way to speedup via vectorize -> reshape...
cd = zeros(size(lat));
for i = 2:size(lat, 1)
    for j = 1:size(lat, 2)
        cd(i, j) = cd(i-1, j) + distance(lat(i-1, j), lon(i-1, j), lat(i, j), lon(i, j));

    end
end
