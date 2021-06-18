function fig3
% FIG3
%
% Plots the first five dives of P012 using html2dive.mat, compiled by Frederik
% J. Simons using his html2dive.m (which does not perform as expected on Mac
% and/or my version of MATLAB); this just adds some formatting using data he
% sent.
%
% Developed as: $SIMON2020_CODE/simon2020_dive.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 19-Mar-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

datadir = fullfile(getenv('GJI21_CODE'), 'data');

% NB, I believe Frederik scp'd the following 'html2dive.mat' to me; it is not in
% any emails.  I sent him back html2dive2.mat, which is a different experiment
% and not a remake of this same file used here.
load(fullfile(datadir, 'html2dive.mat'))

ax = axes;
fig2print([], 'flandscape')

hold on
for i = 1:length(x)
    pl(i) = plot(x{i}, y{i}, '-o', 'MarkerSize', 5);
    pl(i).MarkerFaceColor = pl(i).Color;
    tx(i) = text(x{i}(1), 75, sprintf('Dive: %i', i), 'HorizontalAlignment', ...
                 'Left', 'Color', pl(i).Color);

end
ylim([-1600 200])
yticks([-1500:300:0])

% Make down positive, in keeping with depth convetion.
ax.YAxis.TickLabels = strrep(ax.YAxis.TickLabels, '-', '')
box on
longticks([], 2)
grid on
shrink([], 1, 3)
ylabel('Depth (m)')

axesfs([], 10, 10)

% Remove year stamp.
ha = gca;
ha.XTickLabel = ha.XTickLabel;

xlabel('Calendar date in 2018')
latimes
savepdf('fig3')
