function [z, idx] = hunga_zero_min(z, gc_idx)
% [z, idx] = HUNGA_ZERO_MIN(z, gc_idx)
%
% NB: This correctly sets all Fresnel-radii to zero before-slope using min. of
% great-circle because by construction the outer Fresnel tracks are NaN at
% start/end, meaning for outer tracks near full-width of Fresnel radii the
% minimum may not occur until much later into path (e.g., much after the slope).
% Further, okay to use great-circle index at MINIMUM (as is done here) because at
% the base of the slope you are definitely far enough forward of any occluders
% that may exist along slope that would possibly be counted for a Fresnel-track
% just off the great-circle path (e.g., gc_idx+/-1, which may have its min at
% index 293 instead of 294 for P0053; doesn't matter). TLDR; we don't want to
% set using min. of each Fresnel track.
%
% Set to NaN all elevation indices before minimum elevation, i.e., remove
% trench from bathymetric profiles for all stations west of HTHH.
%
% Input:
% z        Elevation matrix
% gc       Column index of great-circle path
%
% Output:
% z        Elevation matrix pre-slope indices set to NaN
% idx      Index of z set to NaN
%
% Ex:
%    fg = hunga_read_fresnelgrid_gebco('P0045', 2.5)
%    z_raw = fg.depth_m; gc_idx = fg.gcidx;
%    z_no_slope = HUNGA_ZERO_MIN(z_raw, fg.gcidx);
%    xl = [fg.gcdist_m(1) fg.gcdist_m(end)]; yl = [-8000 0];
%    subplot(2,1,1); plot(fg.gcdist_m, z_raw); xlim(xl); ylim(yl)
%    subplot(2,1,2); plot(fg.gcdist_m, z_no_slope); xlim(xl); ylim(yl)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 14-Oct-2024, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

% Find row index in great-circle path of minimum depth -- that signals when past
% trench.
[~, idx] = min(z(:, gc_idx));
z(1:idx, :) = NaN;
