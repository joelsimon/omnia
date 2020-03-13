% Modified FIGURE 4 using dvar, the difference in sample variances,
% for the reviewer.
%
% Cite: Simon, J. D. et al., (2020), BSSA, doi: 10.1785/0120190173
%
% Plots the theoretical summed log-likelihood value (of an ideal time
% series with normlysmixvals.m), and actual summed log-likelihood
% value of real time series with cpsumly.m, at every k for our
% prototypical model.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 22-Oct-2019, Version 2017b on GLNXA64

clear
close all

% Prototypical defaults.
trusigmas = [1 sqrt(2)];
N = 1000;
ko = 500;

% Set up figure window.
f = figure;
fig2print(f, 'landscape')

%% Data:  cpsumly.m

% Generated synthetic time series and calculate the summed
% log-likelihood curve.
ax = gca;
hold(ax, 'on')
ave_est_dvar = zeros(N,1);
for i = 1:25
    % Generate the synthetic data.
    x = cpgen(1000, 500, 'norm', {0 trusigmas(1)}, 'norm', {0 trusigmas(2)});

    % It's summed log-likelihood curve is obtained with substituting
    % equations 7 and 12 into 15.
    [~, ~, est_dvar] = cpsumly(x);

    % Plot 25 individual estimated lines.
    plest{i} = plot(ax, est_dvar, 'Color', [0.6 0.6 0.6]);
    ave_est_dvar = [ave_est_dvar + est_dvar];
end

% Plot the average of the estimated summed log-likelihoods -- should
% look a lot like true, theoretical ones below (tru_sumly).
ave_est_dvar = ave_est_dvar / 25;

plave = plot(ax, ave_est_dvar, 'k', 'LineWidth', 2);

% Set up color gradient from red to blue depending on mixing percentage.
color_step = linspace(0, 1, N);

%% Theory: normlysmixvals.m

% At every changepoint, k=[1,...,N], calculate theoretical summed
% log-likelihood values depending on amount of mixing, governed by
% difference between k and k0. See normlysmixvals.m
tru_dvar = NaN(N,1);
for k = 2:N-1
    % The marker color for this amount of mixing.
    col = [1-color_step(k) 0 color_step(k)];

    % Theoretical x,y values -- perfect MLE sample variances using
    % equations 32, 34 and substituted into 15.
    [~, ~, tru_dvar(k)] = normlysmixvals(k, trusigmas, N, ko);

    % Plot an individual line object at every sample index so that
    % I can control the color of each object.
    pltru(k) = plot(ax, k, tru_dvar(k), '.', 'Color', col, 'MarkerSize', 5);
end

grid on
grid minor
box(ax, 'on')

% Adjust limits.
xlim(ax, [1 1000]);
xticks(ax, [1 100:100:1000])
ylim(ax, [0 1.5])

% Label axes.
xl = ylabel(ax, '$\sigma_2^2 - \sigma_1^2$')
yl = xlabel(ax, 'Sample index $k$');

% Enlarge points from figures 2,3; correct changepoint and mixing
% changepoints.
set(pltru([250 500 750]), 'MarkerSize', 30)

% Correct the stack order.
z = topz(plave, ax);
set(pltru(2:N-1), 'ZData',  z+1)
set(pltru([250 500 750]), 'ZData',  z+2)

% Mark changepoint and add vertical line.
ko = text(ax, 500, ax.YLim(2)+.05, '$k_{\circ}$');

% Set interpreter to latex, font to 'Times', flip tickdir, make all
% fonts same size.
latimes(f)
axesfs(f, 10, 13)

% Vertline.
plv = plot([500 500], ylim, 'k');
ax.TickDir = 'out';
hold off

% Final stack order correction: vertline above gray data lines;
% central point above vertline.
topz([plv pltru(500)], ax)

savepdf(mfilename)
