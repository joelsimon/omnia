function [stdp, ocdp, kstnm] = hunga_average_depths(sigcat)
% [stdp, ocdp, kstnm] = HUNGA_AVERAGE_DEPTHS(sigcat)
%
% Returns station and (average along great-circle path only) ocean depth in
% down-is-positive meters (negative elevation).
%
% Input:
% sigcat  0: category A, B, and C signal (35 stations)
%         1: only category A and B signals (yes signal; 29 stations) [def]
%         2: only category C stations (no signal; 6 stations);
%
% Output:
% stdp   Depth to station, from sea surface in down-is-positive meters
% ocdp   Depth to average seafloor, from sea surface in down-is-positive meters
% kstnm  Stations considered
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 14-Jan-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

% Default.
defval('sigcat', 1)

% Get station-name list for given signal category.
kstnm = lskstnmcat(sigcat);

% Load the great-circle-path structure and dump stations not considered here.
gc = hunga_read_great_circle_gebco;
gc_kstnm = fieldnames(gc);
bad_kstnm = setdiff(gc_kstnm, kstnm);
gc = rmfield(gc, bad_kstnm);

% Collect depth data.
for i = 1:length(kstnm)
    % Collect station depth.
    stdp(i) = gc.(kstnm{i}).stdp;

    % Collect average ocean depth along great circle path.
    % If not P0048/H11*, remove from consideration bathy before trench.
    if contains(kstnm{i}, {'P0048' 'P0049' 'H11'});
        z = gc.(kstnm{i}).gebco_elev;

    else
        % For the great-circle, gc (as opposed to fresngel grid, fg) struct, the 1st
        % index is the great-circle path.
        z = hunga_zero_min(gc.(kstnm{i}).gebco_elev, 1);

    end
    % Average the great-circle-path bathymetry for each station.
    meanz(i) = nanmean(z);

end
stdp = stdp';

% Let's make ocean depth positive (down is positive, negative elevation).
ocdp = -meanz';
fprintf('%i stations considered\n', length(kstnm))
