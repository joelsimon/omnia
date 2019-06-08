function [x, y] = normlysmixvals(k, trusigmas, N, ko)
% [x, y] = NORMLYSMIXVALS(k, trusigmas, N, ko)
%
% Returns the x (the normalized MLE of the variance) and y (its
% corresponding summed log-likelihood) values given a theoretical time
% series and (POSSIBLY INCORRECT) changepoint, 'k', after summing
% log-likelihoods at that 'k'.  I.e., returns the theoretical x,y
% values, as ntests goes to infinity, of plotnormlystest.m given some
% mixing defined by the difference between 'k' (the assumed
% changepoint) and 'ko' (the true changepoint).
%
% Theoretical time series is assumed to be drawn from
% normrnd(0,trusigmas(1)) for x(1:ko) (the noise), and normrnd(0,
% trusigmas(2)) for x(ko+1:end) (the signal). I.e., concatenated on
% the true changepoint, 'ko'.  This code tests how the MLE and its
% likelihood value behave when k is allowed to vary.
%
% Input:
% k            The index of the incorrect changepoint
% trusigmas    Std. deviations of the generating norm distributions 
%                  (def: [1 sqrt(2)])
% N            Length time series generated here (def: 1000)
% ko           Sample index of changepoint that separates noise, signal
%                  (def: 500). Elsewhere called 'bp', for changepoint.
%
% Output:
% x            The value on the x-axis on a normlysmix plot; i.e.,
%                  the MLE of the normalized variance 
% y            The likelihood value of the MLE of the normalized variance
%     
% Both outputs are vectors in the form x, y = [noise signal sum], that
% is, both x and y return a 1x3 vector that gives the normalized MLE
% value and its likelihood for the noise section (segment 1), the
% signal section (segment 2), and the combined theoretical time
% series.
%
% Ex1: (changepoint early; we expect reduced MLE of "signal" variance)
%    [x, y] = NORMLYSMIXVALS(50, [1 sqrt(2)], 1000, 500)
%
% Ex2: (changepoint late; we expect increased MLE of "noise" variance)
%    [x, y] = NORMLYSMIXVALS(950, [1 sqrt(2)], 1000, 500)
%
% Citation: paper??
%
% See also: normly.m, normlysmix.m, plot2normlysmix.m, 
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 16-May-2018, Version 2017b
% Documented pp. 55-61, 2017.1.

% Defaults.
defval('trusigmas', [1 sqrt(2)])
defval('N', 1000)
defval('ko', 500)

% Sanity checks.
% Noise and signal segments both need at least 1 sample.
if N < 2 
    error('Input argument ''N'' must be at least of length 2.')
end

% The true changepoint must be within the length of the time series.
if ko < 1 || ko > N-1
    error('Input argument ''ko'' must be within [1:N-1], inclusive.')
end

% The signal segment needs at least one point (we verify this
% condition for the noise in the first sanity check.
if N - k < 1
    error('N-k must be at least of length 1.')
end

sigma1 = trusigmas(1);
sigma2 = trusigmas(2);

% THE X VALUES: maximum likelihood estimate (MLE) of the sample variance.m

% Changepoint early.
if k < ko

    % Noise -- there is no mixing; the sample variance is itself and the
    % normalized value is 1.
    noisevar = sigma1^2;
    norm_noisevar = 1; 

    % "Signal" -- equation 21.
    sigvar = 1/(N-k) * [(ko-k)*sigma1^2 + (N-ko)*sigma2^2]; 
    norm_sigvar = sigvar / sigma2^2;                         

    % Sum -- equation 24.
    norm_sumvar = 1 + 1/N*[(ko-k)*(sigma1^2/sigma2^2 - 1)]; % 

% Changepoint late.
elseif k > ko

    % "Noise" -- equation 16.
    noisevar = 1/k* [ko*sigma1^2 + (k-ko)*sigma2^2]; 
    norm_noisevar = noisevar / sigma1^2;                 
    
    % Signal -- there is no mixing; the sample variance is itself and the
    % normalized value is 1.
    sigvar = sigma2^2;
    norm_sigvar = 1;
    
    % Sum -- equation 23.
    norm_sumvar = 1 + 1/N*[(k-ko)*(sigma2^2/sigma1^2 - 1)]; 

% Changepoint correct.
elseif k == ko
    
    % Trivial case.
    noisevar = sigma1^2;
    norm_noisevar = 1;

    sigvar = sigma2^2;
    norm_sigvar = 1;

    norm_sumvar = 1;

end

% Collect the theoretical MLE variances (X-Axis).
x = [norm_noisevar norm_sigvar norm_sumvar];

%_________________________________________________________________________%

% THE Y VALUES: theoretical log-likelihoods.

% Noise -- equation 8: summed log-likelihood evaluated at MLES.
noiselike = -k/2 * [log(2*pi) + log(noisevar) + 1];

% Noise -- equation 13: summed log-likelihood evaluated at MLES.
siglike = -(N-k)/2 * [log(2*pi) + log(sigvar) + 1];

% Summed -- Equation 14, below*.
sumlike = noiselike + siglike;

% Collect the theoretical log-likelihoods associated with each MLE (Y-Axis).
y = [noiselike siglike sumlike];

% * This is the full equation. We can avoid this calculation by
% summing two normalized sections, but here is equation 15 for
% reference. Uncomment to check the difference..
%sumlike2 = -1/2* [k*log(noisevar) + (N-k)*log(sigvar) + N*(log(2* pi)+1)];
%difer(sumlike-sumlike2)
