function  [ct, OCCL] = occlfspl1(z, tz, crat, prev, plt, recursive_check) % private final var
% [ct, OCCL] = OCCLFSPL1(z, tz, crat, prev, plt)
%
% Occlusive Free-Space Path Loss: "One-Sided"
%
% If either Fresnel radius left/right (up/down) of LoS (great-circle path;
% middle column of depth matrix) is occluded, 1.0 is added to occlusion count.
%
% Input:
% tbd
% prev      true: require previously unoccluded to increment counter
%           false: tally each occluding radii, regardless of previous status (def)
%
% Output:
% tbd
%
% Inspired by: Bullington 1957, Bell Syst. Tech. J.)
%
% Ex:
%    OCCLFSPL1('demo')
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 25-Oct-2024, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

%% NB: Function recursively checks itself exactly once; private input
%% `recursive check` is defaulted to true and flipped to false in singular
%% recursion call.

% Demo it, maybe.
if strcmp(z, 'demo');
    run_demo
    return

end

% Defaults
defval('crat', 0.6)
defval('prev', false)
defval('plt', false)
defval('recursive_check', true)

% Sanity.
if length(tz) > 1
    error('Only 1 test depth allowed.')

end
if crat < 0 || crat > 1.0
    error('`crat` must be within 0:1, inclusive')

end

% Fresnel radii (fish spines) are rows and "tracks" (parallel to great-circle
% path) are columns of elevation matrix.  Expecting an odd number of Fresnel
% tracks, with the central track being the central path.
num_fr_rad = size(z, 1);
num_fr_tra = size(z, 2);
if iseven(num_fr_tra)
    error('Depth matrix must have odd number of columns, with central column representing great-circle path.')

end

% Get index of great-circle track (middle track).
gc_idx = mididx(1:num_fr_tra);

% Initialize outputs.
ct = 0;
occl_beg = [];
occl_end = [];
lh_occl = NaN(num_fr_rad, 1);
lh_H = NaN(num_fr_rad, 1);
lh_H0 = NaN(num_fr_rad, 1);
rh_occl = NaN(num_fr_rad, 1);
rh_H = NaN(num_fr_rad, 1);
rh_H0 = NaN(num_fr_rad, 1);

% `prev_occl` specifies whether the previous radius (row) was occluded; only
% increment the counter if current radius occluded and previous was
% not.
prev_occl = false;

% Loop over each Fresnel radius and look left/right (east/west or north/south
% etc.) from line of sight (middle great-circle index) and check clearance.
for i = 1:num_fr_rad
    % The Fresnel diameters are the rows of the elevation matrix.
    fr_diam = z(i, :);

    % Skip calculation if all NaNs; e.g., a radii before the slope, removed as in
    % `zero_min=true`.
    if all(isnan(fr_diam))
        continue

    end

    % Split full Fresnel diameter into two radii at great-circle path
    % (central track). For the left radius (from index 1 at far edge to
    % middle at great-circle track), index backwards from center so that you
    % start along line-of-sight and look toward edge of Fresnel zone.  These
    % "raw" radii include NaNs at the end -- if elevation matrix made with
    % `fresnelgrid` then only the middle diameter (have way between source
    % and receiver) can be filled with elevations; otherwise the edges of the
    % grid beyond the true length of the Fresnel radius at intermediate
    % distances is set to NaN.
    lh_rad_incl_nan = fr_diam(gc_idx:-1:1);
    rh_rad_incl_nan = fr_diam(gc_idx:end);

    % Going to check both radii (despite only requiring on to be occluded to
    % increment counter) to avoid an early exit via `continue`; also may want to
    % individually know right/left diffs at some point. "lh" = left hand;
    % "rh" = right hand (e.g., west/east or south/north).
    [lh_occl(i), lh_H(i), lh_H0(i)] = ...
        fresnelradius_occluded(lh_rad_incl_nan, tz, crat);
    [rh_occl(i), rh_H(i), rh_H0(i)] = ...
        fresnelradius_occluded(rh_rad_incl_nan, tz, crat);

    if ~prev
        if lh_occl(i) || rh_occl(i)
            ct = ct + 1;
            occl_beg = [occl_beg ; i];
            occl_end = [occl_end ; i];

        end
    else
        if ~lh_occl(i) && ~rh_occl(i)
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
                ct = ct + 1;
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
end

OCCL.ct = ct;
OCCL.beg = occl_beg;
OCCL.end = occl_end;

OCCL.lh_occl = lh_occl;
OCCL.lh_H = lh_H;
OCCL.lh_H0 = lh_H0;

OCCL.rh_occl = rh_occl;
OCCL.rh_H = rh_H;
OCCL.rh_H0 = rh_H0;

OCCL.gc_idx = gc_idx;

% Run verification -- left/right (west/east) radii-lengths should be equal.
if ~isequaln(OCCL.lh_H0, OCCL.rh_H0)
    error('Left/right (west/east) Fresnel radii lengths not equal')

end

if plt
    ax = plotit(z, tz, crat, OCCL);

end

% Verify swapping source/receiver produces same output.
if recursive_check
    reverse_z = flipud(z);
    plt = false;
    recursive_check = false;
    reverse_ct = occlfspl1(reverse_z, tz, crat, prev, plt, recursive_check);
    if ct ~= reverse_ct
        error('Swapping source-receiver produced different results')

    end
end

%% ___________________________________________________________________________ %%
function ax = plotit(z, tz, crat, OCCL)

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
for i = 1:OCCL.ct
    plot(ax, [OCCL.beg(i) OCCL.beg(i)], ax.YLim, 'w-', 'LineWidth', 1);
    plot(ax, [OCCL.end(i) OCCL.end(i)], ax.YLim, 'w--', 'LineWidth', 1);

end
min_free_radius = crat * OCCL.lh_H0;
plot(ax, +min_free_radius, 'k', 'LineWidth', 0.5);
plot(ax, -min_free_radius, 'k', 'LineWidth', 0.5);

%% ___________________________________________________________________________ %%

function [ct, OCCL] = run_demo

H11S1 = load('HTHH_2_H11S1_elevation_matrix.mat');
z = H11S1.z;
tz = -1385;
crat = 0.6;
prev = false;
[ct, OCCL] = occlfspl1(z, tz, crat, prev, true);
