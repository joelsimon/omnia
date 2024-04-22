function rad = occlrad(z, tz)
% rad = OCCLRAD(z, tz)
%
% <placeholder: header coming>
%
% ...measured at each Fresnel radii, i.e., along each row of elevation matrix,
% meaning there is one occlusion value per point along the great-circle track.
%
% Input:
% z        Elevation (depth is negative) matrix with Fresnel "tracks"
%              as columns and Fresnel radii as rows [m]
% tz       Test elevation array [m]
%
% Output:
% rad      Normalized occlusion (0 is free space, 1 completely occluded) at
%              each Fresnel radius
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 22-Apr-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Loop over the rows (going down matrix, along Fresnel "tracks," inspecting each
% Fresnel radii).
for i = 1:size(z, 1)
    % The Fresnel radii are the rows of the elevation matrix.
    fr_rad = z(i, :);

    % Chop off any NaNs in this row (e.g., at source/reciever there may only be a
    % single finite elevation; all points are finite only near midpoint of
    % great-cricle path, where Fresnel radius is maximized).
    fr_rad = fr_rad(~isnan(fr_rad));

    % Occlusion vector is true when elevation is higher than test.
    occl = fr_rad > tz;

    % Normalize by finite (exlcuding NaNs) length of radius.
    rad(i) = sum(occl) / length(occl);

end
