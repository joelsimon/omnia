function y = celldeal(x, zon);
% y = CELLDEAL(x, zon);
%
% Returns a cell array of NaNs, zeros, or ones, that is the same
% dimension as the input cell array.
%
% Input:
% x          A cell array
% zon        0: cell of zeros (default)
%            1: cell of ones
%            NaN: cell of NaNs 
%
% Output:
% y          Cell array of NaNs that is the same dimension as x
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 06-Jun-2018, Version 2017b

% Sanity.
assert(iscell(x), 'Must input cell array as first input argument')

% Default.
defval('zon', 0);

% Preprocess.
if isnan(zon)
    % NaN == NaN always fails so convert to string for switch below
    zon = 'NaN';
end

% Main.
switch zon
  case 0
    y = cellfun(@(z) zeros(size(z)), x, 'UniformOutput', false);
  case 1
    y = cellfun(@(z) ones(size(z)), x, 'UniformOutput', false);
  case 'NaN'
    y = cellfun(@(z) NaN(size(z)), x, 'UniformOutput', false);
  otherwise
    error('Input 0, 1 or NaN for second input argument.')
end
