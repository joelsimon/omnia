function varargout = cpm2(alphas, iters, lx, cp, dist1, p1, ...
                                   dist2, p2, abso, dtrnd, restrikt, ...
                                   plt, x, bias)
% [km_count,kw_count,km_range,kw_range,f1,f2,f3] = CPM2(alphas,iters, ...
%                                                   lx,cp,dist1,p1, ...
%                                                   dist2,p2,abso, ...
%                                                   dtrnd,restrikt,plt,x,bias)
%
% Changepoint Error Estimation via Method 2: Alpha-levels test.
%
% See also: cpci.m, which only computes error for a single changepoint
% type ('km' or 'kw').  This function, rather, compares the two
% changepoint types.
%
% Same idea of cpm1.m except that it asks the question, "Is the true
% changepoint ('cp') within the range of x values included under/within
% the estimated changepoint, plus some alpha-level (percentage of the
% total range of the cpest function)?"  Alpha is specified as a
% percentage between 0:100. Tests both changepoint estimates, km and
% kw, from cpest.m.
%
% Inputs: (all defaulted)
% alphas            Alpha levels (percentages) to test 
% iters             Number of test iterations per alpha
% lx                Length of test time series
% cp                Index of changepoint where distribution changes
% dist1/2           A string, name of 1st/2nd distribution (e.g. 'norm')
% p1/2              Cell array of dist1/2 parameters (e.g., {0 1})
% abso              Work on absolute values of x? (def: false)
% dtrnd             Detrend segments l/r of cp in cpest.m? (def: false)*
% plt               Plot it? (def: false)
% restrikt          Enforce contiguity? (def: false)**
% x                 A time series, used for plotting maybe***
% bias              true to use BIASED estimate of sample variance (1/N) (def: true)
%                   false to use UNBIASED estimate of the sample variance (1/N-1)
%
%
% Outputs:
% km_count          Number of times out of total iterations at each
%                       alpha that the true changepoint is within the spread at or below
%                       the specified alpha, about estimate based on
%                       global minimum
% kw_count          Same as km_count, but for kw, the  based
%                       on weighted averages
% km_range          The average range, in samples, that each alpha
%                       level represents for all test iterations
%                       about the estimate based on global minimum
% kw_range          Same as km_range, for kw, the estimate based on
%                       weighted averages 
% f1,f2,f3          Structs of figures' handles, if created (def: [])
%                       f1: Zoom-in on aicx around cp, with example waterlvls plotted
%                       f2: Summary curve of alpha vs. probability cp
%                           below waterlvl, cpest minimum estimation (km)
%                       f3: Same as f2, for weighted average estimation (kw)
%
% * Massively slows down code because requires 'slow' algo in cpest.m
%
% ** Can specify 'both' and it will test both 'true' and 'false'
% contiguity (restricted and unrestricted).
%
% *** If supplied cpest_samptest will NOT generate a random x time
% series on the last test iteration and instead use the one supplied
% for the purpose of plotting. Be careful here to ensure same
% distributions and parameters where used to generate x as all other
% time series randomly generated in this code for testing.
% 
% N.B.: y-value at kw estimation (ykm) will always be at least
% y-value at km estimation (ykm), though likely above that since AIC
% function (aicx) is always concave up for real numbers. Therefore,
% for the same alpha percentage to search above estimate the kw
% solution will include the truth more often but also have a greater
% uncertainty.  Control the waterlvl behavior with restrikt option.
%
% See also: cptest.m, cpm1.m, contiguous.m
%
% Ex: plotcpm2('demo')
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 07-Mar-2018, Version 2017b

% Defaults -- 
% Possible inputs.
defval('alphas',[0:.05:10])
defval('iters',1000)
defval('lx',1000)
defval('cp',500)
defval('dist1','norm')
defval('p1',{0 1})
defval('dist2','norm')
defval('p2',{0 2})
defval('abso',false)
defval('dtrnd',false)
defval('restrikt',false)
defval('plt',false)
defval('x',[])
defval('bias',true)

% Possible outputs.
defval('f1',[])
defval('f2',[])
defval('f3',[])

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
km_count = zeros(1,length(alphas));
kw_count = km_count;
km_range = km_count;
kw_range = km_count;

% For each iteration test all alphas. Keep of number of times
% estimate within range of waterlvl/bar by summing.
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
    ykw = aicx(kw);
    ykm = aicx(km);

    % Question: is cp (truth) within spread below the waterlvl?
    % --have since written waterlvlsalpha which does both concurrently.
    for j = 1:length(alphas)
        [xl_km(j),xr_km(j)] = waterlvlalpha(aicx,alphas(j),km,restrikt);
        [xl_kw(j),xr_kw(j)] = waterlvlalpha(aicx,alphas(j),kw,restrikt);
    end
    
    % Keep track of the spread; I want to know how an alpha corresponds to
    % a sample spread. Sum them all up and then divide by iters for an
    % average of the spread at each alpha.  Add 1 to x(right) -
    % x(left) because if they are the same sample the test sees 1
    % sample, not zero samples.
    km_range = km_range + (xr_km - xl_km + 1);
    kw_range = kw_range + (xr_kw - xl_kw + 1);

    % If truth within range returned by waterlvl/bar, add +1 to
    % the total count (rhs after '+' will be 1 if true).
    km_count = km_count + (xl_km <= cp & cp <= xr_km);
    kw_count = kw_count + (xl_kw <= cp & cp <= xr_kw);
end

% Average range of samples spanned by each test.
km_range = km_range ./ iters;
kw_range = kw_range ./ iters;

% Plot it, maybe.
if plt
    f1 = plotcpm2(alphas,cp,aicx,km,ykm,kw,ykw,restrikt);
    [f2,f3] = plotcpm2s(alphas,km_count,kw_count,iters,km_range,kw_range);
end

% Collect output.
varns = {km_count,kw_count,km_range,kw_range,f1,f2,f3};
varargout = varns(1:nargout);


