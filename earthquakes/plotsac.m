function [ax, x, h] = plotsac(sac, lohi, pt0)
% [ax, x, h] = PLOTSAC(sac, lohi, pt0)
%
% Make a QDP plot of a .SAC file.
%
% Input:
% sac         SAC filename
% lohi        1x2 array of low, high corner frequencies
%                 (for bandpass.m; def: [1 5], use NaN for raw signal)
% pt0          Time assigned to the first sample of x, in seconds
%                  (e.g., h.B in SAC header; def: 0)
%
% Output:
% ax          Axis handle
% x           SAC number vector (from readsac.m)
% h           SAC header structure array (from readsac.m)
%
% Ex:
%    PLOTSAC('20180629T170731.06_5B3F1904.MER.DET.WLT5.sac')
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 22-Aug-2024, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

defval('lohi', [1 5])
defval('pt0', 0)

[x, h] = readsac(sac);
if ~isnan(lohi)
    x = bandpass(x, efes(h), lohi(1), lohi(2), 4, 1);
end
xax = xaxis(h.NPTS, h.DELTA, pt0);
ax = axes;
plot(ax, xax, x);
