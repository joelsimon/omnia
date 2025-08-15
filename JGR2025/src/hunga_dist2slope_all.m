function hunga_dist2slope_all
% HUNGA_DIST2SLOPE_ALL
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 15-Aug-2025, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

gb = hunga_read_great_circle_gebco;
kstnm = fieldnames(gb);

for i = 1:length(kstnm)
    hunga_dist2slope(kstnm{i}, -1350, true)
    close

end






