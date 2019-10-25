function [km, sumly, dvar, rvar] = cpsumly(x, verify)
% [km, sumly, dvar, rvar] = CPSUMLY(x, verify)
%
% Changepoint Estimator via Summed Log-Likelihoods:
%
% Using the notation equation numbers of Simon+2019: At every sample
% index, k = [1,...,N], CPSUMLY splits 'x' into an assumed "noise"
% segment [x(1:k)], and an assumed "signal" segment [x(k+1:end)].  At
% each split it computes the log-likelihood of both segments assuming:
% each is i.i.d and drawn from a Gaussian distribution, and the sample
% variances are the true population variances (evaluated: equations 8
% and 13 for the "noise" and "signal", respectively).  It then sums
% both log-likelihoods at every sample to build a summed
% log-likelihood curve (equation 15).
%
% Input:
% x         Time series, e.g. a seismogram
% verify    logical true to check math (def: false)
%              i.e., that final sumly follow from its constituents
%
% Outputs:
% km        Sample index, k, which maximizes the summed likelihood function
%               (compare with km in cpest.m, which is the minimum
%               of an AIC curve)
% sumly     Eq. 15: summed log-likelihood curve of "noise" +
%               "signal" model at each k
% dvar      The difference between estimated (data) signal and noise
%               variances, sigma_2^2 - sigma_1^2
% rvar      The ratio of the estimated (data) signal and noise
%               variances, sigma_2^2 / sigma_1^2
%
% Ex: (true changepoint at sample index 5000)
%    x = normcpgen(1000, 500, 100);
%    [km, sumly] = CPSUMLY(x, true);
%    plot(norm2ab(x, -1, 1), 'k'); hold on
%    plot(norm2ab(sumly, -1, 1), 'm');
%    plot([km km], get(gca, 'YLim'));
%    legend('time series', 'summed log-likelihood', ...
%           'max. summed log-likelihood')
%
% Citation: ??
%
% See also: cpest.m, normly.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 25-Oct-2019, Version 2017b on GLNXA64

%% Recursive.

% Set verify to true check the math here, specifically that equation
% 15 is the sum of its constituents.
defval('verify', false)

% Sanity.
if all([~isnumeric(x) ~iscell(x)])
    error('Input ''x'' must be a numeric array or cell.')

end

if iscell(x)
    % Preallocate output cell.
    sumly = cell(size(x));

    % Break up cell and run cpsumly.m on individual vectors.
    for i = 1:length(sumly)

        %% Recursion.

        [km(i), sumly{i}] = cpsumly(x{i}, verify);

    end

else
    % Remove all nonfinite values (e.g., details which see edge set to
    % NaN) for ease of calculation.
    x = x(:);
    [x, idx] = unzipnan(x);

    % Preallocate.
    N = length(x);
    sumly = NaN(size(x));
    dvar = NaN(size(x));
    rvar = NaN(size(x));

    % If verifying, stop at random sample index in domain.
    if verify
        test_sample = randi([2 N-2], 1);

    end

    % At every sample index, compute the summed log-likelihood that
    % segments 1, 2 were drawn from distributions whose parameters are
    % in fact the sample statistics; i.e., assumed that the MLE
    % variances are the true population variances.
    for k = 2:N-2

        % Every changepoint is a new model. Assume segment one is the "noise",
        % and segment two the "signal."
        noise = x(1:k);
        signal = x(k+1:end);

        % Equation 7.
        var1 = 1/k * sum([noise - mean(noise)].^2);

        % Equation 12.
        var2 = 1/(N-k) * sum([signal - mean(signal)].^2);

        % Difference and ratio of variances: local maxima (sufficiently far
        % from the edges) should relate to km.
        dvar(k) = var2 - var1;
        rvar(k) = var2 / var1;

        %% Main -- Compute equation 15: the summed log-likelihood of both segments.
        sumly(k) = -1/2 * [k*log(var1) + (N-k)*log(var2) + N*(log(2*pi) + 1)];
        %% End main

        % Slide any NaNs removed (above in unzipnan) back into their proper index.
        if isempty(idx) == false
            sumly = zipnan(sumly, idx);
        end

        % A natural changepoint estimate would be that sample index
        % where the summed log-likelihood is maximized.
        [~, km] = max(sumly);

        % Throw into verifying procedure below, maybe.
        if verify && k == test_sample
            check_math(noise, signal, var1, var2, sumly, N, k)

        end

    end
end

function check_math(noise, signal, var1, var2, sumly, N, k)
% Check the math -- that equation 15 (which I skip to evaluating
% above) does in fact follow from equations 8 (which follows from 4)
% plus 13 (which follows from 10).
    fprintf('At sample index k = %i:\n', k);

    %________________________________________________%

    % Equation 8 and 13: MLE variances already substituted for true
    % variances; their sum should equal equation 15 ('sumly', above).
    eq8 = -k/2 * [log(2*pi) + log(var1) + 1];
    eq13 = -(N-k)/2 * [log(2*pi) + log(var2) + 1];
    fprintf('Difference between (eq8+13)-eq15 = %e\n', (eq8+eq13) - sumly(k))

    %________________________________________________%

    % Equation 4 should equal equation 8 when the MLE variance of the
    % "noise" is used.
    eq4 = normly(mean(noise), sqrt(var1), noise);
    fprintf('Difference between eqs. 8 and 4 = %e\n', eq8 - eq4)

    %________________________________________________%

    % Equation 10 should equal equation13 when the MLE variance of the
    % "signal" is used.
    eq10 = normly(mean(signal), sqrt(var2), signal);
    fprintf('Difference between eqs. 13 and 10 = %e\n', eq13 - eq10)

    %________________________________________________%

    % Of course, if all holds true above, equations 4 and 10, evaluated
    % at the MLE variances, should equal equation 15.
    eq_4_plus_10 = eq4 + eq10;
    fprintf('Difference between eq15-(eq4+eq10) = %e\n', sumly(k) - eq_4_plus_10)
    %________________________________________________%
