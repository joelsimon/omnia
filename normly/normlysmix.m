function [enk,esk,lnk,lsk,y,cnk,csk] = normlysmix(perc,trusigmas,normvars,npts,lx,k0, ...
                                          ntests)
% [enk,esk,lnk,lsk,y,cnk,csk] = NORMLYSMIX(perc,trusigmas,normvars,npts,lx,k0,ntests)
%
% Like normlystest.m but instead of testing a time series that is
% generated exactly by the input parameters, it allows some percentage
% of mixture between a noise/signal segment.  E.g., if perc = 10, the
% 'noise' (first) and 'signal' (second) segments will both include 10%
% of the total length (lx) of the signal of the other segment's
% samples.  Assumes the time series is composed of a noise and signal
% segment. Ergo, instead of supplying 1 trusigma as in normlystest.m,
% you supply 2 trusigmas (one for the noise segment, one for the
% signal segment).
%
% Returns 4 structures: enk, esk, lnk, lsk. Prefix 'e' means
% changepoint early: samples REMOVED from the NOISE and ADDED to the
% SIGNAL.  Prefix 'l' means changepoint late: samples ADDED to the
% NOISE and REMOVED from the SIGNAL.  nk means noise segment, sk means
% signal segment.  To calculate the joint likelihood you match enk
% with esk and vice versa.
%
% The example below shows the effect of mixing a higher variance
% signal section with a lower variance noise section. When the
% changepoint is early the estimated true variance of the noise
% (enk.avesigma2) is largely unaffected; samples are removed from the
% noise section but none are added from the signal. Conversely, the
% signal section now includes some lower variance noise, which lowers
% its estimated true variance (esk.avesigma2).  Opposite is true when
% changepoint late--lnk.avesigma2 increases; lsk.avesigma2 unaffected.
%
% Inputs:
% perc         Percentage of lx mixed between noise, signal (def: 10)
% trusigmas*   sigmas of the generating norm distributions (def: [1 sqrt(2)])
% normvars*    Normalized sigma^2s to test for noise, signal; 
%                  called 'axlim' in suggestsigmas.m (def: [.5 1.5])
% npts         Number of points per test/likelihood curve
%                  (alternatively--how finely you slice the XLim/normvars;
%                  number of sigmas tested) (def: 100)
% lx           Length random time series generated here (def: 1000)
% k0           Sample index of changepoint that separates noise, signal
%                  (def: 500)
% ntests       Number of tests (likelihood curves calculated) (def: 100)
% 
% Outputs:
% enk          NOISE segment when changepoint EARLY w/ fields:
%  .info           experiment performed, here 'changepoint early: noise'
%  .avesigma:      average of MLE of sigma for all tests
%  .trusigma       true sigma of generating normal dist
%  .avesigma2:     average of MLE of variance for all tests
%  .trusigma2      true variance of generating normal dist
%  .MLEsigmas:     MLE of sigma for every test
%  .sigmastested:  array of sigmas tested in normlys.m, converted
%                      from 'normvars' input via suggestsigmas.m
%  .lys:           every likelihood curve (ly at sigma for every test)
%  .lys_maxidx:    index of maximum of every ly curve
%  .lys_maxval:    value at maximum of every ly curve
%  .lx             length of signal mixed segment (k0+-mixsamps)
%  .xaxis          normalized x axis of sigmastested.^2/trusigma2
%  .mixsamps       total number of samples removed from one segment 
%                      and added the other
%  .perc           percentage of mixture requested (which is rounded to a sample)
%  .k0             true changepoint of time series
%  .k              assumed changepoint of time series (what was actually tested)
%
% esk          SIGNAL segment when changepoint EARLY, same fields as above
% lnk          NOISE segment when changepoint LATE, same fields as above
% lsk          SIGNAL segment when changepoint LATE, same fields as above
% y            Every time series randomly generated herein
% lnk          NOISE segment when changepoint CORRECT, same fields as above
% lsk          SIGNAL segment when changepoint CORRECT, same fields as above
%
%
% * trusigmas is a 1x2 array of standard deviations, not
% variances. normvars is a bracketed range of normalized variances to
% test for both noise and signal sections.  The units of normalized
% variance are (test sigma)^2/(true sigma)^2; normvars = 1 is when the
% trusigma and test sigma are equal.
%
% Ex: (25 percent mixing between noise~N(0,1) and signal~N(0,8))
%    [enk,esk,lnk,lsk] = NORMLYSMIX(25,[2 4],[0.5 3])
%    
% Citation: ??
%
% See also: suggestsigmas.m, plotnormlysmix.m, plot2normlysmix.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 28-May-2019, Version 2017b

