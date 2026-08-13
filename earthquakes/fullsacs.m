function [fsacs, excl] = fullsacs(sacs, diro)
% [fsacs, excl] = FULLSACS(sacs, dir)
%
% `fullsac`, but for a cell-array `sac` input
%
% Input:
% sacs     Cell array of no-path filenames
%
% Output:
% fsacs    Cell with fullpath filenames
% excl     Cell array of sacs not found in diro
%
% Author: Joel D. Simon <jdsimon@bathymetrix.com>
% Last modified: 13-Aug-2026, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

fsacs = fullsac([], diro);
[tf, loc] = ismember(sacs, strippath(fsacs));
fsacs = fsacs(loc(tf));
excl = sacs(~tf);
