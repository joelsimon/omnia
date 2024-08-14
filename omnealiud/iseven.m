function tf = iseven(x)
% ISEVEN(x)
%
% ISEVEN returns true if x is an even number.
%
% Ex:
%     ISEVEN([0 1 2 3 4 5])
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 13-Aug-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Some sanity checks would be good here...
tf = ~mod(x, 2);
