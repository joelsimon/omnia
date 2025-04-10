function [kstnm, val, idx] = orderkstnm_occl(kstnm, tz, algo, crat, prev, los, tzfunc)
% [kstnm, val, idx] = ORDERKSTNM_OCCL(kstnm, tz, algo, crat, prev, los, tzfund)
%
% Input:
% kstnm    Cell array of five-character station names (def: all)
% tz       Test depth in meters (must be negative), or 'stdp' for individual
%              station depths
% algo     1: `occlfspl1`
%          2: `occlfspl2`
%          3: `occlperc`
%          4: `occlrad`
% crat     Clearance ratio, as input to `occlfspl*` and `occlrad`
%              (ignored for `occlperc`, or if `los=true`)
% prev     Require previous unoccluded to increment occlusion count,
%              for `occfspl*` (ignored for `occlperc`; def: false)
% los      true: only consider line-of-sight (LoS; great-circle path)
%          false: consider entire elevation matrix (def)
% tzfunc   1: `val` is mean algo across all depths (def)
%          2: `val` is sum algo across all depths
%
% Output:
% kstnm    Cell array of five-character station names, sorted by occlfspl.m value
% val      Output count from occlfspl.m, taken as sum or mean across all test depths
% idx      Indexing array s.t. kstnm_input(idx) = kstnm_output
%
% See also: occlfspl1, occlfspl2, occlperc, occlrad
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 25-Nov-2024, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

% Sanity
if any(tz > 0)
    error('Test elevations must be 0 or negative')

end

% Default to consider full elevation matrix.
defval('prev', false)
defval('los', false)
defval('tzfunc', 1);

% Default to use all stations.
gc = hunga_read_great_circle;
fnames = fieldnames(gc);
defval('kstnm', fnames);

% Define the occlusion-count algorithm.
switch algo
  case 1
    occl_func = @(aa, bb, cc, dd) occlfspl1(aa, bb, cc, dd)

  case 2
    occl_func = @(aa, bb, cc, dd) occlfspl2(aa, bb, cc, dd)

  case 3
    % cc, dd are dummy variables to maintain same input list-length as occlfspl*
    occl_func = @(aa, bb, cc, dd) occlperc(aa, bb, cc, dd)

    % All `crat`s the same: entire Fresnel zone considered for percentage
    % calculation; I never did, e.g., only consider 60% of Fresnel radii from
    % LoS (I don't think it's worth coding that because, (1) occlfspl* shows
    % us that more crat consider equals more better, and (2) occlfspl works
    % better anyway).
    warning('selected `occlperc` algo; crat=%.1f has no meaning\n', crat)

  case 4
    occl_func = @(aa, bb, cc, dd) occlrad(aa, bb, cc, dd)

  otherwise
    error('`algo` must be one of ''1'', ''2'', ''3'', or ''4''')

end

% Define how occlusion-counting algorithm will be summarized over all test
% depths (mean or sum).
switch tzfunc
  case 1
    val_func = @mean

  case 2
    val_func = @sum

  otherwise
    error('`tzfunc` must be either ''1'' or ''2''')

end

% Do initial sort by epicentral distance.
for i = 1:length(kstnm)
    dist(i) = gc.(kstnm{i}).tot_distkm;

end
[~, idx] = sort(dist);
dist = dist(idx);
kstnm = kstnm(idx);

% Initialize output
val = NaN(length(kstnm), 1);

% Loop over every station and compute occlusion value based on requested test depths.
for i = 1:length(kstnm)
    % (for now just?) Read 2.5 Hz Fresnel zone, the largest.
    fg = hunga_read_fresnelgrid_gebco(kstnm{i}, 2.5);

    % Remove indices before slope for western stations -- only count occlusion east
    % of slope (assumed T-wave conversion point).
    if contains(kstnm{i}, {'P0048' 'P0049' 'H11'});
        z = fg.depth_m;

    else
        z = hunga_zero_min(fg.depth_m, fg.gcidx);

    end

    % Maybe only consider great-circle path (line-of-sight, LoS; middle column of
    % the elevation matrix).
    if los
        % This is equivalent to feeding entire elevation matrix to `occlfspl*` with
        % `crat=0` (great-circle path must be unoccluded). BUT, `crat=0` has a
        % different meaning in `occlrad`, where there it's a fractional
        % occlusion per-radii, i.e., if you require 0 clearance than the entire
        % radius can be occluded (but it wouldn't be counted).  Thus, to be
        % safe, just set crat to 1.0 here for all cases.
        crat = 1.0;
        z = z(:, fg.gcidx);

    end

    % Per-depth counts.
    for j = 1:length(tz)
        ct(j) = occl_func(z, tz(j), crat, prev);

    end

    % Summarizing value across all depths, per float (either sum or mean).
    val(i) = val_func(ct);

end

% Order stations based on occlusion.
[~, idx] = sort(val);
kstnm = kstnm(idx);
val = val(idx);
