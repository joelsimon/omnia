function d = hunga_shallowest_depth(kstnm, freq)
% d = HUNGA_SHALLOWEST_DEPTH(kstnm, freq)
%
% Return shallowest depth, in meters positive down, within `fresnelgrid` from
% HTHH to receiver, excluding any portion of the path pre-trench (removed with
% `hunga_zero_min`).
%
% Input:
% kstnm    5-char station name
% freq     Frequency used in `fresnelgrid`, one of 2.5, 5.0, 7.5, or 10 [Hz]
%
% Output:
% d        Shallowest depth in meters positive down
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 26-Mar-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

fg = hunga_read_fresnelgrid_gebco(kstnm, freq);
z = hunga_zero_min(fg.depth_m, fg.gcidx);
d = -maxmat(z);
