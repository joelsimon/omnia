function val = sacfield(filename, field, endianness)
% val = SACFIELD(filename, field, endianness)
%
% Returns value of field in SAC header.
%
% Input:
% sac        SAC filename (not an actual parsed header struct)
% field      Single header fieldname, as parsed by `sachdr.m`
% endianness      'l': little-endian (default)
%                  'b': big-endian
%
% Output:
% val        Value of header field
%
% Ex:
%    SACFIELD('centcal.1.BHZ.SAC', 'KSTRNM')
%
% Author: Joel D. Simon <jdsimon@bathymetrix.com>
% Last modified: 13-Aug-2026, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

defval('endianness', 'l')
hdr = sachdr(filename, endianness);
val = hdr.(field);
