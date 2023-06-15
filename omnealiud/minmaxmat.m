function x = minmaxmat(mat)
% x = MINMAXMAT(mat)
%
% MINMAXMAT takes a single 2D matrix and returns the 1x2 value of min and max
% values, globally, of the matrix.
%
% Input:
% mat      Matrix
%
% Output:
% x        1x2 of global [min max] in mat
%
% Ex:
%    mat = randi(100, 3, 3)
%    MINMAXMAT(mat)
%
% See also: maxmat
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 15-Jun-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

x = [maxmat(mat, 'min') maxmat(mat, 'max')];
