function [lys,MLE,f,y] = normlystest(trusigma,normvars,npts,lx, ...
                                     ntests,plt,nglog,ha,nork)
% [lys,MLE,f,y] = NORMLYSTEST(trusigma,normvars,npts,lx,ntests,plt,nglog,ha,nork)
%
% NORMLYSTEST loops normlys.m ntests number of times, generating new
% random data given the parameters at each iteration. In normlys.m you
% input data; here it's generated automatically.
%
% Plots estimated variance/(true variance) vs. log-likelihood value of
% that estimated variance given random normal data with a mean of
% 0. Marks MLE of variance for every test with red dot. Returns MLE
% statistics of after all tests.
%
% Input:
% trusigma*    True standard deviation of the generating norm distribution
%                  (def: sqrt(2))
% normvars*    Normalized sigma^2 to test for noise, signal;
%                  called 'axlim' in suggestsigmas.m (def: [.5 1.5])
% npts        Number of x-axis points (e.g., number of likelihood
%                 calculations per time series tested) (def: 100)
% lx           Length random time series generated here (def: 1000)
% ntests       Number of tests (likelihood curves calculated) (def: 100)
%                  (alternatively--how finely you slice the XLim/normvars;
%                  number of sigmas tested) (def: 100)
% plt          true to plot (def: false)
% nglog        true to plot negative log-likelihood curves (def: false)
% ha           Axis handle to set plot, if passed (def: [])
% nork         Integer 1 or 2 for noise or signal segment
%
% Output:
% lys          Struct containing likelihood info w/ fields:
%  .avecurve       average likelihood value, of all tests, at every sigma
%  .curve:         every likelihood curve (ly at sigma for every test)
%  .maxidx:        index of maximum of every ly curve
%  .maxval:        value at maximum of every ly curve
% MLE          Struct containing MLE of sigma info w/ fields,
%  .avesigma:      average of MLE of sigma for all test
%  .trusigma       true sigma of generating distribution
%  .avesigma2:     average of MLE of variance for all test
%  .trusigma2      true variance of generating distribution
%  .sigma:         MLE sigma for every test
%  .sigma2:        MLE variance for every test
%  .sigmastested:  array of sigmas tested in normlys.m, converted
%                      from 'normvars' input via suggestsigmas.m
%  .xaxis          suggested x-axis for plotting
% f            Struct containing relevant figure handles, if created (def: [])
% y            Every time series randomly generated herein
%
% * trusigmas is a 1x2 array of standard deviations, not variances,
% while normvars is a bracketed range of normalized variances to test.
% The units of normalized variance are (test sigma)^2/(true sigma)^2;
% normvars = 1 is when the trusigma and test sigma are equal.
%
% Ex1: (plot positive log-likelihood; XLim = [.5 1.5]; 25 tests)
%    [lys,MLE] = NORMLYSTEST(sqrt(2),[.5 1.5],100,1000,25,true,false)
%    hold on; plot(MLE.xaxis,lys.avecurve,'m','LineWidth',4) % Plot average.
%
% Ex2: (plot negative log-likelihood; XLim = [.25 2]; 40 tests)
%    [lys,MLE] = NORMLYSTEST(sqrt(2),[.25 2],100,1000,40,true,true)
%    hold on; plot(MLE.xaxis,-lys.avecurve,'m','LineWidth',4) % Plot average.
%
% See also: normlys.m, plotnormlystest.m, plot2normlystest.m
%
% Cite: Simon, J. D. et al., (2020), BSSA, doi: 10.1785/0120190173
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 10-Jan-2020, Version 2017b on GLNXA64

% Defaults.
defval('trusigma',sqrt(2))
defval('normvars',[0.5 1.5])
defval('npts',500)
defval('lx',1000)
defval('ntests',100)
defval('plt',false)
defval('nglog',false)
defval('ha',[])
defval('f',[])

% Preallocate structs more than one level deep.
y{ntests} = 0;

lys.curve{ntests} = 0;
lys.avecurve(npts) = 0;
lys.maxval(ntests) = 0;
lys.maxidx(ntests) = 0;

MLE.sigmastested(npts) = 0;
MLE.sigma(ntests) = 0;
MLE.sigma2(ntests) = 0;
MLE.xaxis(npts) = 0;

% Use the input normalized sigma^2 to get sigma array.
MLE.sigmastested = suggestsigmas(trusigma,normvars,npts);

% Main routine: call normlys ntests times.
for i = 1:ntests
    % Generate random data according to input parameters.
    y{i} = normrnd(0,trusigma,[lx 1]);

    % Calculate all likelihoods for every sigma in range of sigmas.
    [lys.curve{i},~,MLE.sigma(i)] = normlys(0,MLE.sigmastested,y{i});

    % Return the sigma that is most likely as MLE.sigma.
    MLE.sigma2(i) = MLE.sigma(i)^2;

    % Collect the maximum value and index of the likelihood curve.
    [lys.maxval(i),lys.maxidx(i)] = max(lys.curve{i});

    % And add the current likelihood curve to a growing summed likelihood,
    % which will be divided after loop by ntests to get a mean
    % likelihood value at every sigma tested.
    lys.avecurve = lys.avecurve + lys.curve{i};
end
% End main routine.

% Collect stats.
MLE.avesigma = mean(MLE.sigma);
MLE.avesigma2 = mean(MLE.sigma2);
lys.avecurve = lys.avecurve/ntests;
[lys.avemaxval,lys.avemaxidx] = max(lys.avecurve);

% Might as well hold onto input info & generate normalized x-axis.
MLE.trusigma = trusigma;
MLE.trusigma2 = trusigma^2;
MLE.xaxis = MLE.sigmastested.^2 / MLE.trusigma2;

% Order the output.
lys = orderfields(lys,{'avecurve','curve','avemaxidx','maxidx', ...
                    'avemaxval','maxval'});
MLE = orderfields(MLE,{'avesigma','trusigma','avesigma2','trusigma2', ...
                    'sigma','sigma2','sigmastested','xaxis'});

% Plot it, maybe.
if plt
    f = plotnormlystest(MLE, lys, ha, nglog, nork);
end
