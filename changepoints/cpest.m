function [kw, km, aicx, weights] = cpest(x, algo, dtrnd, bias)
% [kw, km, aicx, weights] = CPEST(x, algo, dtrnd, bias)
%
% Changepoint Estimation via the Akaike Information Criterion.
%
% CPEST calculates an Akaike Information Criterion value for each
% sample, and estimates the changepoint(s) (e.g., arrival of seismic
% energy), for an input time series, 'x'.  At every sample CPEST
% splits 'x' into two segments and calculates a before-split and
% after-split AIC value assuming both segments are normally
% distributed.  aicx(k) is the sum of both the before-split and
% after-split AIC values at each sample.  The minimum, 'km', and
% weighted average, 'kw' are both estimates of the "best" split, (the
% changepoint) in the time series. Works in samples only.  km/w is
% rounded to the nearest sample.
%
% +- Inf AIC values are ignored and set to NaN.  These usually occur
% when at the edges were a sample variance equals 0 (AIC computation
% includes log(sample_var), and log(o) = -Inf)).
% 
% Input: 
% x             Time series, accepts 1D cells (e.g., 'd' from wt.m) 
% algo          'fast' or 'slow' algorithm (def: 'fast')
% dtrnd*        logical true to linearly detrend lhs & rhs
%                   (before-split segment & after-split segment) at
%                   each k, before calculating aicx (def: false)
% bias**        true to use BIASED estimate of sample variance (1/N) (def: true)
%               false to use UNBIASED estimate of the sample variance (1/N-1)
%                   
% Output:
% kw            Changepoint estimate: weighted average of Akaike weights
% km            Changepoint estimate: x index of AIC global minimum 
% aicx          Value of AIC function at each sample of input time series
% weights       Weight of AIC value at each sample of input time series
%
% * Two things: 
% (1) If dtrnd == true, 'algo' must be slow. 
% (2) No 'constant' option because we are working with variances and,
%     var(x) == var(x - mean(x))).
%
% ** bias = false: var(k) = 1/(length(k)-1)*sum((k-mean(k)).^2)
%    bias = true: var(k) = 1/length(k)*sum((k-mean(k)).^2)
%
% Citations:
% H. Akaike (1998), doi: 10.1007/978-1-4612-1694-0_15
% C. Li et al. (2009), doi: 10.1016/j.ultras.2008.05.005
% N. Maeda (1985), doi: 10.4294/zisin1948.38.3_365
% H. Zhang et al. (2003), doi: 10.1785/0120020241
%
% Example: CPEST('demo')
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 16-May-2018, Version 2017b

%% Recursive.

% Demo, maybe.
if ischar(x)
    demo
    return

end

% Defaults
defval('algo', 'fast')
defval('dtrnd', false)
defval('bias', true)

% Sanity checks: 
if all([~isnumeric(x) ~iscell(x)])
    error('Input ''x'' must be a numeric array or cell.')

end

if all(~strcmp(algo,{'slow' 'fast'}))
    error('Input ''algo'' must be either: ''fast'' or ''slow''.')

end

% cpvar.m does not (yet?) support indexed detrending.
if dtrnd && ~strcmp(algo, 'slow')
    error('dtrnd = true only works with ''slow'' algo.')

end

% End sanity.
%________________________________%


if iscell(x)
    % Preallocate output cell.
    aicx = cell(size(x));

    % Break up cell and run cpest.m on individual vectors.
    for i = 1:length(aicx)
        [kw(i), km(i), aicx{i}, weights{i}] = cpest(x{i}, algo, dtrnd, bias);

    end

