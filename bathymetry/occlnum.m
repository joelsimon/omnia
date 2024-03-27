function num = occlnum(z, tz)
% num = OCCLNUM(z, tz)
%
% Count number of occluders along elevation profiles where occlusion is defined
% to be any elevation (`z`) that is higher (less deep) than a test elevation
% (`tz`).  Output is tallied along Fresnel "tracks" -- paths parallel to
% great-circle path -- as opposed to along perpendicular Fresnel radii.
%
% Occluders are tallied along columns of the elevation matrix `z`, which are
% depths along "Fresnel tracks" as output by fresnelgrid.m.  Occluder width is
% ignored; a seamount that occludes a single point or thousands of points is
% counted the same so long as the occluder is contiguously higher elevation
% than the test elevation.
%
% Fresnel tracks must be organized from source, z(*,1) to receiver, z(*,end),
% which is an important distinction considering how occluders are tallied within
% the code (from top to bottom where order matters, and with special
% consideration given to NaN elevations).  Along each tracks occlusion tallies
% only begin after reaching the first elevation along the profile lower than the
% test elevation (e.g., think about transiting from a seamount to the water
% column); see profile 2 in the example below.
%
% Input:
% z        Elevation (depth) matrix with elevation "tracks" as columns [m]
% tz       Test elevation array [m]
%
% Output:
% num      Number of occlusions per test depth
%
% Ex: one occluder prof. 1; three occluder prof. 2; total is four
%     z = [-5     0
%           0    -5
%           0     0
%           0   -10
%          -5     0
%         -10    -5
%          -5     0];
%     tz = -4;
%     plot(z); hold on; plot(get(gca, 'XLIM'), [tz tz], 'k--')
%     legend('elevation profile 1', 'elevation profile 2', 'test elevation')
%     OCCLNUM(z, tz)
%
% See also: fresnelgrid, gebco, occlperc
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 27-Mar-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

%% RECURSIVE.
% Loop over function for multiple test depths.
if length(tz) > 1
    for i = 1:length(tz)
        num(i) = occlnum(z, tz(i));

    end

    % Reshape output to same size as input and exit.
    num = reshape(num, size(tz));
    return

end
%% RECURSIVE.

% Create true/false matrix where elevation higher than test depth
% ("occluded").
y = z > tz;

% Initialize output count and loop over columns ("Fresnel tracks") of yes/no matrix.
num = 0;
for i = 1:size(y, 2)
    % The "Fresnel tracks" are the columns of the yes/no matrix.
    fr_track = y(:, i);

    % Chop off any NaNs in this Fresnel track that existed in the original elevation
    % matrix. A ">" comparison vs. a NaN is always false, meaning that a NaN at
    % the start of the path (e.g., you're out on the edges of the Fresnel grid)
    % will be 0 and then if the first non-NaN point is 1 that would later be
    % incorrectly counted as a flip from 0 to 1, or an occluder. When in fact
    % that track actually starts occluders and thus we do not want to start the
    % count there because the first actual point is in, e.g., hard rock (see
    % "idx" below).
    idxNaN = find(isnan(z(:, i)));
    fr_track(idxNaN) = [];

    % Find the first index in each column that is equal to 0 ("NOT occluded") and
    % start tally from there; don't want to start tallying if we are within a
    % rock layer at the start of the path, e.g., the slope -- wait until you've
    % passed into the water layer and are not occluded to begin tally.
    idx0 = find(fr_track == 0, 1);
    if isempty(idx0)
        % Move to next track if full path occluded / elevation never dips below test
        % elevation which means full path within rock layer.
        continue

    end

    % Sum all occurrences where true/false matrix diff is 1 (meaning passing from 0
    % to 1, or not occluded to occluded).  This properly counts single occluders
    % as 1, regardless of which (a skinny seamount or an entire continent),
    % because the diff of [1 1 1 1 1 .... 1 1 1] (a single occluder) is 0.
    num_track = sum(diff(fr_track(idx0:end)) == 1);
    num = num + num_track;

end
