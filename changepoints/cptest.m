function varargout = cptest(alphas, iters, lx, bp, dist1, p1, dist2, ...
                            p2, abso, dtrend, restrikt, bias)
% CPTEST(alphas,iters,lx,bp,dist1,p1,dist2,p2,abso,dtrend,restrikt,bias)
% (many outputs, see example below for full list)
%
% Changepoint Estimator Test: Combines cpm1.m and cpm2.m for one
% 'restrikt' type. Conversely, use cpci.m to test both 'restrikt'
% types for one changepoint. 
%
% CPTEST tests both methods (Method 1 (sample error) and Method 2
% (alpha tests)) for both changepoint estimators, km and kw.  Avoids
% redundant generation of randomized time series (which may not be a
% good thing depending on application, see note below). Returns raw
% output for each test iteration (does not return summary statistics
% like mean and var).  Comments have been removed here for brevity --
% see cpm1/2.m for explanation.
%
% N.B.: CPTEST only tests 1 'restrikt' type; does not test both
% 'unrestricted' and 'restricted' as is done in waterlvlsalpha.m,
% which is called in cpci.m. If both restriction types are required
% run cpm2.m twice.  Also, must consider if appropriate to use same
% time series for both M1 and M2 statistics -- re-randomization by
% calling cpm1.m and cpm2.m (performing the tests on different time
% series) may be more appropriate depending on application.
% 
% I/0: see cpm1/2.m
% 
% Ex:
%    [del_km,del_kw,km_percerr,kw_percerr,km_count,kw_count,km_range,kw_range] ...
%        = CPTEST([0:0.5:20],10,1000,500,'norm',{0 1},'norm',{0 sqrt(2)});
%
% See also: cpm1.m, cpm2.m, cpci.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 16-Mar-2018, Version 2017b

% Defaults.
defval('alphas',[0:.05:5])
defval('iters',1000)
defval('lx',1000)
defval('bp',500)
defval('dist1','norm')
defval('p1',{0 1})
defval('dist2','norm')
defval('p2',{0 2})
defval('abso',false)
defval('dtrend',false)
defval('restrikt',false)

% Initialize.
km_count = zeros(1,length(alphas));
kw_count = km_count;
km_range = km_count;
kw_range = km_count;

% Comments removed for brevity -- cpm1.m & cpm2.m for explanation.
for i = 1:iters
    x = cpgen(lx,bp,dist1,p1,dist2,p2);
    if abso
        x = abs(x);
    end
    [kw, km, aicx] = cpest(x, 'fast', dtrend, bias);
    ykw = aicx(kw);
    ykm = aicx(km);

    % cpm1.m guts.
    if isempty(find(isfinite(aicx)))
        del_km(i) = NaN;
        del_kw(i) = NaN;
        km_percerr(i) = NaN;
        kw_percerr(i) = NaN;
        continue
    end
    ytru = aicx(bp);
    del_km(i) = km - bp;
    del_ykm = ykm - ytru;
    del_kw(i) = kw - bp;
    del_ykw = ykw - ytru;
    aicrange = range(aicx(isfinite(aicx)));
    km_percerr(i) = abs(del_ykm)/aicrange * 100;
    kw_percerr(i) = abs(del_ykw)/aicrange * 100;

    % cpm2.m guts.
    for j = 1:length(alphas)
        [xl_km(j),xr_km(j)] = waterlvlalpha(aicx,alphas(j),km,restrikt);
        [xl_kw(j),xr_kw(j)] = waterlvlalpha(aicx,alphas(j),kw,restrikt);
    end
    km_range = km_range + (xr_km - xl_km);
    kw_range = kw_range + (xr_kw - xl_kw);
    km_count = km_count + (xl_km <= bp & bp <= xr_km);
    kw_count = kw_count + (xl_kw <= bp & bp <= xr_kw);
end
km_range = km_range ./ iters;
kw_range = kw_range ./ iters;

% Collect output both tests.
varns1 = {del_km,del_kw,km_percerr,kw_percerr};
varns2 = {km_count,kw_count,km_range,kw_range};

% Combine final output, including last time series tested.
varns = [varns1 varns2];
varargout = varns(1:nargout);


