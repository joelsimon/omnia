function [perc, ncross] = occlusion(elev, test_elev)
% [perc, ncross] = OCCLUSION(elev, test_elev)
%
% Compute elevation profile occlusion statistics.
%
% Envisioned to be used with GEBCO elevation(bathymetric) profiles and a test
% elevation to answer the questions:
% Along a constant-elevation path from source to receiver,
% * what percentage is occluded by seamounts, and
% * how many times is the path occluded (number of seamount "hits")?
% where occlusion is defined as a point where the elevation is
% greater(shallower) than the test elevation.*
%
% In reality this is an `isshallower` function abstracted for use with T waves.
%
% Input:
% elev      MULTIPLE elevation profiles, as columns (either a vector or matrix)
%               (up is positive, so elevations within the ocean are negative)
% test_elev SINGLE test elevation of interest, e.g., a MERMAID parking elevation
%               (up is positive, so elevations within the ocean are negative)
%
% Output:
% perc      Percentage of path that is occluded
% ncross    Number occlusions (seamount "hits") along path
%               (i.e., skinny/narrow and fat/wide seamount each count for 1 hit)
%
% * If elevation profile starts shallower than the test elevation, e.g., a
%  seismic source within rock, that is not counted in statistics; only
%  subsequent transitions from unoccluded to occluded (water to rock) are. This
%  is meaningful for hydroacoustic T waves that start life as seismic waves
%  within rock and convert to T waves in the water column.  I.e., it is
%  meaningless to discuss "occlusion" along the initial path from source to
%  water, before the T wave is generated. Statistics only computed for in-water
%  portion of path, so a path completely within rock (shallower than test depth,
%  see path 3 of example 1) is returned as NaN.
%
% Ex1: 1st path unoccluded; 2nd partially occluded; 3rd path completely w/in rock
%    elev = [-2500 -2000 -1500
%            -2250 -1750 -1250
%            -2000 -1500 -1000]
%    test_elev = -1550
%    [perc, ncross] = OCCLUSION(elev, test_elev)
%
% Ex2: Path w/in water by third point; 2 of next 5 occluded (40%), numbering one "hit"
%    elev = [ -100
%             -200
%            -2000
%            -2500
%            -1000
%            -1000
%            -2000]
%    test_elev = -1550
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 15-Mar-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 27-Oct-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Elevation profiles (e.g. along Fresnel or great-circle tracks), as columns.
npts_elev = size(elev, 1);

% Occlusion matrix: 1 where elevation shallower than test elevation.
% I.e., direct path through water from source to receiver is occluded.
occl = elev > test_elev;

% Loop over every column (elevation profile) and tally when test elevation is
% shallower than profile elevation.
for j = 1:size(elev, 2)
    % Occlusion matrix has 1 where test depth occluded, and 0 otherwise.
    % `i` is first point NOT occluded, after any initial occluded path
    if occl(1, j) == 0
        i = 1;

    else
        % If the first point is occluded (the test depth is deeper than the profile
        % elevation), update the occlusion matrix to force those first points as
        % not occluded (switch 1 to 0) so that we don't count the initial portion
        % of the path where the test depth is in hard rock (i.e., a volcano),
        % and update `i`, the first point to count from for statistics, as the
        % first point along the elevation profile where you are not occluded (in
        % the volcano example: out of hard rock and into ocean).
        i = find(occl(:, j) == 0, 1);
        occl(1:i-1, j) = 0;

    end

    % Because we have to account for different lengths removed from the start of the
    % total profile length to account for any initial path within rock we have
    % to use a different divisor for the percentage of the path occlusion, to
    % only count the path once in the water column.
    if ~isempty(i)
        % Tally the total count of occluded points along path.
        occl_count = sum(occl(:, j));

        % Tally the number of points considered along the path, excluding any initial
        % portion that transited hard rock (was occluded).
        path_length = length(i:npts_elev);

        % The occlusion percentage is just the tally of occluded points
        % divided by the length of the path under consideration (again,
        % excluding any initial occluded portion), multiplied by 100.
        perc(1, j) = ( occl_count / path_length ) * 100;

        % The occlusion "number of crossings" is just a count of the total number of
        % times the profile switches from not occluded (in water) to occluded
        % (slamming into a seamount).  The width of the occlusion does not
        % matter, thus we sum the number of `diffs` equaling positive 1
        % (switching from 0 to 1 in the occlusion matrix).
        ncross(1, j) = sum(diff(occl(:,j)) == 1);

    else
        % If `i` is empty all test elevations are deeper than the profile elevation
        % (said another way, the test elevation is within hard rock/occluded for
        % the entire length of the profile).  This is somewhat counter
        % intuitive, but it is because we swap 1 to 0 in occlusion matrix above
        % to account for any initial path within hard rock; if the test elevation
        % stays within hard rock for the entire path all 1s swap to 0.
        perc(1, j) = NaN;
        ncross(1, j) = NaN;

    end
end
