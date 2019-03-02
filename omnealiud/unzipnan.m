function [xunzip, idx] = unzipnan(x)
% [xunzip, idx] = UNZIPNAN(x)
%
% UNZIPNAN removes all nonfinite values (+-Inf, NaN) from the input
% time series (or cell array) 'x' and returns the finite series and
% the indices that were removed.  zipnan.m does the inverse and puts
% NaNs back in original indices. Allows the avoidance of nanmean.m,
% nanvar.m etc. on time series where index matters (e.g., cpest.m).
%
% Input:
% x              Time series, accepts cells
%
% Outputs:
% xunzip         Time series with non-finite values removed
% idx            Indices of removed non-finite values
%
% Ex: (remove, but hold onto indices, of nonfinite values in x)
%    x = [1 2 3 NaN 4 -Inf Inf 5]
%    [xunzip,idx] = unzipnan(x)
%
% See also zipnan.m
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 12-Jul-2018, Version 2017b

%% Recursive.

if iscell(x)
    for i = 1:length(x)
        [xunzip{i}, idx{i}] = unzipnan(x{i});
    end
else
    xunzip = x(:);
    idx = find(~isfinite(xunzip));
    xunzip(idx) = [];
end
