function [SNRj, SNR, nrel, srel, ntot, stot] = wtsnr(da, cp, meth)
% [SNRj, SNR, nrel, srel, ntot, stot] = WTSNR(da, cp, meth)
%
% WTSNR returns the signal-to-noise ratio and summarizes the
% distribution of power across wavelet scales.
%
% Input:
% da           Cell (e.g., wavelet details,
%                 or their partial reconstructions)
% cp          Corresponding changepoint indices, e.g., from cpest.m
%                 Note: not the arrival indices (which are cp + 1)
% meth        Method of calculation 
%             0 ratio of UNBIASED variances 
%                 var(sig,0) / var(nos,0)
%             1 ratio of the BIASED variances (default)
%                 var(sig,1) / var(nos,1) 
%             2 ratio of the means of the squared values
%                 mean(sig^2) / mean(nos^2)
%             3 ratio of the means of the absolute values
%                 mean(abs(sig)) / mean(abs(nos))
%
%
% Output:
% SNRj        SNR at every scale (signal_power./noise_power)
% SNR         Sum of SNR across all scales 
%                 (sum(signal_power) / sum(noise_power))
% n(s)rel*    Relative distribution of estimated power of noise (signal) 
%                 at each scale (percentage)
% n(s)tot**   L1 norm of power of noise (signal) at all scales 
%                 (totpow = sum(rawpow))
%
% *Use wtpower(da) to get relative power of entire scale as opposed to
% the relative power of just the multiscale noise or signal segments
%
% **SNR == [stot/ntot]
%
% For the examples below first run:
%    x = readsac('20180819T042909.08_5B7A4C26.MER.DET.WLT5.sac');
%
% Ex1: Power distribution of a real seismogram in time-scale domain
%    [a1, ~, ~, d1] = wtrmedge('time-scale', x);
%    kwa1 = cpest(a1);
%    kwd1 = cpest(d1);
%    [SNRj1, SNR1, nrel1, srel1] = WTSNR([d1 a1], [kwd1 kwa1])
%
% Ex2: Power distribution of a real seismogram in time domain
%    [a2, ~, ~, d2] = wtrmedge('time', x);
%    kwa2 = cpest(a2);
%    kwd2 = cpest(d2);
%    [SNRj2, SNR2, nrel2, srel2] = WTSNR([d2 a2], [kwd2 kwa2])
%
% See also: cpest.m, wtpower.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 16-Nov-2018, Version 2017b

% Default.
defval('meth', 1)

% Parse details into noise and signal segments.
for i = 1:length(da)
    if ~isnan(cp(i))
        n{i} = da{i}(1:cp(i));
        s{i} = da{i}(cp(i)+1:end);
    else        
        n{i} = NaN;
        s{i} = NaN;

    end
end

% Feed noise and signal segments to wtpower.m
[nraw, nrel, ntot] = wtpower(n, meth);
[sraw, srel, stot] = wtpower(s, meth);

% Compute SNR at every scale and the total SNR across all scales.
SNRj = sraw ./ nraw;
SNR = nansum(sraw) / nansum(nraw);
