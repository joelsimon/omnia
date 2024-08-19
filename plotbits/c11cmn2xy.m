function [x, y] = c11cmn2xy(c11, cmn)
% [x, y] = C11CMN2XY(c11, cmn)
%
% Covert top left, C(1,1), and bottom right, C(M, N), values (e.g., from
% `image`) to X-Y coordinates
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 19-Aug-2024, 24.1.0.2568132 (R2024a) Update 1 on MACA64

x = [c11(1), cmn(1)];
y = [c11(2), cmn(2)];
