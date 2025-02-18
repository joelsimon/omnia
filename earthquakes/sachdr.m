function  HdrData = sachdr(filename, endianness)
% HdrData = sachdr(filename, endianness)
%
% Wrapper for readsac.m that only returns header.
%
% Input:
% filename        SAC file name (or cell array)
% endianness      'l': little-endian (default)
%                 'b': big-endian
% Output:
% HdrData         The header structure array (or arrays, if filename is cell)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 18-Feb-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

% Default.
defval('endianness', 'l')

% Recursion.
if iscell(filename)
    for i = 1:length(filename)
        HdrData(i) = sachdr(filename{i}, endianness);
    end
    return
end

% Main.
[~, HdrData] = readsac(filename, endianness, true);
