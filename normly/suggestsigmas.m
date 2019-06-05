function sigmas = suggestsigmas(trusigma, axlim, npts, linen)
% sigmas = SUGGESTSIGMAS(trusigma,axlim,npts,linen)
%
% SUGGESTSIGMAS returns a range of 'sigmas' (standard deviations, NOT
% variances) which lie inclusively between the two limits,
%
%         axlim(1) = min(testsigma^2 / trusigma^2)
%         axlim(2) = max(testsigma^2 / trusigma^2)
%
% and are discretized to 'npts' pieces, linear either in sigma (the
% output standard deviations are linearly-spaced), or sigma^2 (the
% square of the output standard deviations [the variances] are
% linearly-spaced).
%
% This function is useful for discretizing a range of standard
% deviations to test for MLE; i.e., in normlys.m and the plots that
% result, e.g., plot2normlysmix.m and image2normlysmix.m.
% SUGGESTSIGMAS takes the thought of out scaling the x-axes there
% because they plot (summed) log-likelihoods in terms of the test
% variance normalized by the true variance:
%
%               testsigma^2 / trusigma^2
%
% Input:
% trusigma      True sigma (standard deviation), input for normlystest.m
% axlim         [min max] of normalized variance coordinates, 
%                   called 'normvars' elsewhere (def: [0.5 2])
% npts          Number of points dividing axlim (def: 100)
% linen         1: sigmas (standard deviations) are linearly spaced
%               2: sigmas^2 (variances) are linearly spaced (def)
%
% Output:
% sigmas        Standard deviations, where either THEY (the standard deviations) 
%                   or THEIR  SQUARES (the variances) are linearly spaced -- 
%                   in either case, the standard deviations are what is returned
%
% Ex1: (x-axis limits of 0.5 1.5)
%    trusigma = sqrt(2); axlim = [0.5 1.5]; npts = 5;
%    disp('Stds. where the stds. are linearly spaced:')
%    sigmas1 = suggestsigmas(trusigma,axlim,npts,1)
%    diff(sigmas1)
%    disp('And normalized w.r.t true variance:')
%    sigmas1.^2/trusigma^2
%    disp('Stds. where the vars. are linearly spaced:')
%    sigmas2 = suggestsigmas(trusigma,axlim,npts,2)
%    diff(sigmas2.^2)
%    disp('And normalized w.r.t true variance:')
%    sigmas2.^2/trusigma^2
%    disp('N.B.: ''linen'' = 2 results in equally-spaced normalized coordinates')
%
% Ex2: (x-axis limits 8.1 12.4; sigmas doesn't include truth!)
%    trusigma = sqrt(2); axlim = [8.1 12.4]; npts = 100;
%    sigmas = SUGGESTSIGMAS(trusigma,axlim,npts)
%
% See also: normlys.m, normlystest.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 29-May-2019, Version 2017b

% Defaults.
defval('axlim', [0.5 2])
defval('npts', 100)
defval('linen', 2)

% Sanity checks.
assert(npts>=0, 'npts requested must be positive')
if ~(axlim(1)<=1 && axlim(2)>=1)
    warning('The requested sigmas range does not include the true sigma')
end

% Do it.
switch linen
  case 1
    sigmas = linspace(sqrt(axlim(1)*trusigma^2), sqrt(axlim(2)*trusigma^2), ...
                      npts);

  case 2
    sigmas = sqrt(linspace(axlim(1)*trusigma^2, axlim(2)*trusigma^2, npts));
    
  otherwise
    error('Specify either 1 or 2 for input: linen')

end
