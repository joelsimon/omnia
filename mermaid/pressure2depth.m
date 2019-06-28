function depth = pressure2depth(value, unit)
% depth = PRESSURE2DEPTH(value, unit)
%
% PRESSURE2DEPTH returns a rough estimate of water depth in the ocean
% at a given pressure (in either dbar or Pa) assuming
% 
%       1 m = 0.101 bar (1.01 dbar) = 1.01e4 Pa
%
% as is done in the MERMAID manual.
% 
% Input:
% value       Pressure in dbar or Pa
% unit        'dbar' or 'Pa' 
%
% Output:
% depth        Water depth [m]
%
% Ex: (MERMAID park depth from average pressure)
%    depth = PRESSURE2DEPTH(1515, 'dbar')
%    depth = PRESSURE2DEPTH(1515e4, 'Pa')
%
% See also: depth2pressure.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 27-Jun-2019, Version 2017b

switch lower(unit)
  case 'dbar'
    depth  = value  / 1.01;  
    
  case 'pa'
    depth = value / 1.01e4;
    
  otherwise
    error('Input either ''dbar'' or ''Pa'' for input: unit')

end 
