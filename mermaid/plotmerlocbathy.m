function plotmerlocbathy(mername, legendloc)
% PLOTMERLOCBATHY(mername, legendloc)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 18-Nov-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults
merpath = getenv('MERMAID');
defval('mername', 'P008')
defval('legendloc', 'SouthEast');
defval('procdir', fullfile(merpath, 'processed'))
defval('evtfile', fullfile(merpath, 'events', 'reviewed', 'all.txt'))

% FontSizes.
ax_fs = 13;
cb_fs = 10;

% Read GPS points for requested MERMAID.
gps = readgps(procdir);
mer = gps.(mername);
lat = mer.lat;
lon = mer.lon;
% Convert longitudes to 0:360 convention:
lon(find(lon<0)) = lon(find(lon<0)) + 360;
locdate = mer.locdate;
cum_days = [0 ; cumsum(days(diff(locdate)))];

% Remove GPS fixes taken by P023 while out of water (on the ship).
if strcmp(mername, 'P023')
    bad_dates = iso8601str2date({'2019-08-17T03:18:29Z' '2019-08-17T03:22:02Z'});
    [~, rm_idx] = intersect(locdate, bad_dates);
    lat(rm_idx) = [];
    lon(rm_idx) = [];
    locdate(rm_idx) = [];
    cum_days(rm_idx) = [];

end

%%______________________________________________________________________________________%%
%% (1) Plot bathymetric base map one separate axis
%%______________________________________________________________________________________%%

% Let MATLAB determine the x/ylims of the ultimate base map: scatter the data then delete the plot.
scatter(lon, lat, [], 'w');
xl = xlim;
yl = ylim;
close

% Plot the base map on the newly-determined lon/latitude limits.
ax_bathy = axes;

% Flip the YLimits because they must go from high to low numbers (southing).
cax = [-7000 1500];
[ax_bathy, cb_bathy] = plotsouthpacificbathy(xl, flip(yl), cax);
cb_bathy.Ticks = [-7000:1000:0 1500];

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
sc = scatter(ax_mer, lon, lat, 75, col, 'Filled', 'MarkerEdgeColor', 'k');

% Adjust the colorbar ticklabels.
cb_mer = colorbar(ax_mer, 'Location', 'SouthOutside');
last_day_tick = floor(cum_days(end)/100) * 100;
days2mark = [0:100:last_day_tick];
ticks2keep = nearestidx([cbticklabels{:}], days2mark);
cb_mer.Ticks = cbticks(ticks2keep);
% Really it's this -- cb_mer.TickLabels = cbticklabels(ticks2keep),
% but we can get away with some rounding --
cb_mer.TickLabels = days2mark;

% Drift-track cosmetics.
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


%%______________________________________________________________________________________%%
%% (3) Overlay station locations at time of seismic recording
%%______________________________________________________________________________________%%

% Read text file of all hits/misses.
[eq_sac, ~, eq_lat] = readevt2txt(evtfile, [], [], 'DET');

% Read text file of interpolated station locations.
loc = readloc(procdir);
loc = loc.(mername);

% Both lists need to trimmed: eqsac because it contains SAC files from other MERMAIDS, loc.sac
% because it contains REQ sac files from this MERMAID
[~, eq_idx, loc_idx] = intersect(eq_sac, loc.sac);

eq_sac = eq_sac(eq_idx);
eq_lat = eq_lat(eq_idx);

loc_sac = loc.sac(loc_idx);
loc_lon = loc.stlo(loc_idx);
% Convert GPS longitudes to 0:360 convection.
loc_lon(find(loc_lon<0)) = loc_lon(find(loc_lon<0)) + 360;
loc_lat = loc.stla(loc_idx);

% Split SAC file list into identified and unidentified sub_lists.
id_idx = ~isnan(eq_lat);
ud_idx = isnan(eq_lat);

id_loc_sac = loc_sac(id_idx);
id_loc_lon = loc_lon(id_idx);
id_loc_lat = loc_lat(id_idx);

ud_loc_sac = loc_sac(ud_idx);
ud_loc_lon = loc_lon(ud_idx);
ud_loc_lat = loc_lat(ud_idx);

hold(ax_mer, 'on')
sc_id = scatter(ax_mer, id_loc_lon, id_loc_lat, 100, 'xk');
%sc_ud = scatter(ax_mer, ud_loc_lon, ud_loc_lat, 25, 'ok');
hold(ax_mer, 'off')

%%______________________________________________________________________________________%%
%% (4) Add drift statistics as title to plot
%%______________________________________________________________________________________%%

% Compute drift statistics.
[drift_tot, drift_surf, drift_deep] = driftstats(gps, mername, 3600, 6.5*3600);

tl_str = sprintf('%s:', mername);
tl_str = sprintf('%s total drift=%i km,', tl_str, round(drift_tot.tot_dist/1000));
tl_str = sprintf('%s surface velocity=%.1f km/hr,', tl_str, drift_surf.ave_vel*3.6);
tl_str = sprintf('%s deep velocity=%.1f km/day', tl_str, drift_deep.ave_vel*3.6*24);

tl = title(ax_mer, tl_str);

%%______________________________________________________________________________________%%
%% (5) Final cosmetics and axes adjustment to ensure they lie on top of one another
%%______________________________________________________________________________________%%

lg = legend(ax_mer, [sc sc_id], ...
            {'GPS location', sprintf('Earthquake detection\n(location interpolated)')}, ...
            'Interpreter', 'LaTeX', 'Color', [0.8 0.8 0.8])
lg.LineWidth = 1;
lg.Location = legendloc;
uistack(lg, 'top')

axesfs(gcf, ax_fs, ax_fs)
latimes(gcf)
movev(tl, 0.1);

%set(lg.BoxFace, 'ColorType','truecoloralpha', 'ColorData', uint8(255*[0.9 ; 0.9 ; 0.9 ; 0.9]));

set(ax_mer, 'Position', ax_bathy.Position,  ...
            'XLim', ax_bathy.XLim, ...
            'YLim', ax_bathy.YLim, ...
            'DataAspectRatio', ax_bathy.DataAspectRatio, ...
            'TickDir', 'Out', 'Box', 'on', 'Color', 'None')
