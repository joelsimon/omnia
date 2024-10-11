function rad = occlrad(z, tz, crat)
% rad = OCCLRAD(z, tz, crat)
%
% <placeholder: header coming>
%
% ...measured at each Fresnel radii, i.e., along each row of elevation matrix,
% meaning there is one occlusion value per point along the great-circle track.
%
% Unlike the other occl*.m scripts, which allow an array of test-depths, OCCLRAD
% only allows a single test depth because the output is returned as a raw array
% the same length as the number of Fresnel radii; i.e., the output is not
% further "summarized"...it simply returns the normalized cross-sectional
% occlusion at every Fresnel radii (perpendicular to great-circle path).
%
% Input:
% z        Elevation (depth is negative) matrix with Fresnel "tracks"
%              as columns and Fresnel radii as rows [m]
% tz       SINGLE test elevation [m]
% crat     ...<clearance ratio> (def: 0.6)
%
% Output:
% rad      Normalized occlusion (0 is free space, 1 completely occluded) at
%              each Fresnel radius
%
% Ex1: (shows how NaNs are treated; test depth is plane at -120 m)
%    z = [ NaN    NaN  -150   NaN   NaN
%          NaN   -150  -125  -150   NaN
%         -150   -125  -100  -125  -150
%          NaN   -150  -125  -150   NaN
%          NaN    NaN  -150   NaN   NaN];
%    tz = -120;
%    rad = OCCLRAD(z, tz)
%
% Ex2: (shows how contiguity matters; test depth is plane at -120 m)
%    z = [-150   -150  -150  -150  -150  -150  -150
%         -125   -125  -125  -100  -125  -125  -150
%         -100   -150  -150  -125  -150  -150  -150
%         -100   -100  -125  -150  -125  -100  -100
%         -125   -125  -150  -150  -125  -100  -100
%         -150   -150  -150  -150  -125  -125  -125];
%    tz = -120;
%    rad = OCCLRAD(z, tz);
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 25-Jul-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('crat', 0.6)

if length(tz) > 1
    error('Need to loop externally or refactor to make recursive for multiple test depth')

end

% Loop over the rows (going down matrix, along Fresnel "tracks," inspecting each
% Fresnel radii).
for i = 1:size(z, 1)
    % The Fresnel radii are the rows of the elevation matrix.
    fr_rad = z(i, :);

    % Skip calculation if all NaNs; e.g., a radii before the slope, removed as in
    % `zero_min=true`.
    if all(isnan(fr_rad))
        rad(i) = NaN;
        continue

    end

    % Chop off any NaNs in this row (e.g., at source/receiver there may only be a
    % single finite elevation; all points are finite only near midpoint of
    % great-circle path, where Fresnel radius is maximized).
    fr_rad = fr_rad(~isnan(fr_rad));

    % Occlusion vector is true when elevation is higher than test.
    occl = fr_rad > tz;

    % Normalize by finite (excluding NaNs) length of radius.
    rad(i) = sum(occl) / length(occl);

end

% In occlfspl* `crat` is a clearance ratio. Here, `orad` is an occlusion ratio
% (the complement; 60% clear is 40% occluded).
orat = 1 - crat;
rad = sum(rad > orat);
