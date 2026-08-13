function out = princeton_sac(sac)
% Returns true if SAC filename is a Princeton float (08-25).
%
% Author: Joel D. Simon <jdsimon@bathymetrix.com>
% Last modified: 13-Aug-2026, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

out = princeton_kstnm(sacfield(sac, 'KSTNM'));





