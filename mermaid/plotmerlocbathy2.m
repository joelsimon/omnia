function plotmerlocbathy2(name)
% PLOTMERLOCBATHY2(name)

% Defaults
defval('name', 'P008')

close all

ax_fs = 13;
cb_fs = 10;

% Read GPS points for requested MERMAID.
mer = readgps;
mer = mer.(name);
lat = mer.lat;
lon = mer.lon;
% Convert longitudes to 0:360 convention:
lon(find(lon<0)) = lon(find(lon<0)) + 360;
locdate = mer.locdate;
cum_days = [0 ; cumsum(days(diff(locdate)))];

%%______________________________________________________________________________________%%
%% (1) Plot bathymetric base map one separate axis
%%______________________________________________________________________________________%%

% Let MATLAB determine the x/ylims of the ultimate basemap: scatter the data then delete the plot.
scatter(lon, lat, [], 'w');
xl = xlim;
yl = ylim;
close

% Plot the basemap on the newly-determined lon/latitude limits.
ax_bathy = axes;
[ax_bathy, cb_bathy] = plotsouthpacificbathy(yl, xl);

% Base map cosmetics.
cb_bathy.Location = 'EastOutside';
cb_bathy.FontSize = ax_fs;
cb_bathy.Label.FontSize = ax_fs;
cb_bathy.Label.Interpreter = 'LaTeX';
cb_bathy.TickDirection = 'Out';

% Turn off base map axis labels.
set(ax_bathy, 'Visible', 'off');

if diff(xl) > diff(yl)
    fig2print(gcf, 'flandscape')

else
    fig2print(gcf, 'fportrait')

end
%%______________________________________________________________________________________%%
%% (2) Overlay MERMAID drift tracks in separate transparent axis
%%______________________________________________________________________________________%%

ax_mer = axes;

% Figure out color map based on drift duration for scatter plot.
cmap = jet(length(cum_days));
colormap(ax_mer, cmap)
[col, cbticks, cbticklabels] = x2color(cum_days, [], [], cmap, false);

% Scatter the data.
sc = scatter(ax_mer, lon, lat, [], col, 'Filled');

% Adjust the colorbar ticklabels.
cb_mer = colorbar(ax_mer, 'Location', 'SouthOutside');
last_day_tick = floor(cum_days(end)/100) * 100;
days2mark = [0:100:last_day_tick];
ticks2keep = nearestidx([cbticklabels{:}], days2mark);
cb_mer.Ticks = cbticks(ticks2keep);
% Really it's this -- cb_mer.TickLabels = cbticklabels(ticks2keep),
% but we can get away with some rounding --
cb_mer.TickLabels = days2mark;

% Drift-track costmetics.
cb_mer.Label.String = 'Days since deployment';
cb_mer.FontSize = ax_fs;
cb_mer.Label.FontSize = ax_fs;
cb_mer.Label.Interpreter = 'LaTeX';
cb_mer.TickDirection = 'Out';

xlabel(ax_mer, 'Longitude');
ylabel(ax_mer,'Latitude');

% Keep only integer degrees (to not muck up next part)
ax_mer.XTick = ax_mer.XTick(find(isint(ax_mer.XTick)));
ax_mer.YTick = ax_mer.YTick(find(isint(ax_mer.YTick)));

% Covert longitude back to GPS convention for XLabels.
lonlabels = ax_mer.XTick;
lonlabels(ax_mer.XTick>=180) = lonlabels(ax_mer.XTick>=180) - 360;
latlabels = ax_mer.YTick;

ax_mer.XTickLabels = compose('%d', lonlabels);
ax_mer.YTickLabels = compose('%d', latlabels);

% Add LaTeX-ready degree symbols to lat/lon ticklabels.
ax_mer.XTickLabels = cellfun(@(xx) [xx '$^{\circ}$'], ax_mer.XTickLabels, 'UniformOutput', false);
ax_mer.YTickLabels = cellfun(@(xx) [xx '$^{\circ}$'], ax_mer.YTickLabels, 'UniformOutput', false);

axesfs(gcf, ax_fs, ax_fs)
latimes(gcf)

set(ax_mer, 'Position', ax_bathy.Position,  ...
            'XLim', ax_bathy.XLim, ...
            'YLim', ax_bathy.YLim, ...
            'DataAspectRatio', ax_bathy.DataAspectRatio, ...
            'TickDir', 'Out', 'Box', 'on', 'Color', 'None')
