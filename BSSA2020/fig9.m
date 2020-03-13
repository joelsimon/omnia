% Figure 9
%
% Cite: Simon, J. D. et al., (2020), BSSA, doi: 10.1785/0120190173
%
% plotcpm22.m (a local version) with some formatting.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 22-May-2018, Version 2017b

% VERY ODD BEHAVIOR: I've had trouble with the sizing of this plot;
% sometimes it is sized correctly and sometimes not. I assumes it was
% due to horzline, but even after hardcoding it as last step at end I
% still have odd behavior. You may have to close and reopen matlab
% before running this. I find that if a sessions is already running
% this may not output correctly.

clear
close all

% This probably shouldn't be changed from true, but just so we know
% it's here; we are using the BIASED the sample variance, normalized
% by N, not N-1, because that's what falls out of the math.
bias = true;

% I want to control exactly what x is plotted on zoom in, so I'm
% loading a static x that has same parameters but looks pretty zoomed.
load 'Static/x_01_0sqrt2.mat'
alphas = [0:10];
lvls = [0 3 6];

% Run cpest.m on the STATIC x time series.
[kw, km, aicx] =  cpest(x, 'fast', false, bias);

% Run basic plotting function.
f = plotcpm2_both_local(alphas, bp, aicx, km, kw, lvls);

% And simply update the axes and marker sizes.

if bias == true
    % biased variance estimate
    f.ha.YLim = [375 400];
    f.th_km(1).Position(2) = 375.7;
    f.th_km(2).Position(2) = 377.3;

else
    % unbiased variance estimate.
    f.ha.YLim = [376 402];
    f.th_km(2).Position(2) = 379.2;

end

f.ha.XLim = [460 540];
f.plaicx_circ.MarkerSize = 4;

f.th_km(1).Position(1) = f.th_km(1).Position(1) - 16;
f.th_km(2).Position(1) = f.th_km(2).Position(1) - 16;
f.th_km(3).Position(1) = f.th_km(3).Position(1) - 16;

f.th_kw(1).Position(1) = f.th_kw(1).Position(1) + 2;
f.th_kw(2).Position(1) = f.th_kw(2).Position(1) + 2;
f.th_kw(3).Position(1) = f.th_kw(3).Position(1) + 2;

f.bxt.Position = [524.5 378 2];

f.bx.Visible = 'on';
f.bx.Vertices =   [512   377     1;
                   512   379     1;
                   537   379     1;
                   537   377     1];

grid on
latimes
axesfs(f.f, 9, 13)
f.lg.FontSize = 10;
f.bxt.FontSize= 10;

hold(gca, 'on')
plot([460 540], [aicx(bp) aicx(bp)], 'k')
hold(gca,'off')

% Save it.
if bias == true
    warning('bias is TRUE, normalized by 1/N')
    savepdf(mfilename)
else
    warning('bias is FALSE, normalized by 1/(N-1)')
    savepdf([mfilename '_unbiased'])
end

%__________________________________________________________________%
function f = plotcpm2_both_local(alphas, bp, aicx, km, kw, lvls)
%
% Plots plotcpm2.m for both RESTRICTED and UNRESTRICTED alpha tests.
%
% Plots the output of one test iteration of cpm2 -- zoom-in on aicx,
% highlighting some alpha levels above the changepoint estimators. Will
% definitely require some massaging of the alphalvl string positions.
%
% Inputs:
% alphas        Alpha levels (percentages) to test (def)
% bp            True changepoint of model which generated aicx
% aicx          Output of cpest.m
% kw            Changepoint estimate: weighted average of Akaike weights
% km            Changepoint estimate: x index of AIC global minimum
%
% Output:
% f             Struct of figure's handles and bits
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
% put everything in a structure.  Overwrite km, kw to km/kw.bp for
% "changepoint."
tmp = km;
clear km;
km.bp = tmp;

tmp = kw;
clear kw;
kw.bp = tmp;

clear tmp;

% Set up figure and plot the AIC function.
f.f = figure;
fig2print(gcf, 'landscape')
f.ha = gca;

% Y-values of AIC function at changepoint estimates
ykm = aicx(km.bp);
ykw = aicx(kw.bp);

% Plot the AIC curve, true changepoint, and both estimators.
hold on
f.plaicx_line = plot(aicx, 'k');
f.plaicx_circ = plot(aicx, 'o', 'Color', 'k', 'MarkerFaceColor', 'w');

f.pl_km = plot(km.bp, ykm, 'bo', 'MarkerFaceColor', 'b');
f.pl_kw = plot(kw.bp, ykw, 'ro', 'MarkerFaceColor', 'r');

ytru = aicx(bp);
f.pl_tru = plot(bp, ytru, 'ko', 'MarkerFaceColor', 'k');
%f.vl_tru = vertline(bp, [], 'k');
hold off

