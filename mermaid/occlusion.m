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
% elev      Elevation profiles, as columns (either a vector or matrix)
%               (up is positive, so elevations within the ocean are negative)
% test_elev Elevation of interest, e.g., a MERMAID parking elevation
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
%    elev = [-2500 -2000 -1500; -2250 -1750 -1250; -2000 -1500 -1000]
%    test_elev = -1550
%    [perc, ncross] = OCCLUSION(elev, test_elev)
%
% Ex2: Path w/in water by third point; 2 of next 5 occluded, numbering one "hit"
%    elev = [-100 -200 -2000 -2500 -1000 -1000 -2000]'
%    test_elev = -1550
%    [perc, ncross] = OCCLUSION(elev, test_elev)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 27-Oct-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Elevation profiles (e.g. along Fresnel or great-circle tracks) as columns.
npts_elev = size(elev, 1);

% Occlusion matrix: 1 where elevation shallower than test elevation.
% I.e., direct path through water from source to receiver is occluded.
occl = elev > test_elev;

% Remove the first portion of the path that is within rock, if any.
% (elevation shallower than test elevation)
for j = 1:size(elev, 2)
    i = 1;

    % For every path (column), `i` is the first point actually within water (deeper
    % than test depth); update occlusion matrix to not count those initial points
    % as occluded.
    if occl(1, j)
        i = find(occl(:, j) == 0, 1);
        occl(1:i-1, j) = 0;

    end

    % Because we have to account for different lengths of the initial path
    % within rock we have to use a different divisor for the percentage of
    % the path occlusion, to only count the path once in the water column.
    if ~isempty(i)
        % Subtract 1 because `i` is the first point in water.
        npts_perc = npts_elev - (i-1);
        perc(1, j) = ( sum(occl(:, j)) / npts_perc ) * 100;

    else
        % If `i` is empty, all points within rock/elevation never deeper than test.
        perc(1, j) = NaN;

    end
end

% Compute number water-rock transition (`diff` returns for each column).  Okay
% to work on whole matrix because initial-path 1 flipped to 0 in occlusion matrix.
ncross = sum(diff(occl) == 1);
