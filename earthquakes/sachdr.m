function  HdrData = sachdr(filename, endianness)
% HdrData = sachdr(filename, endianness)
%
% Wrapper for readsac.m that only returns header.
%
% Input:
% filename        SAC file name
% endianness      'l': little-endian (default)
%                 'b': big-endian
% Output:
% HdrData         The header structure array
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 17-Jan-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('endianness', 'l')
[~, HdrData] = readsac(filename, endianness, true);
