function f = plotcpm22(alphas, cp, aicx, km, kw, lvls)
% f = PLOTCPM22(alphas, cp, aicx, km, kw, lvls)
%
% Plots plotcpm2.m for both RESTRICTED and UNRESTRICTED alpha tests.
%
% Plots the output of one test iteration of cpm2 -- zoom-in on aicx,
% highlighting some alpha levels above the changepoint estimators. Will
% definitely require some massaging of the alphalvl string positions.
%
% Inputs:      
% alphas        Alpha levels (percentages) to test (def)
% cp            True changepoint of model which generated aicx
% aicx          Output of cpest.m
% kw            Changepoint estimate: weighted average of Akaike weights
% km            Changepoint estimate: x index of AIC global minimum 
% lvls          Array specifying alpha lvls to be plotted (optional)
%
% Output: 
% f             Struct of figure's handles and bits
%
% Ex: True cp at index 500 of length 1000 time series
%    cp = 500;
%    [kw,km,aicx] = cpest(cpgen(1000,cp));
%    f = PLOTCPM22([0:2:10],cp,aicx,km,kw,[0:2:10])
%
% See also: cpm2.m, plotcpm2.m, contiguous.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 23-Apr-2018, Version 2017b

% Demo, maybe.
if ischar(alphas)
    demo
    return
end

% Default to plot 4 equally spaced alpha lvls.
defval('lvls',linspace(0,max(alphas),4))

% Because we do two cases with two changepoint estimators, easier to
% put everything in a structure.  Overwrite km, kw to km/kw.cp for
% "changepoint."
tmp = km; 
clear km;
km.cp = tmp;

tmp = kw; 
clear kw;
kw.cp = tmp;

clear tmp;

% Set up figure and plot the AIC function.
f.f = figure;
fig2print(gcf, 'landscape')
f.ha = gca;

% Y-values of AIC function at changepoint estimates
ykm = aicx(km.cp);
ykw = aicx(kw.cp);

% Plot the AIC curve, true changepoint, and both estimators.
hold on
f.plaicx_line = plot(aicx, 'k');
f.plaicx_circ = plot(aicx, 'o', 'Color', 'k', 'MarkerFaceColor', 'w');

f.pl_km = plot(km.cp, ykm, 'bo', 'MarkerFaceColor', 'b');
f.pl_kw = plot(kw.cp, ykw, 'ro', 'MarkerFaceColor', 'r');

ytru = aicx(cp);
f.pl_tru = plot(cp, ytru, 'ko', 'MarkerFaceColor', 'k');
hold off

