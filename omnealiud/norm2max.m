function x = norm2max(x)
% x = NORM2MAX(x)
%
% Normalizes x to its maximum absolute value, thereby setting
% max(abs(x)) to either -1 or +1.  Ignores nonfinite values (NaNs,
% +/-inf). Literally just x = x/max(abs(x)).
%
% Inputs:
% x            1D vector
%
% Output:
% x            1D vector normalized to max(abs(x))
%
% Ex: (normalize a random time series to largest value)
%    x = cpgen; figure; plot(x); title('raw x'); shg
%    x = NORM2MAX(x); figure; plot(x); shg; title('normalized x')
%
% Last modified in Ver. 2017b by jdsimon@princeton.edu, 5-Feb-2018.

% unzip and zip to handle NaN, inf.
[x,idx] = unzipnan(x);
x = x / max(abs(x));
x = zipnan(x,idx);
