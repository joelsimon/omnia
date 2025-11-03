function [data, time, loc, x, h, sd] = comparesac(sac1, sac2)
% [data, time, loc, x, h, sd] = COMPARESAC(sac1, sac2)
%
% Compare data, times, and station locations between two SAC files.
%
% Input:
% sac1,2     SAC files
%
% Output:
% data       true if data are equal
% time       [start end] time differences, in seconds
% loc        Station location difference in meters
% x          1x2 cell of data from sac1,2
% h          1x2 struct of headers from sac1,2
% sd         1x2 struct of `seistimes` from sac1,2
%
% Ex:
%    sac1 = '20180728T225619.06_5B773AE6.MER.REQ.WLT5.sac';
%    sac2 = '20180728T225619.06_5B773AE6.MER1.REQ.WLT5.sac';
%    [data, time, loc] = COMPARESAC(sac1, sac2)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 14-May-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

sac = {sac1 sac2};
for i = 1:2
    [x{i}, h(i)] = readsac(sac{i});
    sd(i) = seistime(h(i));

end

if isequal(x{1}, x{2});
    data = true;

else
    data = false;

end
time = seconds([sd(1).B - sd(2).B, sd(1).E - sd(2).E]);
loc = 1e3 * deg2km(distance(h(1).STLA, h(1).STLO, h(2).STLA, h(2).STLO));
