function [dbar, Pa] = depth2pressure(depth)
% [dbar, Pa] = DEPTH2PRESSURE(depth)
%
% DEPTH2PRESSURE returns a rough estimate of water pressure in the
% ocean at a given depth assuming
% 
%       1 m = 0.101 bar (1.01 dbar) = 1.01e4 Pa
%
% as is done in the MERMAID manual.
% 
% Input:
% depth        Water depth [m]
%
% Output:
% Pa           Water pressure [Pa]
% dbar         Water pressure [dbar]
%
% Ex: (approximate pressure at normal MERMAID parking depth)
%    [dbar, Pa] = DEPTH2PRESSURE(1500)
%
% See also: pressure2depth.m
% 
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 23-Aug-2018, Version 2017b

barr = depth * 0.101;
Pa = barr * 1e5;
dbar = barr * 10;
