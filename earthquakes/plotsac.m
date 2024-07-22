function [ax, x, h] = plotsac(sac, lohi, pt0)
% [ax, x, h] = PLOTSAC(sac, lohi, pt0)
%
% Make a QDP plot of a .SAC file.
%
% Input:
% sac         SAC filename
% lohi        1x2 array of low, high corner frequencies
%                 (for bandpass.m; def: [1 5])
% pt0          Time assigned to the first sample of x, in seconds
%                  (e.g., h.B in SAC header; def: 0)
%
% Output:
% ax          Axis handle
% x           SAC number vector (from readsac.m)
% h           SAC header structure array (from readsac.m)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 22-Jul-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('lohi', [1 5])
defval('pt0', 0)

[x, h] = readsac(sac);
x = bandpass(x, efes(h), lohi(1), lohi(2), 4, 1);
xax = xaxis(h.NPTS, h.DELTA, pt0);
ax = axes;
plot(ax, xax, x);