% Plot some example waterlvls.
for i = 1:length(lvls)
    [km.xl_ur(i), km.xr_ur(i), km.xl_r(i), km.xr_r(i), km.y_exact(i)] ...
        = waterlvlsalpha(aicx, lvls(i), km.bp);
    km.yl_ur(i) = aicx(km.xl_ur(i));
    km.yr_ur(i) = aicx(km.xr_ur(i));
    km.yl_r(i) = aicx(km.xl_r(i));
    km.yr_r(i) = aicx(km.xl_r(i));

    [kw.xl_ur(i), kw.xr_ur(i), kw.xl_r(i), kw.xr_r(i), kw.y_exact(i)] ...
        = waterlvlsalpha(aicx, lvls(i), kw.bp);
    kw.yl_ur(i) = aicx(kw.xl_ur(i));
    kw.yr_ur(i) = aicx(kw.xr_ur(i));
    kw.yl_r(i) = aicx(kw.xl_r(i));
    kw.yr_r(i) = aicx(kw.xl_r(i));

    % Plot the levels: restricted first; if unrestricted is broader, plot
    % second with different linestyle.
    hold on
    f.hl_km_r(i) = plot([km.xl_r(i) km.xr_r(i)], [km.y_exact(i) ...
                        km.y_exact(i)], 'b-');

    f.hl_kw_r(i) = plot([kw.xl_r(i) kw.xr_r(i)], [kw.y_exact(i) ...
                        kw.y_exact(i)], 'r-');

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
                              'b--');
    end

    if diff(km.right{i}) ~= 0
        % Unrestricted, right (urr)
        f.hl_km_urr(i) = plot(km.right{i}, [km.y_exact(i) km.y_exact(i)], ...
                              'b--');
    end
    %%

    %% kw
    if diff(kw.left{i}) ~= 0
        % Unrestricted, left (url)
        f.hl_kw_url(i) = plot(kw.left{i}, [kw.y_exact(i) kw.y_exact(i)], ...
                              'r--');
    end

    if diff(kw.right{i}) ~= 0
        % Unrestricted, right (urr)
        f.hl_kw_urr(i) = plot(kw.right{i}, [kw.y_exact(i) kw.y_exact(i)], ...
                              'r--');
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
    tstr_km = sprintf('$\\beta(k_\\mathrm{m},%i\\%s)$', lvls(i), '%');
    tstr_kw = sprintf('$\\beta(k_\\mathrm{w},%i\\%s)$', lvls(i), '%');

    f.th_km(i) = text(km.xl_ur(i), km.y_exact(i), gca, tstr_km, 'Interpreter', 'Latex');

    f.th_kw(i) = text(kw.xr_ur(i), kw.y_exact(i), gca, tstr_kw, 'Interpreter', 'Latex');

    f.th_km(i).Color = 'b';
    f.th_kw(i).Color = 'r';
end

% Use the largest waterlvl for the recentering (it has largest spread)
% -- (largest will be last waterlvl of kw because it is at least at or
% above km, always).
maxdiff = kw.xr_ur(end) - kw.xl_ur(end);
lx = length(aicx);
xliml = max((bp-maxdiff) - (0.01*lx),1);
xlimr = min((bp+maxdiff) + (0.01*lx),lx);
xlim([xliml xlimr]);
rangex = range(aicx(isfinite(aicx)));

% Labels and legend
f.xl = xlabel('Sample index $k$', 'Interpreter', 'Latex');
f.yl = ylabel('Akaike information criterion $\mathcal{A}$', 'Interpreter', 'Latex');

[f.bx,f.bxt] = boxtex('lr' ,gca, sprintf('Range$(\\mathcal{A}) = %.1f$',rangex));
f.bxt.Interpreter = 'Latex';
f.bx.Visible = 'off';

lg_entries = [f.pl_tru f.pl_km f.pl_kw];
lg_str = {'$k_{\circ}$','$k_\mathrm{m}$','$k_\mathrm{w}$'};
f.lg = legend(lg_entries, lg_str,  'Location', 'NW', 'Interpreter', ...
              'latex', 'AutoUpdate', 'off');

f.ha.Box = 'on';
f.ha.TickDir = 'out';

% Ensure red and blue points are at top of stack.
topz([f.plaicx_circ f.pl_km f.pl_kw f.pl_tru]);

% And that alpha strings lie above horizontal line.
uistack([f.th_km f.th_kw], 'top')

% Print an output (comment if it bothers)
fprintf('km sample spans--\n')
fprintf('Restricted: ')
km.xr_r - km.xl_r + 1
fprintf('\nUnrestricted: ')
km.xr_ur - km.xl_ur + 1

fprintf('kw sample spans--\n')
fprintf('Restricted: ')
kw.xr_r - kw.xl_r + 1
fprintf('\nUnrestricted: ')
kw.xr_ur - kw.xl_ur + 1

end
