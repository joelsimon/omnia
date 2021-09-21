function [kstnm, kinst] = osean2fdsn(osean)
% [kstnm, kinst] = OSEAN2FDSN(osean)
%
% Return the "generic name of recording instrument" (KINST), defined as the
% string which precedes the first hyphen in the Osean-defined names, and a
% five-character station name (KSTNM), zero-padded between the letter and number
% defining the unique MERMAID (if required) --
%
% 452.112-N-01:   kinst, kstnm = '452.112', 'N0001'
% 452.020-P-08:   kinst, kstnm = '452.020', 'P0008'
% 452.020-P-0050: kinst, kstnm = '452.020', 'P0050'
%
% See also: osean2kinstkstnm (shell), Dive.attach_kstnm_kinst (Python/automaid)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 21-Sep-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

osean = strsplit(osean, '-');
kinst = osean{1};
num_zeros = 5 - length([osean{2} osean{3}]);
kstnm = [osean{2} repmat('0', [1, num_zeros]) osean{3}];
