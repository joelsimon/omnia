function [idx, inbounds] = nearestidx(data, gofish)
% [idx, inbounds] = NEARESTIDX(data, gofish)
%
% NEARESTIDX finds the indices ('idx') of 'data' that minimize the
% absolute value of the difference between 'data' and the numbers
% ('gofish') requested, unless that number is not contained within the
% range of 'data'. Returns idx = 0 in out-of-range case. Only tested
% for 1D, real number arrays.
%
% Barring numerical error (see Ex3), NEARESTIDX returns the first
% index if multiple values in 'data' are the same distance from a
% 'gofish' value (see Ex2).
%
% Input:
% data        Data array
% gofish      Numbers to search for nearest match in data
%
% Output:
% idx         Indices in 'data' that contain values nearest to 'gofish'
% inbounds    Indices in 'gofish' that are in range of 'data'
%
% Ex1: (data(2) nearest to 4.1 and data(7) nearest to 78)
%    data = [1.1 4.2 7 9.8 14 56.7 80];
%    gofish = [-1 4.1 78 92];
%    [idx, inbounds] = NEARESTIDX(data, gofish)
%
% Ex2: (both 'data' values are 1 away from 'gofish', returns first)
%    [idx, inbounds] = NEARESTIDX([5  3], 4)
%
% Ex3: (numerical error says 4.1 closer to 4 than 3.9)
%    [idx, inbounds] = NEARESTIDX([3.9  4.1], 4)
%
% Documented pp. 29, 2017.1
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 21-Nov-2018, Version 2017b

iters = length(gofish);
idx = zeros(iters,1);
for i = 1:iters
    if min(data) <= gofish(i) & gofish(i) <= max(data)
        [~,idx(i)] = min(abs(data-gofish(i)));

    end
end
inbounds = find(idx~=0);
