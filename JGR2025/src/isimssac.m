function tf = isimssac(sac)
% ISIMSSAC(sac)
%
% ISIMSSAC returns true if SAC file is from IMS station H11 or H03
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 29-Jun-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

if startsWith(strippath(sac), 'H11') || startsWith(strippath(sac), 'H03')
    tf = true;

else
    tf = false;

end
