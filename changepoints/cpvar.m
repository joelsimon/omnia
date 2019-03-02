function [var_segment1, var_segment2] = cpvar(x, bias)
% [var_segment1, var_segment2] = CPVAR(x, bias)
%
% Changepoint Variances.
%
% Given x(k), k = [1,...,N]: var_segment1(k) = var(1:k) 
%                            var_segment2(k) = var(k+1:end)
%
% CPVAR is a wrapper for cumstats.m that flips the right-hand side
% variance and advances its indexing by one, therefore returning the
% before-split (including k) and after-split (k+1 to end) variances of
% a time series using a notation useful for cpest.m, where at every k
% we are interested in the variances (1:k) and (k+1:N).  Includes
% option to return biased (1/N) or unbiased (1/N-1) sample variances.
%
% In the unbiased case (bias = false): Output argument 'var_segment2'
% ends in ONE NaN. The corresponds to the case when k = N, or the
% segment x(N+1:N), which is undefined. Also, var_segment1(1) = 0
% because the biased estimate of the variance of a single number is
% equal to 0, and, similarly var_segment2(N-1) = 0 because when k=N-1,
% var_segment2(k=N-1) = var(N:N), again, 1 number.
%
% In the unbiased case (bias = false): Output argument 'var_segment2'
% ends in TWO NaNs. The first NaN corresponds to when k = N-1.
% Segment two in that case goes from x(k+1:N) == x(N-1+1:N) == x(N:N).
% Because this returns the sample variance, a segment of length 1 is
% said to have an undefined variance.  The second NaN corresponds to
% the case when k = N, or the segment x(N+1:N), which is again
% undefined. See Ex4 below.
%
% CPVAR is prone to numerical error if variance is low (near 0) and
% sets any negative variances to 0.
%
% In the biased case (bias = true):
%
% Input:
% x              Time series, accepts 1D cells (e.g., 'd' from wt.m) 
% bias**         true to return biased estimate of sample variance (1/N) (def: false)
%                false to return unbiased estimate of the sample variance (1/N-1)
%
% Outputs:
% var_segment1(k)    The cumulative sample variance of segment one, x(1:k)
% var_segment2(k)    The cumulative sample variance of segment two, x(k+1:N) 
%
% ** bias = false: var(k) = 1/(length(k)-1)*sum((k-mean(k)).^2)
%    bias = true: var(k) = 1/length(k)*sum((k-mean(k)).^2)
%
% For example, x(k) = [1 2 3 4 5 6 7 8 9 10]
% If k = 2 (changepoint = 2):
% var_segment1(2) = var([1 2]), and 
% var_segment2(2) = var([3 4 5 6 7 8 9 10]).
%
% If k = 5 (changepoint = 5):
% var_segment1(5) = var([1 2 3 4 5]), and 
% var_segment2(5) = var([6 7 8 9 10]), and so on.
%
% Ex1: CPVAR('demo')
%
% Ex2: (random time series of length 12 compare at random split, k, unbiased)
%    x = randi(100, 1, 12) 
%    [var_segment1,var_segment2] = CPVAR(x, false);
%    k = randi(10)                  % assume random changepoint
%    var_segment1(k)                     % w/in error == var(x(1:k))
%    var_segment2(k)                     % w/in error == var(x(k+1:end))
%
% E4: (extreme case x is of length 2, biased)
%    x = [1:2]
%    [var_segment1,var_segment2] = CPVAR(x, true)
%    % var_segment1(1); at k = 1 is var(x(1:1))   = 0
%    % var_segment1(2); at k = 2 is var(x(1:2))   = 0.25
%    % var_segment2(1); at k = 1 is var(x(1+1:2)) = 0
%    % var_segment2(2); at k = 2 is var(x(2+1:2)) = NaN
%
% E4: (extreme case x is of length 2, unbiased)
%    x = [1:2]
%    [var_segment1,var_segment2] = CPVAR(x, false)
%    % var_segment1(1); at k = 1 is var(x(1:1))   = NaN
%    % var_segment1(2); at k = 2 is var(x(1:2))   = 0.5
%    % var_segment2(1); at k = 1 is var(x(1+1:2)) = NaN
%    % var_segment2(2); at k = 2 is var(x(2+1:2)) = NaN
%
% Ex5: (input is a cell, unbiased)
%    [~,x] = wt(cpgen);
%    [var_segment1, var_segment2] = cpvar(x, false);
%    % First segment: k = 88, scale = 3 vs. MATLAB's builtin var.m
%    var_segment1{3}(88) - var(x{3}(1:88))
%    % Second segment: k = 349, scale = 1 vs. MATLAB's builtin var.m.
%    var_segment2{1}(349) - var(x{1}(350:end))
%
%  See also: cumstats.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 15-Jan-2019, Version 2017b

%% Recursive. 

% Default.
defval('bias', false)

% Demo, maybe.
if ischar(x)
    demo
    return
end

% Break up cell and call recursively, maybe.
if iscell(x)
    for i = 1:length(x)
        [var_segment1{i}, var_segment2{i}] = cpvar(x{i}, bias);
    end
else    
    if ~isempty(x)
        % This is just a wrapper for cumstats.m.  The variance of segment 1 is
        % returned correctly already.
        [~, ~, ~, ~, var_segment1, var_from_right] = cumstats(x, bias);
        
        %% Main
        % To get the variance of segment 2 we must flip var_from_right, since
        % it starts at the end of x and works backwards.  Calling different
        % variable as opposed to overwriting to make clear.
        var_segment2 = flip(var_from_right);

        % Advance the indexing by 1 (by removing the first index) so that the
        % index k represents the changepoint, meaning segment 1 includes the
        % changepoint, segment 2 does not (it starts at k + 1).
        var_segment2(1) = [];

        % Lastly we want variances to be the same length, so add a NaN to the
        % end of var_segment2.
        var_segment2 = [var_segment2 ; NaN];
        %% End main.

    else
        var_segment1 = NaN;
        var_segment2 = NaN;

    end
end


% Demo.
function demo
    % Compares a the estimate of the sample variance returned here at a
    % random index with the (unbiased) variance estimate using MATLAB's
    % builtin var.m.
    lx = randi(1e6);
    x = rand(lx, 1);
    [var_segment1, var_segment2] = cpvar(x, false);
    k = randi(lx - 2); % var_segment2(k) is NaN for last two indices.
    fprintf(['For this example length(x) = %i and the changepoint ' ...
             '(k) is %i.\n'], lx, k);
    
    % Compare this output with MATLAB's builtin for var.m segment 1.
    if eq(var_segment1(k), var(x(1:k)))
        fprintf(['unbiased var_segment1(%i) and var(x(1:%i)) are ' ...
                 'exactly equal.\n'], k, k);
    else
        fprintf('Difference: var_segment1(%i) - var(1:%i)  = %e\n', ...
                k, k, var_segment1(k) - var(x(1:k)));
    end

    % Compare this output with MATLAB's builtin var.m for segment 2.
    if eq(var_segment2(k), var(x(k+1:end)))
        fprintf(['unbiased  var_segment2(%i) and var(x(%i+1:end)) ' ...
                 'are exactly equal.\n'], k, k);
    else
        fprintf('Difference: var_segment2(%i) - var(%i+1:end)  = %e\n', k, k, ...
                var_segment2(k) - var(x(k+1:end)));
    end

