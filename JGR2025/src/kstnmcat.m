function [stype, col] = kstnmcat(kstnm)
% [stype, col] = KSTNMCAT(kstnm)
%
% Return signal category, color (blue, black, gray) based on KSTNM.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 03-Oct-2024, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

C = catsac;
stype = C.(kstnm);
switch stype
  case 'A'
    col = 'blue';

  case 'B'
    col = 'black';

  case 'C'
    col = [0.6 0.6 0.6];

  otherwise
    error('unexpected signal type')

end
