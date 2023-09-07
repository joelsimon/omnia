function [dbar, Pa, mbar] = depth2pressure(depth)
% [dbar, Pa, mbar] = DEPTH2PRESSURE(depth)
%
% DEPTH2PRESSURE returns a rough estimate of water pressure in the
% ocean at a given depth assuming
%
%       1 m = 0.101 bar (1.01 dbar) = 1.01e4 Pa
%
% as is done in the MERMAID manual.
%
% NB: as of writing, automaid assumes 1 m = 1 dbar, no 1.01 dbar.
%
% Input:
% depth        Water depth [m]
%
% Output:
% Pa           Water pressure [Pa]
% dbar         Water pressure [dbar]
% mbar         Water pressure [mbar]
%
% Ex: (approximate pressure at normal MERMAID parking depth)
%    [dbar, Pa, mbar] = DEPTH2PRESSURE(1500)
%
% See also: pressure2depth.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 07-Sep-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

barr = depth * 0.101;
Pa = barr * 1e5;
dbar = barr * 10;
mbar = dbar * 100;
