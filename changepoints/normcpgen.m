function x = normcpgen(lx, cp, varsnr)
% x = NORMCPGEN(lx, cp, varsnr)
%
% Wrapper for cpgen to assuming both segments drawn from normal
% distributions, each with an expectation of 0, and a signal-to-noise
% ratio specified by varsnr. Segment one has parameters mu=0, std=1;
% segment two has parameters mu = 0, std = sqrt(varsnr).
%
% Inputs:
% lx          Length of time series (def: 1000)
% cp          Changepoint index, where distribution changes (def: 500)
% varsnr      Ratio of variance of segment one over segment two, or ~SNR*
%                 (def: 2)
%
% Output:
% x           Time series concatenated at cp
%
% *Note: input ratio of variances, not standard deviations!
%
% Ex: (time series of length 1000; cp @ 500; SNR of 4)
%    x = NORMCPGEN(1000,500,4);          % generate series
%    SNR = var(x(501:end))/var(x(1:500)) % should be ~4
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 29-Dec-2018, Version 2017b

% Defaults.
defval('lx', 1000)
defval('cp', 500)
defval('varsnr', 2)

% MATLAB normrnd.m uses parameters of mu and sigma (standard
% deviation), not mu and variance.  Take sqrt of input varsnr.
p1 = {0 1};
p2 = {0 sqrt(varsnr)};
x = cpgen(lx, cp, 'norm', p1, 'norm', p2);
