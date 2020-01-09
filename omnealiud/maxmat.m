function [val, row, col] = maxmat(mat, mima)
% [val, row, col] = MAXMAT(mat, mima)
%
% MAXMAT returns the maximum (or minimum) index(ices) and value(s) of
% an input 2D matrix.  Outputs 'row' and 'col' are the M x N pairs of
% indices in 'mat' that each contain the maximum (or minimum) value,
% 'val.'
%
% Input:
% mat        Matrix
% mima       'Max' or 'Min' (def: 'Max')
%
% Output:
% val        Max. (or min.) value of matrix
% row        Row index(ices) of max. (or min.) value(s)
% col        Column index(ices) of max. (or min.) value(s)
%
%
% Ex:
%    mat = randi(5, [3, 3])
%    [max_val, max_row, max_col] = MAXMAT(mat, 'Max')
%    [min_val, min_row, min_col] = MAXMAT(mat, 'Min')
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 27-May-2019, Version 2017b

% Default.
defval('mima', 'Max')

% Switch anon. function for max. or min.
switch lower(mima)
  case 'max'
    func = @max;
      
  case 'min'
    func = @min;

  otherwise
    error('Specify either ''Max'' or ''Min'' for input: ''mima''')

end

val = func(func(mat));
[row, col] = find(mat == val);
