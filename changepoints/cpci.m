function [M1, M2] = cpci(x, cptype, iters, alphas, algo, dtrnd, bias, ...
                         dists, stdnorm)
% [M1, M2] = CPCI(x, cptype, iters, alphas, algo, dtrnd, bias,
%                 dists, stdnorm)
%
% Changepoint Estimate Confidence Interval of simon??
%
% Computes confidence intervals for a single cpest.m changepoint
% estimate ('kw' or 'km') via Method 1 (sample errors) & Method 2
% (alpha hypothesis tests). M2 is much more computationally expensive;
% if only 1 output (M1) requested code is much faster.
%
% Inputs:
% x             The time series (double or cell)
% cptype        Changepoint to test, 'km' or 'kw' (def: 'kw')
% iters         Number of test iterations (def: 100)
% alphas        Alpha levels (percentages) to test (def: [0:100])
% algo,...,bias Input to cpest.m, see there (def: 'fast', false, true)
% dists         Cell of dist names of noise/signal (def: {'norm' norm'})
% stdnorm       Use N(0,1) for "noise" and N(0,sqrt(SNR)) for
%                   "signal" in synthseis.m (def: false)
%
% Outputs:
% M1            Struct of Method 1 (sample error) collection with fields:
% .ave              Mean sample error after all tests
% .onestd           1 std. dev. of the sample errors after all tests (biased: 1/N)
% .twostd           2 std. dev. of the sample errors after all tests (biased: 1/N)
% .raw              Raw sample error of each test
%
% M2            Struct of Method 2 (alpha tests) collection with fields:
% .restricted       Contiguity enforced: waterlvlalpha(restrikt = true)
% .unrestricted     Contiguity not enforced: waterlvlalpha(restrikt = false)
%      Each with subfields:
%      .six8        Average sample spread when null hypothesis is
%                       rejected 68% of the time
%      .nine5       Average sample spread when null hypothesis is
%                       rejected 95% of the time
%      .h1          Percentage of time null hypothesis rejected at
%                       each alpha lvl tested
%      .span        Average sample spread at each alpha lvl tested
%
% See also: cpest.m, changepoint.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 02-Nov-2019, Version 2017b on GLNXA64

%% Recursive.

% Defaults.
defval('cptype', 'kw')
defval('alphas', [0:100])
defval('iters', 100)
defval('algo', 'fast')
defval('dtrnd', false)
defval('bias', true)
defval('dists', {'norm' 'norm'})
defval('stdnorm', false)

% Sanity.
if ~isint(iters)
    erorr('Input argument ''iters'' must be an integer')

end

% Ignore case.
cptype = lower(cptype);

% Are both test outputs requested?  If not, skip the second more
% expensive test (M2).
if nargout == 1
    skip_alphas = true;

else
    skip_alphas = false;

end

% Compute across multiple scales (e.g., acting on the details after a
% wavelet transform, wt.m)?
if iscell(x)

    %% Recursive.

    for i = 1:length(x)
        [M1(i), M2(i)] = cpci(x{i}, cptype, iters, alphas, algo, dtrnd, ...
                              bias, dists, stdnorm);

    end
    return

end

% Which changepoint estimator is being used?
switch cptype
  case 'kw'
    true_cp = cpest(x, algo, dtrnd);

  case 'km'
    [~, true_cp] = cpest(x, algo, dtrnd);

  otherwise
    error('Unrecognized ''cptype''. Supply ''km'' or ''kw''.')

end

% Initialize outputs.
M1.raw = zeros(1, length(iters));
M1.ave = NaN;
M1.onestd = NaN;
M1.twostd = NaN;

% Don't bother generating M2 struct unless alpha tests requested.
if ~skip_alphas
    M2.restricted.h1 = zeros(1,length(alphas));
    M2.restricted.span =  M2.restricted.h1;
    M2.restricted.six8 = NaN;
    M2.restricted.nine5 = NaN;

    M2.unrestricted.h1 = M2.restricted.h1;
    M2.unrestricted.span = M2.restricted.h1;
    M2.unrestricted.six8 = NaN;
    M2.unrestricted.nine5 = NaN;

end

% Run cpest 'iters' number of times, collect error of changepoint estimates.
for i = 1:iters
    % Generate a synthetic time series.
    synth = synthseis(x, true_cp, dists, false, dtrnd, bias, stdnorm);

    % Find the changepoint of the synthetic.
    switch cptype
      case 'kw'
        [est_cp, ~, aicx] = cpest(synth, algo, dtrnd);

      case 'km'
        [~, est_cp, aicx] = cpest(synth, algo, dtrnd);

    end

    %% Crunch the numbers.
    % Method 1: sample error distance.
    M1.raw(i) = est_cp - true_cp;

    % Skip the alpha tests at every iteration if alphas tests not requested.
    if skip_alphas
        continue

    else
        % Method 2: beta hypothesis tests.  Question: is cp (truth) within the
        % spread at or below the waterlvl?  The null hypothesis
        % (h_0) states the truth DOES NOT lie at or below the
        % waterlvl.
        for j = 1:length(alphas)
            % Note waterlvls, not waterlvl (extra 's' in
            % former) to perform both contiguity tests concurrently.
            [xl_unrestricted(j), xr_unrestricted(j), xl_restricted(j), ...
             xr_restricted(j)] = waterlvlsalpha(aicx, alphas(j), est_cp);

        end
        % Keep track of the sample spread; I want to know how an alpha
        % corresponds to a sample spread. Add 1 to x(right) -
        % x(left) because if they are the same sample the test
        % sees 1 sample, not zero samples.
        M2.unrestricted.span = ...
            M2.unrestricted.span + (xr_unrestricted - xl_unrestricted + 1);
        M2.restricted.span = ...
            M2.restricted.span + (xr_restricted - xl_restricted + 1);

        % Is truth within span returned by waterlvl?  If so, reject
        % the null hypothesis add +1 to the total count of rejections
        % (alternative hypothesis, h_1, accepted).
        M2.unrestricted.h1 = M2.unrestricted.h1 + ...
            (xl_unrestricted <= true_cp & true_cp <= xr_unrestricted);
        M2.restricted.h1 = M2.restricted.h1 + ...
            (xl_restricted <= true_cp & true_cp <= xr_restricted);

    end
end

%% Summarize.
% Method 1.
M1.ave = nanmean(M1.raw);
if bias
    M1.onestd = nanstd(M1.raw, 1);

else
    M1.onestd = nanstd(M1.raw, 0);

end
M1.twostd = 2 * M1.onestd;

% Skip the alpha summary if not requested; exit the function.
if skip_alphas
    return

else
    % Method 2.
    % Average spread of samples spanned by each alpha test.
    M2.restricted.span = M2.restricted.span ./ iters;
    M2.unrestricted.span = M2.unrestricted.span ./ iters;

    % Percentage of times null hypothesis rejected.
    M2.restricted.h1 = (M2.restricted.h1 ./ iters) * 100;
    M2.unrestricted.h1 = (M2.unrestricted.h1 ./ iters) * 100;

    % Find the alpha lvls where the null hypothesis was rejected 68% and
    % 95% of the time.
    [sigma_indexR, sigma_existR] = nearestidx(M2.restricted.h1, [68 95]);

    % Loop over the sigma indices that exist. sigma_exist = 1 refers to
    % the first percentage (68%); sigma_exist = 2 is 95%.  See
    % second output of nearestidx.m for more.
    m2_fields = {'six8' 'nine5'};
    if ~isempty(sigma_existR)
        for ii = sigma_existR'
            M2.restricted.(m2_fields{ii}) = ...
                M2.restricted.span(sigma_indexR(ii));

        end
    end

    % Repeat for unrestricted test case.
    [sigma_indexUR, sigma_existUR] = nearestidx(M2.unrestricted.h1, ...
                                                [68 95]);
    if ~isempty(sigma_existUR)
        for jj = sigma_existUR'
            M2.unrestricted.(m2_fields{jj}) = ...
                M2.unrestricted.span(sigma_indexUR(jj));

        end
    end
end

% Cleanup output.
M1 = orderfields(M1, {'ave' 'onestd' 'twostd' 'raw'});
if ~skip_alphas
    M2.restricted  = orderfields(M2.restricted, {'six8' 'nine5' ...
                        'h1' 'span'});
    M2.unrestricted  = orderfields(M2.unrestricted, {'six8' ...
                        'nine5' 'h1' 'span'});

end
