function fig1
% FIG1
%
% Plots global and regional station maps with MERMAID locations.
%
% Developed as: $SIMON2020_CODE/simon2020_globalstations.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 11-Mar-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

% The savefile lives in the same folder of this mfilename.
savefile = fullfile(getenv('GJI21_CODE'), 'data', 'globalstations.mat');
fprintf('\nLoading (large) %s...\n\n', strippath(savefile))
load(savefile, 's')

f.f = figure;
f.ha = gca;
clc

% Plot the continents.
c11 = [-20 90];
cmn = [340 -90];
[~, lola] = maprotate([], [c11 cmn]);
p = plot(lola(:,1), lola(:,2), 'k');
set(f.ha, 'DataAspectRatio', [1 1 1]);

% Plot the plate boundaries.
[plat, plon] = plateboundaries(c11(1));

hold(f.ha, 'on')
plateColor = [0.6 0.6 0.6];
plp = plot(f.ha, plon, plat, 'Color', plateColor);

%% ___________________________________________________________________________ %%
%% Average the plate-boundary lines where they were wrapped so that they lines
%% extend completely to the edges.

% Indices of last/first legit values at the left and right edges of the map.
% (left/right pairs should be connected but are split by a NaN for the wrap).
left = [59 103 269 393];
right = [61 101 267 391];

% Compute the slope between each pair, useful to compute an average at the edge.
rise = plat(right) - plat(left);    % latitude diff
run = plon(left)+360 - plon(right); % longitude diff
slope = rise./run;                  % latitude / longitudge

% Compute the distance from the last legit point the edge.
run_left = -20 - plon(left);

% Compute the latitude at the left edge (which is the same at the right edge),
% hence we only need to do this once.
edge_plat = plat(left) - slope.*run_left;

% Left longitude/latitude matrices.
left_plon = [repmat(-20, size(edge_plat)) plon(left)];
left_plat = [edge_plat plat(left)];

% Right longitude/latitude matrices.
right_plon = [plon(right) repmat(340, size(edge_plat))];
right_plat = [plat(right) edge_plat];

for i = 1:length(left_plon)
    % Line to left edge.
    plot(left_plon(i,:), left_plat(i,:), 'Color', plateColor);

    % Line to right edge.
    plot(right_plon(i,:), right_plat(i,:), 'Color', plateColor);

end

%% ___________________________________________________________________________ %%

% Figure 1 uses FJS plotcont.m, where longitude goes from 0:360
% degrees, ergo must add 360 degrees to any negative longitudes.
lon = [s.Longitude];
lat = [s.Latitude];
lon(find(lon<0)) = lon(find(lon<0)) + 360;

% Then wrap those longitudes that are greater than 340 (map starts at -20).
lon(find(lon>340)) = lon(find(lon>340)) - 360;
f.pl = plot(f.ha, lon, lat, 'v', 'MarkerFaceColor', 'blue', ...
             'MarkerEdgeColor', 'blue', 'MarkerSize', 0.1);

f.ha.XLim = [-20 340];
f.ha.YLim = [-90 90];

f.ha.XTick = [-20:20:340];
f.ha.YTick = [-90:30:90];

set(f.ha, 'XTickLabels', {'' ...
                    '0$^{\circ}$'  ...
                    '' ...
                    '' ...
                    '60$^{\circ}$' ...
                    '' ...
                    ''  ...
                    '120$^{\circ}$'  ...
                    ''  ...
                    '' ...
                    '180$^{\circ}$' ...
                    ''  ...
                    ''  ...
                    '-120$^{\circ}$'  ...
                    '' ...
                    ''  ...
                    '-60$^{\circ}$'  ...
                    ''  ...
                    ''})

set(f.ha, 'YTickLabels', {'-90$^{\circ}$' ...
                    '-60$^{\circ}$' ...
                    '-30$^{\circ}$' ...
                    '0$^{\circ}$' ...
                    '30$^{\circ}$' ...
                    '60$^{\circ}$' ...
                    '90$^{\circ}$'})


