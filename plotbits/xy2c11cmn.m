function [c11, cmn] = xy2c11cmn(x, y)
% [c11, cmn] = XY2C11CMN(x, y)
%
% Covert X-Y coordinates to top left, C(1,1), and bottom right, C(M, N), values
% (e.g., for `image`).
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 19-Aug-2024, 24.1.0.2568132 (R2024a) Update 1 on MACA64

c11 = [x(1) y(1)];
cmn = [x(2) y(2)];
