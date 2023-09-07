function depth = pressure2depth(value, unit)
% depth = PRESSURE2DEPTH(value, unit)
%
% PRESSURE2DEPTH returns a rough estimate of water depth in m in
% the ocean at a given pressure (in either dbar or Pa) assuming
%
%       1 m = 0.101 bar (1.01 dbar, or 101 mbar) = 1.01e4 Pa
%
% as is done in the MERMAID manual.
%
% NB: as of writing, automaid assumes 1 m = 1 dbar, no 1.01 dbar.
%
% Input:
% value       Pressure in dbar or Pa
% unit        'mbar', 'dbar' or 'Pa'
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
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 07-Sep-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

switch lower(unit)
  case 'mbar'
    depth  = value  / 101;

  case 'dbar'
    depth  = value  / 1.01;

  case 'pa'
    depth = value / 1.01e4;

  otherwise
    error('Input either ''dbar'' or ''Pa'' for input: unit')

end