xlabel(f.ha, 'Longitude');
ylabel(f.ha, 'Latitude');

latimes
longticks(f.ha, 2)
axesfs(f.f, 7, 9)
botz(plp)
grid on
f.ha.LineWidth = 0.5;
f.ha.GridAlpha = .075;

% Get the locations of all floats at the time of their deployment.
datadir = fullfile(getenv('SIMON2020_CODE'), 'data');
str = readtext(fullfile(datadir, 'misalo.txt'));

% Assuming this file is sorted...
P008_idx = cellstrfind(str, 'P008')';
P025_idx = cellstrfind(str, 'P025')';

Princeton_idx = P008_idx:P025_idx;
all_idx = 1:length(str);

other_idx = setdiff(all_idx, Princeton_idx);

mlat = cellfun(@(xx) str2double(xx(31:40)), str);
mlon = cellfun(@(xx) str2double(xx(43:53)), str);

% Again, map longitudes to plotcont.m convention.
mlon(find(mlon<0)) = mlon(find(mlon<0)) + 360;
mlon(find(mlon>340)) = mlon(find(mlon>340)) - 360;

% Add "nearby" box
hold(f.ha, 'on')
f.pl_left = plot(f.ha, [176 176], [4 -33], 'k-', 'LineWidth', 0.5);
f.pl_right = plot(f.ha, [251 251], [4 -33], 'k-', 'LineWidth', 0.5);
f.pl_top = plot(f.ha, [176 251], [4 4], 'k-', 'LineWidth', 0.5);
f.pl_bottom = plot(f.ha, [176 251], [-33 -33], 'k-', 'LineWidth', 0.5);
botz([f.pl_left f.pl_right f.pl_top f.pl_bottom]);

% Plot MERMAIDs.
f.pl_other = plot(f.ha, mlon(other_idx), mlat(other_idx), ...
                   'v', 'MarkerFaceColor', [0.6 0.6 0.6], 'MarkerEdgeColor', ...
                   'k', 'MarkerSize', 5);
f.pl_Princeton = plot(f.ha, mlon(Princeton_idx), mlat(Princeton_idx), ...
                       'v', 'MarkerFaceColor', porange, 'MarkerEdgeColor', ...
                       'k', 'MarkerSize', 6);

topz([f.pl_other f.pl_Princeton])

hold(f.ha, 'off')
axesfs(f.f, 7, 7)
tx = text(-50, 100, '(a)', 'Interpreter', 'LaTex', 'FontName', 'Times');
tx.FontSize = 1.25*8;
savepdf('fig1a')

% Zoom in on the area of interest.
xlim([176-10 251+10])
ylim([-33-10 4+10])

f.pl.MarkerSize = 2;
f.pl_other.MarkerSize = 10;
f.pl_Princeton.MarkerSize = 12;

xticks([165:10:260])
yticks([-40:10:10])

set(f.ha, 'XTickLabels', {'165$^{\circ}$' ...
                    '175$^{\circ}$'  ...
                    '-175$^{\circ}$' ...
                    '-165$^{\circ}$' ...
                    '-155$^{\circ}$' ...
                    '-145$^{\circ}$' ...
                    '-135$^{\circ}$' ...
                    '-125$^{\circ}$' ...
                    '-115$^{\circ}$' ...
                    '-105$^{\circ}$'})


set(f.ha, 'YTickLabels', {'-40$^{\circ}$' ...
                    '-30$^{\circ}$' ...
                    '-20$^{\circ}$' ...
                    '-10$^{\circ}$' ...
                    '0$^{\circ}$' ...
                    '10$^{\circ}$'})

tx.Position = [156 16];
tx.String = '(b)';
axesfs(f.f, 1.4*7, 1.4*7)
tx.FontSize = 1.4*1.25*8;
savepdf('fig1b')
