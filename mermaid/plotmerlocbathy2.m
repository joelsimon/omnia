 function plotmerlocbathy2
close all

ax_fs = 13;
cb_fs = 10;

g = readgps;
g = g.P008;
lat = g.lat;
lon = g.lon;
% Convert longitudes to 0:360 convention:
lon(find(lon<0)) = lon(find(lon<0)) + 360;
%%______________________________________________________________________________________%%
%% (1) Plot bathymetric base map one separate axis
%%______________________________________________________________________________________%%

duration = g.duration;

scatter(lon, lat, [], 'w');
xl = xlim;
yl = ylim;
close

ax_bathy = axes;
[ax_bathy, cb_bathy] = plotsouthpacificbathy(yl, xl);
cb_bathy.Location = 'EastOutside';
cb_bathy.FontSize = ax_fs;
cb_bathy.Label.FontSize = ax_fs;
cb_bathy.Label.Interpreter = 'LaTeX';


set(ax_bathy, 'Visible', 'off');

fig2print(gcf, 'flandscape')

%%______________________________________________________________________________________%%
%% (2) Overlay MERMAID drift tracks in separate transparent axis
%%

ax_mer = axes;

% Figure out color map based on drift duration for scatter plot.
days_deployed = days(duration);
cmap = jet(length(days_deployed));
[col, cbticks, cbticklabels] = x2color(days_deployed, [], [], cmap, false);

% Scatter the data.
sc = scatter(ax_mer, lon, lat, [], col, 'Filled');

% Adjust the 
colormap(ax_mer, cmap)
cb_mer = colorbar(ax_mer, 'Location', 'SouthOutside');
last_day_tick = floor(days_deployed(end) / 100) * 100;
days2mark = [0:100:last_day_tick];
ticks2keep = nearestidx([cbticklabels{:}], days2mark);
cb_mer.Ticks = cbticks(ticks2keep);
% Really it's this -- cb_mer.TickLabels = cbticklabels(ticks2keep),
% but we can get away with some rounding --
cb_mer.TickLabels = num2cell(days2mark);
cb_mer.Label.String = 'Days since deployment';
cb_mer.FontSize = ax_fs;
cb_mer.Label.FontSize = ax_fs;
cb_mer.Label.Interpreter = 'LaTeX';

xlabel(ax_mer, 'Longitude');
ylabel(ax_mer,'Latitude');

set(ax_mer, 'Position', ax_bathy.Position, 'Color', 'None', 'DataAspectRatio', [1 1 1], 'Box', 'on');

axesfs(gcf, ax_fs, ax_fs)
latimes(gcf)


keyboard
%%______________________________________________________________________________________%%