else
    % Main function, after splitting up cell into vectors, maybe.

    % Remove all nonfinite values (e.g., details which see edge set to
    % NaN) for ease of calculation.  They will be slid back into their
    % proper index later with zipnan.m.
    x = x(:);
    [x, idx] = unzipnan(x);

    % Preallocate.
    N = length(x);
    aicx = NaN(size(x));

    % Calculate the aicx values.
    if strcmpi(algo, 'fast')
        % Fast calculation.

        % Fast calculation calls on cpvar.m to compute the cumulative
        % variance of the lhs/rhs segments at each k.
        [var_segment1, var_segment2] = cpvar(x, bias);
        k = [1:N]';

        % Akaike Information Criterion calculation.
        aicx = [k.*log(var_segment1) + (N-k).*log(var_segment2)];

    else
        % Slow calculation.
        
        % Use anonymous function to toggle between unbiased and biased
        % estimate of variance, var(x, [0 or 1]).
        if bias == true
            % biased estimate.
            sampvar = @(x)  var(x, 1);

        else
            % unbiased estimate.
            sampvar = @(x)  var(x, 0);            

        end

        for k = [2:N-2]
            % *** See note at bottom about loop indices.
            if dtrnd 
                %  To detrend: create a temp time series at every sample pretending
                % that's the true changepoint.  Note: detrend(x, dtype,
                % k) assumes a shared merge point, whereas aicx
                % assumes no shared samples.
                tmp = [detrend(x(1:k), 'linear')' detrend(x(k+1:end), 'linear')'];

                % Akaike Information Criterion calculation for the detrended series.
                %aicx(k) = k*log(var(tmp(1:k))) + (N-k)*log(var(tmp(k+1:N)));
                aicx(k) = k*log(sampvar(tmp(1:k))) + (N-k)*log(sampvar(tmp(k+1:N)));

            else
                % Akaike Information Criterion calculation for the raw input series.
                aicx(k) = k*log(sampvar(x(1:k))) + (N-k)*log(sampvar(x(k+1:N)));

            end
        end
    end
    % Slide any NaNs removed (above in unzipNaN) back into their proper index.
    if isempty(idx) == false
        aicx = zipnan(aicx, idx);

    end
    
    % Further, remove any +-Infs, if they exist and replace with NaNs.
    aicx(isinf(aicx)) = NaN;

    % One changepoint estimate: the minimum value of the AIC function
    [ykm, km] = min(aicx);

    % Ensure the minimum AIC value is not NaN (occurs when N is small, or
    % time series uniform and all variances 0). Because I set all
    % nonfinite values to NaN above, if the minimum is NaN the whole
    % time series is NaN.
    if isnan(ykm) 
        % There's nothing left to do. Undefined behavior. Exit with default.
        kw = NaN;
        km = NaN;
        weights = NaN(size(aicx));

    else
        % Update length of time series since it's been zipped back up.
        N = length(aicx);

        % Compute Akaike weights (equations 2-4 in li+2009).
        delta_k = aicx - ykm;
        numerator = exp(-delta_k./2);
        denominator = nansum(numerator);
        weights = numerator / denominator;
        weighted_ave = weights .* [1:N]';

        % Another changepoint estimate: the weighted average of the AIC function.
        kw = round(nansum(weighted_ave));

    end
end


% *** Unbiased variance: Loop from i=2, and not i=1, because var1 is
% undefined if k = 1 (denominator is 0; we use the unbiased estimate,
% which has N-1 degrees of freedom).  Stops at N-2 because at i=(N-1)
% and i=N var2 is undefined (the denominator in var2 would be 0 and
% -1, respectively).
%
% Biased variance: aicx(i) when i=1 or i=(N-1) is -Inf,
% because variance of segment1(1) = 0 and variance of
% segment2(N-1) = 0. These -inf values would be removed
% anyway so just skip them.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Demo.
function demo
    subplot(2, 1, 1);
    bp = randi([400,600], 1);
    x = cpgen(1000, bp, [], [], [], [], 1);
    vertline(bp);
    title(sprintf('changepoint at sample %i', bp))
    [kw, km, aicx] = cpest(x);
    subplot(2, 1, 2)
    plot(aicx, 'k');
    v1 = vertline(km);
    v2 = vertline(kw, [], 'b');
    legend([v1{1} v2{1}], {'AIC minimum', 'Weighted average'}, ...
           'AutoUpdate', 'off')
    title(sprintf(['Global min. estimates %i, AIC weights estimates ' ...
                   '%i'], km, kw))
    set(gca, 'TickDir', 'out')
    shg