% Defaults.
defval('perc',10)
defval('trusigmas',[1 sqrt(2)])
defval('normvars',[.5 1.5])
defval('lx',1000)
defval('k0',500)
defval('ntests',100)
defval('npts',100)

% Sanity check.
if perc < 0 || perc > 100
    error('Please supply a positive percenatge between 0:100.')
end

% Preallocate structure fields more than one level deep.
enk.sigmastested(npts) = 0;
esk.sigmastested(npts) = 0;
lnk.sigmastested(npts) = 0;
lsk.sigmastested(npts) = 0;
cnk.sigmastested(npts) = 0;
csk.MLEsigmas(ntests) = 0;

enk.MLEsigmas(ntests) = 0;
esk.MLEsigmas(ntests) = 0;
lnk.MLEsigmas(ntests) = 0;
lsk.MLEsigmas(ntests) = 0;
cnk.MLEsigmas(ntests) = 0;
csk.MLEsigmas(ntests) = 0;

enk.lys{ntests} = 0;
esk.lys{ntests} = 0;
lnk.lys{ntests} = 0;
lsk.lys{ntests} = 0;
cnk.lys{ntests} = 0;
csk.lys{ntests} = 0;

enk.lys_maxidx(ntests) = 0;
esk.lys_maxidx(ntests) = 0;
lnk.lys_maxidx(ntests) = 0;
lsk.lys_maxidx(ntests) = 0;
cnk.lys_maxidx(ntests) = 0;
csk.lys_maxidx(ntests) = 0;

enk.lys_maxval(ntests) = 0;
esk.lys_maxval(ntests) = 0;
lnk.lys_maxval(ntests) = 0;
lsk.lys_maxval(ntests) = 0;
cnk.lys_maxval(ntests) = 0;
csk.lys_maxval(ntests) = 0;

% Calculate appropriate sigma ranges to test given requested
% normalized sigma^2 / XLim.
sigmas{1} = suggestsigmas(trusigmas(1),normvars,npts);
sigmas{2} = suggestsigmas(trusigmas(2),normvars,npts);

% Lengths of noise and signal segments.
mixsamps = round(lx*perc/100);
early_noise = [1:k0-mixsamps];
early_sig = [k0-mixsamps+1:lx];
late_noise = [1:k0+mixsamps];
late_sig = [k0+mixsamps+1:lx];

% Ensure the total samples in one section is not greater than the
% total length of the time series (lx); also that there is at least 1
% point in both noise and signal segments.
if k0-mixsamps < 1 || k0+mixsamps > lx 
    errmsg = sprintf(['The changepoint and sample mixture requested ' ...
                      'leaves either the noise or signal segments ' ...
                      'without any samples.\nTry a lower percentage ' ...
                      'of mixing.']);
    error(errmsg);
end

%% Main routine: call normlys ntests times on the mixed noise/signal segments.
for i = 1:ntests
    % Generate random data according to input params.
    y{i} = cpgen(lx,k0,'norm',{0 trusigmas(1)},'norm',{0 trusigmas(2)});

    %% CASE 1: the changepoint is early.
    earlynksamps = y{i}(early_noise);
    earlysksamps = y{i}(early_sig);

    [enk.lys{i},~,enk.MLEsigmas(i)] = normlys(0,sigmas{1},earlynksamps);
    [esk.lys{i},~,esk.MLEsigmas(i)] = normlys(0,sigmas{2},earlysksamps);

    %% CASE 2: the changepoint is late.
    latenksamps = y{i}(late_noise);
    latesksamps = y{i}(late_sig);

    [lnk.lys{i},~,lnk.MLEsigmas(i)] = normlys(0,sigmas{1},latenksamps);
    [lsk.lys{i},~,lsk.MLEsigmas(i)] = normlys(0,sigmas{2},latesksamps);

    %% CASE 3: the changepoint is correct.
    correctnksamps = y{i}(1:k0);
    correctsksamps = y{i}(k0+1:end);

    [cnk.lys{i},~,cnk.MLEsigmas(i)] = normlys(0,sigmas{1},correctnksamps);
    [csk.lys{i},~,csk.MLEsigmas(i)] = normlys(0,sigmas{2},correctsksamps);


end
%% End main.

