function x = zipnanshift(x, idx, bora)
% x = ZIPNANSHIFT(x, idx, bora)
%
% Places NaNs at the specified index in 'x', with the appropriate shift.
%
% Difference with zipnan: zipnan assumes input 'idx' refers to original,
% unzipped time series 'x', not the indices of the input 'xunzip', which has had
% those indices removed.  Here, the input has NaN slide into the appropriate
% indices in 'x', plus whatever shift gets acquired along the way while sliding
% in those indices.  There is no shift in zipnan: those indices DO NOT refer to
% the input time series as they do here.
%
% ZIPNAN: put NaN in the indices of the OUTPUT x
% ZIPNANSHIFT: slide NaN either before or after the indices of the INPUT x
%
% Input:
% x         Time series or data vector
% idx       Indices in x slide NaN
% bora      'before' or 'after' to place NaN before or after x(idx)
%               (def: 'after')
%
% Output:
% x         x with NaNs applied in the positions of the x(idx),
%               plus the appropriate shift
%
% Ex1: (Ex. from zipnan.m: breaks because the INPUT x does not have indices 6 or 7)
%    x = [1 2 3 4]; idx = [4 6 7]
%    x = ZIPNANSHIFT(x, idx)
%
% Ex2: (this works because x has indices 2 and 3)
%    x = [1 2 3 4]; idx = [2 3]
%    x_after = ZIPNANSHIFT(x, idx, 'after')
%
% Ex3: (same as Ex2., but put NaNs before indices 2 and 3 in x)
%    x = [1 2 3 4]; idx = [2 3]
%    x_before = ZIPNANSHIFT(x, idx, 'before')
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 24-Mar-2020, Version 2017b on MACI64

defval('bora', 'after')

if max(idx) > length(x)
    error('NaN requested to be placed at index greater than length of input (nonexistent)')
end
if min(idx) < 1
    error('NaN requested to be placed at index less than 1 (nonexistent)')

end

rowit = isrow(x);
x = x(:);
count = 0;
for i = 1:length(idx)
    switch lower(bora)
      case 'after'
        x = [x(1:idx(i)+count) ; NaN ; x(idx(i)+1+count:length(x))];

      case 'before'
        x = [x(1:idx(i)+count-1) ; NaN ; x(idx(i)+count:length(x))];

      otherwise
        error('specify either ''before'' or ''after'' for input ''bora''')
    end
    count = count + 1;

end
if rowit
    x = x';

end
