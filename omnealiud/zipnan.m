function x = zipnan(xunzip, idx)
% x = ZIPNAN(xunzip,idx)
%
% ZIPNAN is the inverse of unzipnan.m. Returns reconstructed x time
% series (or cell array) by sliding NaNs back into 'idx' indices.
%
% Inputs: (from unzipnan.m)
% xunzip        Unzipped time series
% idx           Indices of unzipped non-finite values
%
% Output:
% x             Reconstructed time series, with NaN at every idx
%
% Ex: (slide NaNs into indices 4,6,7 of x)
%    xunzip = [1 2 3 4]; idx = [4 6 7]
%    x = ZIPNAN(xunzip,idx)            
%    >> x = [1 2 3 NaN 4 NaN NaN 5]'
%
% See also: unzipnan.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 12-Jul-2018, Version 2017b

%% Recursive.

if iscell(xunzip)
    for i = 1:length(xunzip)
        x{i} = zipnan(xunzip{i}, idx{i});
    end
else
    xunzip = xunzip(:);
    idx = idx(:);
    nanspots = false(1, length(xunzip)+length(idx))';
    nanspots(idx) = true;
    x = NaN(size(nanspots));
    x(~nanspots) = xunzip;
end    
