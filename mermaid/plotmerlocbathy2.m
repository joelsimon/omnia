 function plotmerlocbathy2
close all

g = readgps;
g = g.P008;
lat = g.lat;
lon = g.lon;
% Convert longitudes to 0:360 convention:
lon(find(lon<0)) = lon(find(lon<0)) + 360

duration = g.duration;

scatter(lon, lat, [], 'w');
xl = xlim
yl = ylim
close

ax_bathy = axes;
[ax_bathy, cb_bathy] = plotsouthpacificbathy(yl, xl)
cb_bathy.Location = 'EastOutside';
set(ax_bathy, 'Visible', 'off');

fig2print(gcf, 'flandscape')

%%______________________________________________________________________________________%%
ax_mer = axes;

days_deployed = days(duration)
cmap = jet(length(days_deployed));
[col, cbticks, cbticklabels] = x2color(days_deployed, [], [], cmap, false);

sc = scatter(ax_mer, lon, lat, [], col, 'Filled');

colormap(ax_mer, cmap)
cb_mer = colorbar(ax_mer, 'Location', 'SouthOutside');
last_day_tick = floor(days_deployed(end) / 100) * 100;
days2mark = [0:100:last_day_tick];
ticks2keep = nearestidx([cbticklabels{:}], days2mark);
cb_mer.Ticks = cbticks(ticks2keep);
% Really it's this -- cb_mer.TickLabels = cbticklabels(ticks2keep),
% but we can get away with some rounding --
cb_mer.TickLabels = num2cell(days2mark);
cb_mer.Label.Interpreter = 'LaTeX';
cb_mer.Label.String = 'Days since deployment';

xlabel(ax_mer, 'Longitude');
ylabel(ax_mer,'Latitude');

set(ax_mer, 'Position', ax_bathy.Position, 'Color', 'None', 'DataAspectRatio', [1 1 1]);

keyboard
%%______________________________________________________________________________________%%