% Collect statistics.
enk.info = 'changepoint early: noise';
enk.avesigma = mean(enk.MLEsigmas);
enk.avesigma2 = mean(enk.MLEsigmas.^2);
enk.trusigma = trusigmas(1);
enk.trusigma2 = trusigmas(1)^2;
enk.sigmastested = sigmas{1};
[enk.lys_maxval,enk.lys_maxidx] = ...
    cellfun(@max,enk.lys);
enk.lx = length(early_noise);
% And make a normalized X-Axis, which is the same for all.
enk.xaxis = enk.sigmastested.^2/enk.trusigma2;
enk.mixsamps = mixsamps;
enk.perc = perc;
enk.k0 = k0;
enk.k = length(early_noise);

esk.info = 'changepoint early: signal';
esk.avesigma = mean(esk.MLEsigmas);
esk.avesigma2 = mean(esk.MLEsigmas.^2);
esk.trusigma = trusigmas(2);
esk.trusigma2 = trusigmas(2)^2;
esk.sigmastested = sigmas{2};
[esk.lys_maxval,esk.lys_maxidx] = ...
    cellfun(@max,esk.lys);
esk.lx = length(early_sig);
esk.xaxis = esk.sigmastested.^2/esk.trusigma2;
esk.mixsamps = mixsamps;
esk.perc = perc;
esk.k0 = k0;
esk.k = length(early_noise);

lnk.info = 'changepoint late: noise';
lnk.avesigma = mean(lnk.MLEsigmas);
lnk.avesigma2 = mean(lnk.MLEsigmas.^2);
lnk.trusigma = trusigmas(1);
lnk.trusigma2 = trusigmas(1)^2;
lnk.sigmastested = sigmas{1};
[lnk.lys_maxval,lnk.lys_maxidx] = ...
    cellfun(@max,lnk.lys);
lnk.lx = length(late_noise);
lnk.xaxis = lnk.sigmastested.^2/lnk.trusigma2;
lnk.mixsamps = mixsamps;
lnk.perc = perc;
lnk.k0 = k0;
lnk.k = length(late_noise);

lsk.info = 'changepoint late: signal';
lsk.avesigma = mean(lsk.MLEsigmas);
lsk.avesigma2 = mean(lsk.MLEsigmas.^2);
lsk.trusigma = trusigmas(2);
lsk.trusigma2 = trusigmas(2)^2;
lsk.sigmastested = sigmas{2};
[lsk.lys_maxval,lsk.lys_maxidx] = ...
    cellfun(@max,lsk.lys);
lsk.lx = length(late_sig);
lsk.xaxis = lsk.sigmastested.^2/lsk.trusigma2; 
lsk.mixsamps = mixsamps;
lsk.perc = perc;
lsk.k0 = k0;
lsk.k = length(late_noise);

cnk.info = 'changepoint correct: noise';
cnk.avesigma = mean(cnk.MLEsigmas);
cnk.avesigma2 = mean(cnk.MLEsigmas.^2);
cnk.trusigma = trusigmas(1);
cnk.trusigma2 = trusigmas(1)^2;
cnk.sigmastested = sigmas{1};
[cnk.lys_maxval,cnk.lys_maxidx] = ...
    cellfun(@max,cnk.lys);
cnk.lx = length(1:k0);
cnk.xaxis = cnk.sigmastested.^2/cnk.trusigma2; 
cnk.mixsamps = mixsamps;
cnk.perc = 0;
cnk.k0 = k0;
cnk.k = k0;

csk.info = 'changepoint correct: signal';
csk.avesigma = mean(csk.MLEsigmas);
csk.avesigma2 = mean(csk.MLEsigmas.^2);
csk.trusigma = trusigmas(2);
csk.trusigma2 = trusigmas(2)^2;
csk.sigmastested = sigmas{2};
[csk.lys_maxval,csk.lys_maxidx] = ...
    cellfun(@max,csk.lys);
csk.lx = length(k0+1:lx);
csk.xaxis = csk.sigmastested.^2/csk.trusigma2; 
csk.mixsamps = 0;
csk.perc = 0;
csk.k0 = k0;
csk.k = k0;

% Return sensibly ordered fields.
enk = orderfields(enk,{'info','avesigma','trusigma','avesigma2', ...
                    'trusigma2','MLEsigmas','sigmastested','lys', ...
                    'lys_maxidx','lys_maxval','lx','xaxis', ...
                    'mixsamps','perc','k0','k'});
esk = orderfields(esk,enk);
lnk = orderfields(lnk,enk);
lsk = orderfields(lsk,enk);
cnk = orderfields(cnk,enk);
csk = orderfields(csk,enk);
