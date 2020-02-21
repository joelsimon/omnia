function [mm, m] = nm2mm(nm)
% [mm, m] = NM2MM(nm)
%
% Converts nanometers to millimeters and meters.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 21-Feb-2020, Version 2017b on GLNXA64

mm = nm / 1e6;
m =  nm / 1e9;
