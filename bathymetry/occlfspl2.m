function  [ct, lh_OCCL, rh_OCCL, ax] = occlfspl2(z, tz, crat, plt)
% [ct, lh_OCCL, rh_OCCL, ax] = OCCLFSPL2(z, tz, crat, plt)
%
% Occlusive Free-Space Path Loss -- 2-sided.
%
% Differs from `occlfsl` in that this requires clearance of 0.6 the Fresnel
% radial length as measured right/left (up/down) from the line of sight
% (great-circle path), as opposed to simply contiguous 0.6 Fresnel diameter
% window arranged at place within full Fresnel diameter. `occlfsl` will
% likely be sunsetted or renamed...
%
% Occlusion to left/right of great-circle path (line-of-sight) each add 0.5 to
% total count; both halves being occluded at a given radius sum to 1.0.
% Additionally, this mean a single occluder on great-circle path only add 1.0 to
% total count....which is kind of(?) unphysical.
%
% Define a clearance ratio below which you have free-space path loss --
% classically(? ; or at least implied...) this requires a clear path from
% line-of-sight to 0.6x the length of the radius (Bullington 1957, BELL SYST
% TECH J).  In their jargon this is H/H0.
%
% Inspired by: Bullington 1957, Bell Syst. Tech. J.)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 23-Aug-2024, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

if strcmp(z, 'demo');
    run_demo
    return

end

% Defaults
defval('crat', 0.6)
defval('plt', false)

% Sanity.
if length(tz) > 1
    error('Only 1 test depth allowed.')

end

% Expecting an odd number of Fresnel tracks, with the central track being the
% central path.
num_fr_tra = size(z, 2);
if iseven(num_fr_tra)
    error('Depth matrix must have odd number of columns, with central column representing great-circle path.')

end

% Get index of great-circle track (middle track).
gc_idx = mididx(1:num_fr_tra);

% Split Fresnel zone left/right (or, e.g., top/bottom) at great-circle path
% (line of sight).
lh_fr_rad = z(:, 1:gc_idx);
rh_fr_rad = z(:, gc_idx:end);

% Flip lh radii left-right so that line of sight is first column and
% max-extent of radii is last column.
lh_fr_rad = fliplr(lh_fr_rad);

lh_OCCL = main(lh_fr_rad, tz, crat);
rh_OCCL = main(rh_fr_rad, tz, crat);

ct = lh_OCCL.ct + rh_OCCL.ct;

% Verify radii symmetry
if ~isequaln(lh_OCCL.H0, rh_OCCL.H0)
    error('Left/right Fresnel-radii lengths not equal')

end

ax = [];
if plt
    ax = plotit(z, tz, crat, lh_OCCL, rh_OCCL);

end

%% ___________________________________________________________________________ %%

function OCCL = main(fr_radii, tz, crat)

% Fresnel radii (fish spines) are rows and "tracks" (parallel to great-circle
% path) are columns of elevation matrix.
num_fr_rad = size(fr_radii, 1);

% `prev_occl` specifies whether the previous radius (row) was occluded; only
% increment the counter if current radius occluded and previous was
% not.
prev_occl = false;

% Initialize outputs.
ct = 0;

occl_beg = [];
occl_end = [];

occl = NaN(num_fr_rad, 1);
H = NaN(num_fr_rad, 1);
H0 = NaN(num_fr_rad, 1);

% Loop over each Fresnel radius and look left/right (east/west or north/south
% etc.) from line of sight (middle great-circle index) and check clearance.
for i = 1:num_fr_rad
    % The Fresnel diameters are the rows of the elevation matrix.
    fr_rad = fr_radii(i, :);

    % Skip calculation if all NaNs; e.g., a radii before the slope, removed as in
    % `zero_min = true`.
    if all(isnan(fr_rad))
        continue

    end

    % Check if this specific radius is occluded.
    [occl(i), H(i), H0(i)] = is_occluded(fr_rad, tz, crat);

    if ~occl(i)
        % Neither radius occluded.
        if prev_occl
            % I previously occluded, set "end" occlusion index here
            % (transition out of seamount back into open ocean water).
            occl_end = [occl_end ; i];

        end
        % Set "previous" flag to unoccluded, for next loop.
        prev_occl = false;

    else
        % One/both radii occluded.
        if ~prev_occl
            % If previously unoccluded, increment occluder counter and set "begin" occlusion
            % index here (transition from open ocean water to seamount).
            ct = ct + 0.5;
            occl_beg = [occl_beg ; i];
            if i == num_fr_rad
                % If still occluded at end of path (how? MERMAID in seamount?...) just set
                % begin/end index equal consistency in array size.
                occl_end = [occl_end ; i];

            end
        end
        % Set "previous" flag to occluded, for next loop.
        prev_occl = true;

    end