% Plot some example waterlvls.
for i = 1:length(lvls)
    [km.xl_ur(i), km.xr_ur(i), km.xl_r(i), km.xr_r(i), km.y_exact(i)] ...
        = waterlvlsalpha(aicx, lvls(i), km.cp);
    km.yl_ur(i) = aicx(km.xl_ur(i));
    km.yr_ur(i) = aicx(km.xr_ur(i));
    km.yl_r(i) = aicx(km.xl_r(i));
    km.yr_r(i) = aicx(km.xl_r(i));

    [kw.xl_ur(i), kw.xr_ur(i), kw.xl_r(i), kw.xr_r(i), kw.y_exact(i)] ...
        = waterlvlsalpha(aicx, lvls(i), kw.cp);
    kw.yl_ur(i) = aicx(kw.xl_ur(i));
    kw.yr_ur(i) = aicx(kw.xr_ur(i));
    kw.yl_r(i) = aicx(kw.xl_r(i));
    kw.yr_r(i) = aicx(kw.xl_r(i));

    % Plot the levels: restricted first; if unrestricted is broader, plot
    % second with different linestyle.
    hold on
    f.hl_km_r(i) = plot([km.xl_r(i) km.xr_r(i)], [km.y_exact(i) ...
                        km.y_exact(i)], 'b--');

    f.hl_kw_r(i) = plot([kw.xl_r(i) kw.xr_r(i)], [kw.y_exact(i) ...
                        kw.y_exact(i)], 'r--');

    % Any extra samples, maybe seen in unrestricted test.
    km.left{i} = [km.xl_ur(i)  km.xl_r(i)];
    km.right{i} = [km.xr_r(i)  km.xr_ur(i)];

    kw.left{i} = [kw.xl_ur(i)  kw.xl_r(i)];
    kw.right{i} = [kw.xr_r(i)  kw.xr_ur(i)];


    % Plot excess samples, maybe.
    %% km
    if diff(km.left{i}) ~= 0
        % Unrestricted, left (url)
        f.hl_km_url(i) = plot(km.left{i}, [km.y_exact(i) km.y_exact(i)], ...
                              'b:');
    end

    if diff(km.right{i}) ~= 0
        % Unrestricted, right (urr)
        f.hl_km_urr(i) = plot(km.right{i}, [km.y_exact(i) km.y_exact(i)], ...
                              'b:');
    end
    %%

    %% kw
    if diff(kw.left{i}) ~= 0
        % Unrestricted, left (url)
        f.hl_kw_url(i) = plot(kw.left{i}, [kw.y_exact(i) kw.y_exact(i)], ...
                              'r:');
    end

    if diff(kw.right{i}) ~= 0
        % Unrestricted, right (urr)
        f.hl_kw_urr(i) = plot(kw.right{i}, [kw.y_exact(i) kw.y_exact(i)], ...
                              'r:');
    end
    %%


    % Format switch for integer alpha levels (looks cleaner).
    if isint(lvls(i)) == true
        fmt = '%i';
    else
        fmt = '%.1f';
    end
    
    % Add alpha strings: km on left at y-exact value (the waterlevel), kw
    % at right.
    tstr = sprintf(['$\\alpha=' sprintf('%s',fmt) '%s$'], lvls(i), '\%');
    f.th_km(i) = text(km.xl_ur(i), km.y_exact(i), gca, tstr, 'Interpreter', 'Latex');
    f.th_kw(i) = text(kw.xr_ur(i), kw.y_exact(i), gca, tstr, 'Interpreter', 'Latex');
    f.th_km(i).Color = 'b';
    f.th_kw(i).Color = 'r';
end

% Plot horizontal line at Y-value at true changepoint.
f.hl_tru = horzline(ytru, [], 'k');

% Use the largest waterlvl for the recentering (it has largest spread)
% -- (largest will be last waterlvl of kw because it is at least at or
% above km, always).
maxdiff = kw.xr_ur(end) - kw.xl_ur(end);
lx = length(aicx);
xliml = max((cp-maxdiff) - (0.01*lx),1);
xlimr = min((cp+maxdiff) + (0.01*lx),lx);
xlim([xliml xlimr]);
rangex = range(aicx(isfinite(aicx)));

% Labels and legend
f.xl = xlabel('sample index $k$', 'Interpreter', 'Latex');
f.yl = ylabel('$\mathcal{A}$', 'Interpreter', 'Latex');

[f.bx,f.bxt] = boxtex('lr' ,gca, sprintf('range$(\\mathcal{A}) = %.1f$',rangex));
f.bxt.Interpreter = 'Latex';
f.bx.Visible = 'off';

lg_entries = [f.pl_tru f.pl_km f.pl_kw];
lg_str = {'$k_{\circ}$', '$k_m$', '$k_w$',};
f.lg = legend(lg_entries, lg_str,  'Location', 'NW', 'Interpreter', 'latex');

f.ha.Box = 'on';
f.ha.TickDir = 'out';

% Ensure red and blue points are at top of stack.
topz([f.plaicx_circ f.pl_km f.pl_kw f.pl_tru]);

% Print an output.
fprintf('km sample spans--\n')
fprintf('Restricted: ')
km.xr_r - km.xl_r
fprintf('\nUnrestricted: ')
km.xr_ur - km.xl_ur

fprintf('kw sample spans--\n')
fprintf('Restricted: ')
kw.xr_r - kw.xl_r
fprintf('\nUnrestricted: ')
kw.xr_ur - kw.xl_ur
