function [rawpow, relpow, totpow] = wtpower(da, meth)
% [rawpow, relpow, totpow] = WTPOWER(da, meth)
%
% Given an input cell array of details and/or approximation
% coefficients WTPOWER returns (1) an estimate of the power contained
% at every scale, (2) the relative distribution of power among scales
% (as a percentage), and (3) the total power contained in all scales.
% 
% Inputs:
% d           Cell array (e.g., of details and/or approximations from wt.m)
% meth        Method of calculation
%             0 Unbiased variance:            rawpow =    var(da, 0)
%             1 Biased variance (default):    rawpow =    var(da, 1)
%             2 Mean squared:                 rawpow =    mean(da^2)
%             3 Mean absolute value of:       rawpow = mean(abs(da))
%
% Outputs:
% rawpow      Estimated the power at every scale
% relpow      Relative distribution of estimated power at each scale 
%                 (percentage)
% totpow      L1 norm of power at all scales (totpow = sum(rawpow))
%
% Citations: 
% Sukhovich et al. (2011), doi: 10.1029/2011GL048474
% Sukhovich et al. (2014), doi: 10.1002/2013JB010936
%
% Ex: Power distribution considering (1) just details and,
%     (2) details and approximation
%    x = readsac('20180819T042909.08_5B7A4C26.MER.DET.WLT5.sac');
%    [a, ~, ~, d] = wtrmedge('time-scale', x);
%    [rawpow1, relpow1, totpow1] = WTPOWER(d)
%    [rawpow2, relpow2, totpow2] = WTPOWER([d a])
%
% See also: wtsnr.m, wt.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 10-Aug-2018, Version 2017b

% Default
defval('meth', 1)

% Sanity.
assert(iscell(da), 'Input ''da'' must be a cell array (e.g. output from wt.m).')

% Anonymous function switch for power estimate function of details
% and/or approx.
switch meth
  case 0
    % Unbiased variance.
    powfunc = @(zz) var(zz, 0);

  case 1
    % Biased variance.
    powfunc = @(zz) var(zz, 1);

  case 2
    % Mean squared.
    powfunc = @(zz) mean(zz.^2);    

  case 3
    % Mean absolute value -- Sukhovich et al. (2011) estimate of the power.
    powfunc = @(zz) mean(abs(zz));
  
  otherwise
    error('Specify [0:4] for ''meth'' option.')

end

% Collect average value of details and/or approx. at every scale.
for i = 1:length(da)
    % Work only on the finite coefficients.
    dtails = da{i}(isfinite(da{i}));

    % Apply to power (anonymous) power function defined above.
    rawpow(i) = powfunc(dtails);

end

% Remove any nonfinite values of rawpow before calculating relative
% power. Added back later.
[raw_unzip, idx] = unzipnan(rawpow);

% Divide by norm to see how power is distributed among the scales.
totpow  = norm(raw_unzip, 1);
relpow = 100 * (raw_unzip / totpow);

% Add (maybe) NaN values into proper indices of relpow to
% reflect their index in rawpow.
relpow = zipnan(relpow, idx);

rawpow = rawpow(:);
relpow = relpow(:);
