function str = underhyphen(str)
%
% Swap char '_' for '-' in (the former is interpretted as subscript in tex)
%
% Input:
% str      Char array or string
%
% Output:
% str      Char array or string with hyphens in place of underscores
%
% Ex:
%    UNDERHYPHEN('Hello_World!')
%    UNDERHYPHEN("Hello_World!")
%
% Author: Joel D. Simon
% Contact: jdsimon@bathymetrix.com | joeldsimon@gmail.com
% Last modified: 31-Oct-2025, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

str = strrep(str, '_', '-');
