function varargout = cpm1(iters, lx, cp, dist1, p1, dist2, p2, abso, ...
                          dtrnd, plt, x, bias)
% [del_km,del_kw,km_percerr,kw_percerr,f1,f2] = ...
%     CPM1(iters,lx,cp,dist1,p1,dist2,p2,abso,dtrnd,plt,x,bias)
%
% Changepoint Error Estimation via Method 1: Sample errors.
%
% See also: cpci.m, which only computes error for a single changepoint
% type ('km' or 'kw').  This function, rather, compares the two
% changepoint types.
%
% Run cpest.m 'iters' number of times and collect sample (x-direction)
% and percentage (y-direction) errors for each test.  Returns raw
% error vectors of length(iters), i.e. doesn't summarize with mean,
% std. etc.  If asked to plot, will do so only for last test
% iteration, and using x if supplied.
%
% Inputs: (all defaulted)
% iters             Number of test iterations 
% lx                Length of test time series
% cp                Index of changepoint where distribution changes
% dist1/2           A string, name of 1st/2nd distribution (e.g. 'norm')
% p1/2              Cell array of dist1/2 parameters (e.g., {0 1})
% abso              Work on absolute values of x? (def: false)
% dtrnd             Detrend segments l/r of cp in cpest.m? (def: false)*
% plt               Plot it? (def: false)
% x                 A time series, used for plotting maybe**
% bias              true to use BIASED estimate of sample variance (1/N) (def: true)
%                   false to use UNBIASED estimate of the sample variance (1/N-1)
%
% Outputs:
% del_km           The x value error in number of samples of the guess based
%                      on AIC global minimum
% del_kw           The x value error in number of samples of the guess based
%                      on AIC weights
% km_percerr       The y value error in magnitude percentage of the
%                      guess based on AIC global minimum
% kw_percerr       The y value error in magnitude percentage of the
%                      guess based on AIC weights
% f1,f2            Figure handles, if created (def: [])
%                   f1: Zoom-in on aicx around cp, showing sample error of pick
%                   f2: Summary sample error histogram of all test iterations
%
% * Massively slows down code because requires 'slow' algo in cpest.m
%
% ** If supplied cpm1.m will NOT generate a random x time series on
% the last test iteration and instead use the one supplied for the
% purpose of plotting. Be careful here to ensure same distributions
% and parameters where used to generate x as all other time series
% randomly generated in this code for testing.
%
% See also: cpm2.m, cptest.m, cpci.m
%
% Ex: plotcpm1('demo'), of which cpm1.m is represented in figure 1.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 17-Nov-2017, Version 2017b

% Defaults.
defval('iters',1000)
defval('lx',1000)
defval('cp',500)
defval('dist1','norm')
defval('p1',{0 1})
defval('dist2','norm')
defval('p2',{0 sqrt(2)})
defval('abso',false)
defval('dtrnd',false)
defval('plt',false)
defval('x',[])
defval('bias',true)

% Default output.
f1 = [];
f2 = [];

% Use supplied x for plots?
if ~isempty(x)
    warning(['Using supplied x for plotting; ensure fits same model ' ...
             'parameters as that which is being tested'])
    xend = x;
end

% Fair warning.
if dtrnd
    warning(sprintf(['dtrnd option makes this crawl because it ' ...
                     'defaults cpest.m to use ''slow'' algo;\n''fast'' ' ...
                     'algo uses cumstats.m which doesn''t currently ' ...
                     'support indexed detrending.']))
end

% Initialize outputs.
del_km = NaN(1,length(iters));
del_kw = del_km;
km_percerr = del_km;
kw_percerr = del_km;

% Run cpest.m 'iters' number of times, collect error of changepoint estimates.
for i = 1:iters
    % Generate time series and calculate AIC function.  Here's the switch
    % in case x is supplied; maybe use a supplied time series for last
    % test iteration and plotting. Otherwise generate randomly.
    if exist('xend') && i == iters(end)
        x = xend;
    else
        x = cpgen(lx,cp,dist1,p1,dist2,p2);
    end

    % Use absolute values, if requested.
    if abso
        x = abs(x);
    end
    
    % Estimate the changepoint.
    [kw, km, aicx] = cpest(x, 'fast', dtrnd, bias);
    ykm = aicx(km);
    ykw = aicx(kw);

    % If AIC non-finite return NaN output (generally when lx < 4).
    if isempty(find(isfinite(aicx)))
        del_km(i) = NaN;
        del_kw(i) = NaN;
        km_percerr(i) = NaN;
        kw_percerr(i) = NaN;
        continue
    end

    % Nab every true value.
    ytru = aicx(cp);

    % SAMPLE DISTANCE X, Y
    del_km(i) = km - cp;
    del_ykm = ykm - ytru;

    del_kw(i) = kw - cp;
    del_ykw = ykw - ytru;

    % PERCENTAGE DISTANCE Y
    aicrange = range(aicx(isfinite(aicx)));
    km_percerr(i) = abs(del_ykm)/aicrange * 100;
    kw_percerr(i) = abs(del_ykw)/aicrange * 100;
end

% Plot last test result and summary, maybe.
if plt
    f1 = plotcpm1(cp,x,aicx,km,ykm,kw,ykw);
    f2 = plotcpm1s(del_km,del_kw);
end

% Collect outputs.
varns = {del_km,del_kw,km_percerr,kw_percerr,f1,f2};
varargout = varns(1:nargout);
