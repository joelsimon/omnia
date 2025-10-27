function [ver, uver] = merver(sac)
% [ver, uver] = MERVER(sac)
%
% Return all and unique automaid versions given list of SAC files.
%
% Input:
% sac        Cell array of sac files
%
% Output:
% ver        Cell array of automaid versions
% uver       Unique automaid version numbers present in full list
%
% Author: Joel D. Simon
% Contact: jdsimon@bathymetrix.com | joeldsimon@gmail.com
% Last modified: 27-Oct-2025, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

% Keep legacy char ( {} ) not string ( () ) for `fullsac` compatibility
len_sac = length(sac);
ver = cell(len_sac, 1);
for i = 1:length(sac)
    h = sachdr(sac{i});
    ver{i} = h.KUSER0;

end
uver = unique(ver);
