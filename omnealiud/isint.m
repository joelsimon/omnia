function tf = isint(x)
% ISINT(x)
%
% Returns true if x is a real integer (mod(x,1) == 0; NOT x is of type integer--
% use isinteger.m for that).  Accepts arrays.
%
% Ex:
%    ISINT([1 3 4 5 .6 4.7 6])
%
% Ex2:
%    ISINT('hello world')
%
% See also: intstr.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 10-Oct-2018, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Numbers only.
if any(~isnumeric(x)) || any(isempty(x)) || any(~isfinite(x))
    tf = false;
    return

end

% Either 1 or 0 (true or false).
for i = 1:length(x)
    tf(i) = mod(x(i), 1) == 0;

end
