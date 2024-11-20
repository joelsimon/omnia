function a = samedim(a, b)
% a = SAMEDIM(a, b)
%
% Returns a in the same dimension as b, for 1xN or Nx1 arrays.
% Useful for I/O in vectorized functions to keep dimension equal.
%
% Input:
% a      1xN or Nx1 array
% b      1xN or Nx1 array
%
% Output:
% a      a, transposed if required, to match dimesion of b
%
% Ex:
%    a = [1:5]
%    b = [6:10]'
%    a = SAMEDIM(a, b)
%    c = [11:15]'
%    d = [16:20]
%    c = SAMEDIM(c, d)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 20-Nov-2024, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

dima = size(a);
dimb = size(b);
if ~any(dima == 1)
    error('Input must be 1xN or Nx1 array')

end
if ~any(dimb == 1)
    error('Input must be 1xN or Nx1 array')

end
if ~isequal(dima, dimb)
    a = a';

end
