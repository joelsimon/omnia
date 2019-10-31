function x = norm2ab(x, a, b)
% x = NORM2AB(x, a, b)
%
% NORM2AB normalizes x between the minimum and maximum values a and b,
% respectively. Nonfinite values are ignored.
%
% Input:
% x         1D array
% a         Minimum normalized value
% b         Maximum normalized value
%
% Output:
% x         Input, normalized between a and b
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 26-Nov-2018, Version 2017b

[x, idx] = unzipnan(x);
x = (b-a)*(x - min(x))/(max(x) - min(x)) + a;
x = zipnan(x, idx);