end

OCCL.ct = ct;

OCCL.beg = occl_beg;
OCCL.end = occl_end;

OCCL.occl = occl;
OCCL.H = H;
OCCL.H0 = H0;

%% ___________________________________________________________________________ %%

function [occl, H, H0] = is_occluded(fr_rad, tz, crat)

% IS_OCCLUDED returns true if this specific Fresnel radius is occluded, as well
% as the index of the first occlusion (a length from line-of-sight heading along
% Fresnel radius toward edge of first Fresnel zone) and full Fresnel radial
% length.

% Chop off any NaNs in this radius (e.g., at source/receiver there may only be a
% single finite elevation; all points are finite only near midpoint of
% great-circle path, where Fresnel radius is maximized).
fr_rad = fr_rad(~isnan(fr_rad));

% Radial length of the first Fresnel zone at this point along the path --
% only compute this after chopping off NaNs. Using Bullington 1975 jargon for
% distances here.
H0 = length(fr_rad);

% Yes/no vector of "occluded or not" where occlusion is defined as
% elevation being greater than test depth (i.e., you ran into a seamount
% as opposed to transiting free-space [clear-path through water]).
occl_idx = fr_rad > tz;

% The clearance is defined as the distance from line-of-sight to first
% occluder (how far off great-circle path can you look east/west before
% bumping into an occluder).
H = find(occl_idx, 1);

% Default output occlusion is false.
occl = false;

% Exit with NaN (for indexing) if radius completely unoccluded.
if isempty(H)
    H = NaN;
    return

end

% If first occluder too close to line-of-sight (great-circle path), represented
% as a ratio of total length of Fresnel radius at this point along the great
% circle path, then this radius is considered occluded (suffering free-space
% path loss).
if H / H0 < crat
    occl = true;

end

%% ___________________________________________________________________________ %%

function ax = plotit(z, tz, crat, lh_OCCL, rh_OCCL)

num_fr_rad = size(z, 1);
num_fr_tra = size(z, 2);
gc_idx = mididx(1:num_fr_tra);

x = [1 num_fr_rad];
y = [+gc_idx -gc_idx];

figure
im = imagesc(x, y, z', 'AlphaData', ~isnan(z'));
ax = gca;
set(ax, 'YDir', 'normal')

caxis([tz-1 tz+1])
colormap(bluewhiteredcmap(3))
cb = colorbar;
cb.Ticks = [tz-1 tz tz+1];
cb.Label.String = 'Depth [m]';

hold(ax, 'on')
plot(ax.XLim, [0 0], 'k', 'LineWidth', 0.5);

% Annotate lhs (top half of image)
for i = 1:length(lh_OCCL.beg) % or lh_OCCL.end
    plot(ax, [lh_OCCL.beg(i) lh_OCCL.beg(i)], [0 ax.YLim(2)], 'w-', 'LineWidth', 1);
    plot(ax, [lh_OCCL.end(i) lh_OCCL.end(i)], [0 ax.YLim(2)], 'w--', 'LineWidth', 1);

end

% Annotate rhs (bottom half of image)
for i = 1:length(rh_OCCL.beg) % or rh_OCCL.end
    plot(ax, [rh_OCCL.beg(i) rh_OCCL.beg(i)], [0 ax.YLim(1)], 'w-', 'LineWidth', 1);
    plot(ax, [rh_OCCL.end(i) rh_OCCL.end(i)], [0 ax.YLim(1)], 'w--', 'LineWidth', 1);

end

min_free_radius = crat * lh_OCCL.H0; % or rh_OCCL.H0; isequal
plot(ax, +min_free_radius, 'k', 'LineWidth', 0.5);
plot(ax, -min_free_radius, 'k', 'LineWidth', 0.5);

%% ___________________________________________________________________________ %%

function [ct, OCCL] = run_demo

H11S1 = load('HTHH_2_H11S1_elevation_matrix.mat');
z = H11S1.z;
tz = -1000;
crat = 0.6;
[ct, OCCL] = occlfspl2(z, tz, crat, true);
