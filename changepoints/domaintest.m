function [t_err, tsf_err, tsm_err, tsl_err] = domaintest(lx, cp, ...
                                                      varsnr, iters, ...
                                                      n, inputs, pth)
% [t_err, tsf_err, tsm_err, tsl_err] = ...
%         DOMAINTEST(lx, cp, varsnr, iters, n, inputs, pth)
%
% DOMAINTEST measures the error (via Method 1) of changepoint
% estimates in both the 'time' and 'time-scale' domains at various
% SNRs assuming the test time series is a concatenation of two normal
% distributions split at 'cp' (the changepoint, the last sample of the
% "noise").
%
% Output matrices are indexed as (iteration, SNR index, scale).
%
% Error (at scale j) is a defined as:
% error = CP.cpsamp - cp
%         (estimate - truth)
%
% Input:
% lx          Length of time series (def: 4000)
% cp          True changepoint (def: 2000)
% varsnr      SNRs to test
%                 (def: [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024])
% iters       Number of test iterations per SNR (def: 1000)
% n           Number of scales of the wavelet decomposition (def: 5)
% inputs      Parameter struct for changepoint.m (def: cpinputs)
% pth           Path to savefile where domaintest.mat is written
%                 (def: '~/Desktop')
%
% Output:
% t_err       Time domain error
% tsf_err     Time-scale domain error: first sample
% tsm_err     Time-scale domain error: middle (rounded) sample
% tsl_err     Time-scale domain error: last sample
%
%
% See also: changepoint.m
% 
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 01-Jan-2019, Version 2017b

% Defaults.
defval('lx', 4000)
defval('cp', 2000)
defval('varsnr', [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024])
defval('iters', 1000)
defval('n', 5)
defval('inputs', cpinputs)
defval('pth', '~/Desktop')

% Output matrices indexing (iter, snr index, scale)
t_err   = NaN(iters, length(varsnr), n + 1);
tsf_err = NaN(iters, length(varsnr), n + 1);
tsm_err = NaN(iters, length(varsnr), n + 1);
tsl_err = NaN(iters, length(varsnr), n + 1);

for i = 1:length(varsnr)
    for j = 1:iters
        % Generate random time series.
        x = normcpgen(lx, cp, varsnr(i));

        % Compute M1 error in time domain.
        CPt = changepoint('time', x, n, 1, 1, 1, inputs, -1);
        t = CPt.cpsamp;

        t_err(j, i, :) = cellfun(@(xx) xx - cp, t);
        
        % Compute M1 error in time-scale domain.
        CPtsf = changepoint('time-scale', x, n, 1, 1, 1, inputs, ...
                            -1, 'first');        
        CPtsm = changepoint('time-scale', x, n, 1, 1, 1, inputs, ...
                            -1, 'middle');        
        CPtsl = changepoint('time-scale', x, n, 1, 1, 1, inputs, ...
                            -1, 'last');        

        tsf = CPtsf.cpsamp;
        tsm = CPtsm.cpsamp;
        tsl = CPtsl.cpsamp;
        
        tsf_err(j, i, :) = cellfun(@(xx) xx - cp, tsf);
        tsm_err(j, i, :) = cellfun(@(xx) xx - cp, tsm);
        tsl_err(j, i, :) = cellfun(@(xx) xx - cp, tsl);

    end
end
save([fullfile(pth, mfilename) '.mat'])
