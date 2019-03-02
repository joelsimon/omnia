function varargout = cpbias(iters, lx, dist1, p1, dist2, p2, abso, dtrnd, plt, bias);
% [mean_del_km,std_del_km,mean_del_kw,std_del_kw, ...
%  mean_km_percerr,mean_kw_percerr,std_km_percerr,std_kw_percerr,f] = ...
%     cpbias(iters,lx,dist1,p1,dist2,p2,abso,dtrnd,plt,bias)
%
% Run cptest.m 'iters' number of times at each sample, k = [1,...,lx],
% in time series.  I.e., slides changepoint all the way along time
% series to test bias at each possible changepoint in a synthetic time
% series.
%
% Essentially this is cpm1.m assuming every index, k, is the truth.
%
% Inputs: (all defaulted)
% iters,...,bias          Inputs to cpm1/2.m, see there 
% plt                     1 to plot (def = 0)
%
% Outputs:
% Outputs of cptest.m, ordered as array indexed at every changepoint
%
% Ex: Slide true changepoint along length 10 time series
%    CPBIAS(10,100,[],[],[],[],false,false,true,true)
%
% See also: cptest.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 07-Mar-2018, Version 2017b

% Defaults
defval('iters',1000)
defval('lx',1000)
defval('dist1','norm')
defval('p1',{0 1})
defval('dist2','norm')
defval('p2',{0 2})
defval('abso',0)
defval('dtrnd',0)
defval('plt',0)
defval('f',[])

% Allocate.
mean_del_km = NaN(1,lx);
mean_del_kw = mean_del_km;
std_del_km = mean_del_km;
std_del_kw = mean_del_km;
mean_km_percerr = mean_del_km;
mean_kw_percerr = mean_del_km;
std_km_percerr = mean_del_km;
std_kw_percerr = mean_del_km;

% Run cptest.m, sliding changepoint along each index of
% signal. Calculate statistics for error of min and changepoint guess.
parfor cp = 1:lx-1
    % Force never to plot in cptest.m; do that separately below (don't
    % want 1000 individual cptest.m plots...)
    [km, kw, mp, tp] = cptest([],iters,lx,cp,dist1,p1,dist2,p2,abso,dtrnd,[],bias);
    
    mean_del_km(cp) = mean(km(isfinite(km)));
    mean_del_kw(cp) = mean(kw(isfinite(km)));
    
    std_del_km(cp) = std(km(isfinite(km)));
    std_del_kw(cp) = std(kw(isfinite(kw)));
    
    mean_km_percerr(cp) = mean(mp(isfinite(mp)));
    mean_kw_percerr(cp) = mean(tp(isfinite(tp)));
    
    std_km_percerr(cp) = std(mp(isfinite(mp)));
    std_kw_percerr(cp) = std(tp(isfinite(tp)));
end

% Plot mean of experiment at every changepoint with
% std. spread, maybe
if plt
    f = figure;
    fig2print(f,'landscape')
    pmin = plot(1:2:lx,mean_del_km(1:2:lx),'ko','MarkerSize',2, ...
                'MarkerFaceColor','k');
    hold on
    pkw = plot(2:2:lx,mean_del_kw(2:2:lx),'ro','MarkerSize',2, ...
                'MarkerFaceColor','r');
    ax = f.Children;
    hold on

    % Alternate plotting of km/kw guess to avoid clutter.  Concatenate x
    % and y values from two experiments so you can plot without a loop
    % (otherwise have to loop over every cp)
    xs = [[1:lx];[1:lx]];
    ys_km = [[mean_del_km - std_del_km];[mean_del_km + std_del_km]];
    ys_kw = [[mean_del_kw - std_del_kw];[mean_del_kw + std_del_kw]];
    pkm_std = plot(xs(:,1:2:lx),ys_km(:,1:2:lx),'k');
    pkw_std = plot(xs(:,2:2:lx),ys_kw(:,2:2:lx),'r');


    % Cosmetics.
    % Plot fake points for legend -- in 2017 this now add ghost
    % 'data'. Fix at some point.
    lg_km = plot(NaN,NaN,'k-o','MarkerFaceColor','k','MarkerSize',2);
    lg_kw = plot(NaN,NaN,'r-o','MarkerFaceColor','r','MarkerSize',2);
    axis tight
    tl = title('AIC test bias','FontSize',18,'FontWeight','normal');
    xl = xlabel('index of changepoint','FontSize',14,'FontWeight','normal');
    yl = ylabel('sample bias: positive is late','FontSize',14,...
                'FontWeight','normal');
    hl = horzline(0,ax,'k');
    hl{1}.LineWidth = 1;
    longticks(gca,4)
    legend(ax,[lg_km lg_kw], {['mean and std. of sample error of ' ...
                        'changepoint estimates via global minimum'], ...
                        ['mean and std. of sample error of changepoint ' ...
                        'estimates via weighted average']}, ...
           'AutoUpdate', 'off')
    [bx,tx] = boxtex('lr',gca,sprintf(...
        'n = %i %s per changepoint tested',...
        iters,plurals('iteration',iters)),12);
    bx.Visible = 'off';
    movev(tl,2)
end

% Collect output 
varns = {mean_del_km,std_del_km,mean_del_kw,std_del_kw, ...
         mean_km_percerr,mean_kw_percerr,std_km_percerr, ...
         std_kw_percerr,f};
varargout = varns(1:nargout);




