function [M1,M2] = parcpci(x, cptype, iters, alphas, algo, ...
                                 dtrnd, bias, dists, stdnorm, skip_alphas)
% [M1,M2] = PARCPCI(x, cptype, iters, alphas, algo, dtrnd, bias,...
%                   dists, stdnorm, skip_alphas)
%
% (Parallel) Changepoint Estimate Confidence Interval.
% 
% Parallel version of cpci.m that is automatically called when cpci.m
% is run on multiple wavelet scales.
%
% Inputs: 
% x,...,dists   Inputs to cpci.m, see there
% skip_alphas   logical true/false (automatically generated based
%                   on number of output arguments requested in cpci.m)
%
% Outputs:
% M1, M2        Outputs to cpci.m, see there
%
% See also: cpci.m, for.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 26-Jan-2018, Version 2017b

% Input argument 'skip_alphas' is automatically set to true in cpci.m
% if M1 is the only output requested.
if skip_alphas == true
    % Method 1 (sample error) only.
    for i = 1:length(x)
        M1(i) = cpci(x{i}, cptype, iters, alphas, algo, dtrnd, bias, ...
                     dists, stdnorm);

    end    
else
    % Execute both tests.
    for i = 1:length(x)
        [M1(i), M2(i)] = cpci(x{i}, cptype, iters, alphas, algo, ...
                              dtrnd, bias, stdnorm, dists);

    end
end
