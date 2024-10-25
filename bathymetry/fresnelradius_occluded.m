function [occl, H, H0] = fresnelradius_occluded(fr_rad, tz, crat)
% [occl, H, H0] = FRESNELRADIUS_OCCLUDED(fr_rad, tz, crat)
%
% FRESNELRADIUS_OCCLUDED returns true if the specific Fresnel radius input is
% occluded, as well as the index of the first occlusion (a length from
% line-of-sight heading along Fresnel radius toward edge of first Fresnel zone)
% and full Fresnel radial length.
%
% Input:
% fr_rad    Single Fresnel radius (1xN array)
% tz        Single test elevation, down (below sea level) is negative [m]
% crat      Requested clearance ratio, below which radius deemed occluded
%
% Output:
% occl      true if occluded (first occluder within requested clearance ratio)
% H         Actual clearance (distance to first occluder), or empty if clear path
% H0        Fresnel-zone radius
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 25-Oct-2024, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

% Sanity.
if crat < 0 || crat > 1
    error('Clearance ratio, `crat`, defined between 0 (LoS) and 1 (Fresnel radius)')

end

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

% Exit early on two-edge cases: entire radius completely (un)occluded
% (makes the ratio H/H0 break).
if all(occl_idx)
    occl = true;
    return

end
if isempty(H)
    occl = false;
    H = NaN; % reset to NaN for output indexing purposes
    return

end

% Exit early if crat = 0 (line-of-sight only consideration), and the first
% index in the radius (starts at great-circle and extends outward) is
% occluded.
if crat == 0 && H == 1
    occl = true;
    return

end

% If first occluder too close to line-of-sight (great-circle path), represented
% as a ratio of total length of Fresnel radius at this point along the great
% circle path, then this radius is considered occluded (suffering free-space
% path loss).
if H/H0 < crat
    occl = true;

else
    occl = false;

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
