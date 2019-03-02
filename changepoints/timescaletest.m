function h1 = timescaletest(lx, ko, varsnr, iters, n, inputs)
% h1 = TIMESCALETEST(lx, ko, varsnr, iters, n, inputs)
%
% TIMESCALETEST measures whether or not the true changepoint, 'ko',
% lies within the time domain smear of the time-scale domain estimated
% changepoint coefficient index (is 'ko' within 'k_{j,lw}').  The null
% hypothesis is that that truth IS NOT within the time smear.
%
% TIMESCALETEST performs this test at various SNRs assuming the test
% time series is a concatenation of two normal distributions split at
% 'ko' (the changepoint, the last sample of the "noise").  Output
% matrices are indexed as (iteration, SNR index, wavelet scale).
%
% Input:
% lx          Length of time series (def: 4000)
% ko          True time-domain changepoint (def: 2000)
% varsnr      SNRs to test
%                 (def: [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024])
% iters       Number of test iterations per SNR (def: 1000)
% n           Number of scales of the wavelet decomposition (def: 5)
% inputs      Parameter struct for changepoint.m (def: cpinputs)
%
% Output:
% h1          Output matrix where 1 rejects null hypothesis, 0 otherwise,
%                 indexed as (iter, SNR, scale)
%
% Ex:
%    h1 = TIMESCALETEST(4000, 2000, 2, 100, 5, cpinputs)
%
% See also: changepoint.m
% 
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 10-Jan-2019, Version 2017b

% Defaults.
defval('lx', 4000)
defval('ko', 2000)
defval('varsnr', [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024])
defval('iters', 1000)
defval('n', 5)
defval('inputs', cpinputs)

% Output matrices indexing (iter, SNR index, scale)
h1 = zeros(iters, length(varsnr), n + 1);

for i = 1:length(varsnr)
    for j = 1:iters
        % Generate random time series.
        x = normcpgen(lx, ko, varsnr(i));

        % Compute changepoint in time-scale domain.
        CPts = changepoint('time-scale', x, 5, 1, 1, 1, inputs);        
        kjstar = CPts.cpsamp;

        % Reject null hypothesis if ko is within kjstar.
        h1(j, i, :) = cellfun(@(xx) xx(1) <= ko && ko <= xx(end), kjstar);

    end
end
