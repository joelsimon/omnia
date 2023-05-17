function plotmerlocbathyall(skip_french, skip_nearby, just_xenet)
% PLOTMERLOCBATHYALL(skip_french, skip_nearby, just_xenet)
%
% Plot MERMAID drift trajectories, color coded based on deployment duration, for
% entire array on GEBCO basemap.
%
% Input:
% skip_french     true to not plot P0006/7 GeoAzur float (def: true)
% skip_nearby     true to not plot nearby stations (def false)
% just_xenet*     true to only plot XE OBS network (def: false)
%
% NB: PLOTMERLOCBATHYALL loads bathymetric .mat basemap in
% `plotsouthpacificbathy` and thus the bounding box is relatively inflexible. If
% you want to enlarge plot you must remake basemap .mat file.
%
% * Sets `skip_french = true' and uses nearbystations list updated 2023-05-08.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 08-May-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

defval('skip_french', true)
defval('skip_nearby', false)
defval('just_xenet', false)

if just_xenet
    skip_french = true;
    skip_nearby = true;

end

% Paths.
merpath = getenv('MERMAID');
procdir = fullfile(merpath, 'processed');
evtdir = fullfile(merpath, 'events');
nearbytbl = fullfile(evtdir, 'nearbystations', 'nearbystations.tbl');

% Common parameters.
fs = 13;
if ~skip_nearby  || just_xenet
    latlim = [-33 4];
    lonlim = [176 251];

    if just_xenet
        latlim = [-33 -2];
        lonlim = [176 240];

    end
else
    % Must regenerate basemap `plotsouthpacificbathy` uses to adjust
    % lat/lonlim outside original box listed above
    latlim = [-33 -7];
    lonlim = [176 240];

end
deplim = [-7000 1500];

%%______________________________________________________________________________________%%
%% (1) Plot bathymetric base map
%%______________________________________________________________________________________%%
[ax_bathy, cb_bathy] = plotsouthpacificbathy(lonlim, flip(latlim), deplim);
if isempty(ax_bathy.Children.CData)
    error('Likely issue -- must recompute/enlarge basemap; lat/lon limits outside of [-33 -4]/[176 251]')

end
cb_bathy.Label.String = strrep(cb_bathy.Label.String , 'elevation', 'Elevation');
fig2print(gcf, 'flandscape')

%% Cosmetics to bathymetric base map.
ax_mer.XLim = lonlim;
ax_mer.YLim = latlim;

hold(ax_bathy, 'on')

cb_bathy.FontSize = fs;
cb_bathy.Label.FontSize = fs;
cb_bathy.Label.Interpreter = 'latex';

movev(gca, 0.1)
movev(cb_bathy, 0.1)
cb_bathy.Ticks = [-7000:1000:0 1500];

if ~skip_nearby
    ax_bathy.XTick = [180:10:250];
    ax_bathy.XTickLabel = {'-180$^{\circ}$'  ...
                        '-170$^{\circ}$' ...
                        '-160$^{\circ}$' ...
                        '-150$^{\circ}$' ...
                        '-140$^{\circ}$' ...
                        '-130$^{\circ}$' ...
                        '-120$^{\circ}$' ...
                        '-110$^{\circ}$'};


    ax_bathy.YTick = [-30:10:0];
    ax_bathy.YTickLabel = flip({'0$^{\circ}$' ...
                        '-10$^{\circ}$' ...
                        '-20$^{\circ}$' ...
                        '-30$^{\circ}$'});
end

longticks(ax_bathy, 3)
cb_bathy.TickLength = 0.015;
cb_bathy.TickDirection = 'out';

axesfs(gcf, fs, fs+3)

cb_bathy.Location = 'EastOutside';

%%______________________________________________________________________________________%%
%% (2) Plot MERMAID tracks in secondary (transparent) axis
%%______________________________________________________________________________________%%

% Generate secondary (transparent) axes in same location as base map.
ax_mer = axes;
set(ax_mer, 'Color', 'None', 'Position', ax_bathy.Position, ...
            'DataAspectRatio', ax_bathy.DataAspectRatio)
hold(ax_mer, 'on')
fig2print(gcf, 'flandscape')
axesfs(gcf, fs, fs)
scsize = 10;
tsize = fs - 2;

% Plot MERMAID tracks.
mer = readgps(procdir, false);

% Apr/May 2023 "T0100" came online into my server, ignore for now.
if isfield(mer, 'T0100')
    mer = rmfield(mer, 'T0100');

end

% Remove French floats, P0006 and P0007
if skip_french
    mer = rmfield(mer, {'P0006', 'P0007'});

end

% Figure out the longest deployment time to generate the colorbar reference saturation
name = fieldnames(mer);
longest_deployment = 0;
for i = 1:length(name)
    days_deployed = days(mer.(name{i}).date(end) - mer.(name{i}).date(1));
    if days_deployed > longest_deployment
        longest_deployment = days_deployed;

    end
end

% Define colormap and add colorbar.
cbdata = [0:ceil(longest_deployment)];
cmap = jet(length(cbdata));
colormap(ax_mer, cmap)
[~, cbticks, cbticklabels] = x2color(cbdata, [], [], cmap, false);
cb_mer = colorbar(ax_mer, 'Location', 'SouthOutside');

% Plot all drift tracks.
for i = 1:length(name)
    sta = mer.(name{i});
    lon = sta.lon;
    lon(find(lon<0)) = lon(find(lon<0)) + 360; % convert longitudes from GPS coordinates to 0:360
    lat = sta.lat;
    cum_days = [0 ; cumsum(days(diff(mer.(name{i}).date)))];

    % Remove indices when MERMAID P023 was out of the water (on the ship).
    if strcmp(name{i}, 'P0023')
        bad_dates = iso8601str2date({'2019-08-17T03:18:29Z' '2019-08-17T03:22:02Z'});
        [~, rm_idx] = intersect(sta.date, bad_dates);
        lon(rm_idx) = [];
        lat(rm_idx) = [];
        cum_days(rm_idx) = [];

        % Plot a faint line connecting those points.
        plot(ax_mer, lon(rm_idx-1:rm_idx), lat(rm_idx-1:rm_idx), ':', ...
             'Color', [0 0 0], 'LineWidth', 1);

        % Note again its still MERMAID 23.
        mer_tx_23 = text(ax_mer, 200, -29, '23', 'FontSize', tsize);
        mer_tx_redploy = text(ax_mer, 202, -31.5, '(redeployed)', 'FontSize', tsize, 'HorizontalAlignment', 'Center');

    end

    % Generate a colorbar that saturates at the longest deployment date, so that the colors are in
    % reference to each other (only a single GPS track will reach the saturation color).
    col = x2color(cum_days, [], longest_deployment, cmap, false);
    col(end,:)
    sc(i) = scatter(ax_mer, lon, lat, scsize, col, 'filled');
    mer_tx(i) = text(ax_mer, lon(1), lat(1)+1, name{i}(end-1:end), 'FontSize', tsize);

end

%%______________________________________________________________________________________%%
%% (3) Overlay "nearby" and CPPT stations in same axis as MERMAID tracks
%%______________________________________________________________________________________%%
if ~skip_nearby
    [~, nb_sta, nb_lat, nb_lon] = parsenearbystationstbl(nearbytbl);

    nb_lon(find(nb_lon<0)) = nb_lon(find(nb_lon<0)) + 360;
    for i = 1:length(nb_sta)
        nb_pl(i) = plot(ax_mer, nb_lon(i), nb_lat(i), 'kv', 'MarkerFaceColor', 'none');
        nb_tx(i) = text(ax_mer, nb_lon(i), nb_lat(i)+1, nb_sta{i}, 'FontSize', ...
                        tsize, 'HorizontalAlignment', 'Center');

    end
end

%%______________________________________________________________________________________%%
%% (3.1) Overlay "nearby" EX-network stations ONLY, in same axis as MERMAID tracks
%%______________________________________________________________________________________%%
if just_xenet
    updated_txtfile = fullfile(evtdir, 'nearbystations', 'nearbystations_2023-05-08.txt');
    [xe_net, xe_sta, ~, ~, xe_lat, xe_lon] = parsenearbystations(updated_txtfile, false);
    xe_idx = cellstrfind(xe_net, 'XE');
    xe_net = xe_net(xe_idx);
    xe_sta = xe_sta(xe_idx);
    xe_lat = xe_lat(xe_idx);
    xe_lon = xe_lon(xe_idx);
    xe_lon = longitude360(xe_lon);
    for i = 1:length(xe_sta)
        xe_pl(i) = plot(ax_mer, xe_lon(i), xe_lat(i), 'kv', 'MarkerFaceColor', 'none');
        % xe_tx(i) = text(ax_mer, xe_lon(i), xe_lat(i)+1, xe_sta{i}, 'FontSize', ...
        %                 tsize, 'HorizontalAlignment', 'Center');

    end
end

%% ___________________________________________________________________________ %%
%% (4) Final cosmetics
%% ___________________________________________________________________________ %%

ax_mer.XLim = lonlim;
ax_mer.YLim = latlim;
box on

cb_mer.Label.Interpreter = 'latex';

% This identifies the indices of the colorbar tick labels.
tick_int = 365/2; % ticks every 6 months
max_tick2keep = round2fac(cbticklabels{end}, tick_int, 'down');
ticks2keep = nearestidx([cbticklabels{:}], [0:tick_int:max_tick2keep]);
cb_mer.Ticks = cbticks(ticks2keep);
cb_mer.TickLabels = round2fac(ticks2keep/365, tick_int/365, 'down');
cb_mer.Label.String = 'Years Deployed';
cb_mer.FontSize = fs;
cb_mer.Label.FontSize = fs;

longticks(ax_mer, 3)
cb_mer.TickDirection = 'out';
cb_mer.TickLength = 0.015;

%% MERMAID
if skip_french
    mer_tx(1).Position = [186 -11.75];  % P0008
    mer_tx(2).Position(2) = -10;        % P0009
    mer_tx(3).Position(2) = -15.5;      % P0009
    mer_tx(5).Position(2) = -13.25;     % P0012
    mer_tx(7).Position = [220.5 -10.2]; % P0016
    mer_tx(10).Position = [227.5 -15];  % P0019
    mer_tx(12).Position = [226 -25];    % P0021
    mer_tx(13).Position(1) = 222;       % P0022
    mer_tx(15).Position = [214  -23.5]; % P0024
    mer_tx(16).Position = [211  -20.5]; % P0025

end

%% Nearby stations.
if ~skip_nearby
    nb_tx(1).Position = [183 -15.75];  % FUTU
    nb_tx(5).Position(1) = 249;        % VA02
    nb_tx(7).Position = [248.5 -27.5]; % RPN
    delete(nb_pl(7))
    nb_tx(8).Position = [189 -15.25];  % AFI
    nb_tx(24).Position = [212 -12.7];  % VAH
    delete(nb_pl(24));
    nb_tx(25).Position = [208.5 -23.6]; % TBI

    % Delete station names around Fiji; put them in legend
    kpr = [2 15 16 17 18 20 21 22];
    for i = kpr
        if i == 2
            % Don't move this out as initial value -- I want complete list in 'kpr'.
            patch_str =  nb_tx(i).String;

        else
            patch_str = [patch_str newline nb_tx(i).String];

        end

    end
    delete(nb_tx(kpr))

    % Flip the triangle on Fiji and make bigger to mark this cluster of stations. Use the first as the
    % marker and delete the rest.
    nb_pl(kpr(1)).MarkerSize = 12;
    nb_pl(kpr(1)).Marker = '^';
    delete(nb_pl(kpr(2:end)))

    % Add a long list of names attached to the single triangle on Fiji.
    lg = legend(nb_pl(kpr((1))), patch_str, 'Interpreter', 'LaTeX');
    lg.Color = 'None';

end

ax_mer.XTick = [];
ax_mer.YTick = [];

latimes(gaf)
moveh([ax_bathy cb_mer], -0.05)
movev(cb_mer, -0.1)

set(ax_mer, 'Color', 'None', 'Position', ax_bathy.Position)
uistack(mer_tx, 'top')

if skip_nearby
    set(ax_bathy, 'YTickLabels', degrees(ax_bathy.YTick))
    set(ax_bathy, 'XTickLabels', degrees(ax_bathy.XTick))

end
