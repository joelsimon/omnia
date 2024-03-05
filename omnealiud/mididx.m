function [idx, val] = mididx(x)
% [idx, val] = MIDIDX(x)
%
% Return index(es) and value(s) of the middle of an array.
%
% Returns 1 value if array odd length (Ex1).
% Returns 2 values if array is even length (Ex2).
%
% Input:
% x       Array
%
% Output:
% idx     Index(es) of middle of array
% val     Value(s) at middle of array (x(idx))
%
%
% Ex1:
%    x = randi(10, 1, 5)
%    [idx, val] = MIDIDX(x)
%
% Ex2:
%    x = randi(10, 1, 6)
%    [idx, val] = MIDIDX(x)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 05-Mar-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

lx = length(x);
mid = lx/2;
if mod(lx, 2)
    % length(x) is odd
    idx = ceil(mid + 0.5);

else
    % length(x) is even
    idx = [mid mid+1];

end
val = x(idx);
