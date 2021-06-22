function fig4a
% FIG4A
%
% Plots MERMAID drift trajectories and island station locations.
%
% Developed as: $SIMON2020_CODE/simon2020_plotmerloc.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 11-Mar-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

figure
ha = gca;
hold(ha, 'on')
fig2print(gcf, 'flandscape')

% Equalize degrees in N/S and E/W directions.
set(ha, 'DataAspectRatio', [1 1 1])

fs = 13;
axesfs(gcf, fs, fs)

scsize = 10;
tsize = fs - 2;

%______________________________________________________________________________%

% Plot MERMAID tracks.

% Read the location data.
supplement_directory = fullfile(getenv('GJI21_CODE'), 'data', 'supplement');
mer = read_simon2021gji_supplement_gps(supplement_directory);

%% Do everthing once for P008, the starndard for logest deployed.
name = fieldnames(mer);
if ~isequaln(mer.(name{1}), mer.P008);
    keyboard
    error('P008 is not the first float in the list')

end

% We know mer.P008 is the first station in the list.
sta  = mer.P008;
locdate = sta.locdate;
lon = sta.lon;
lat = sta.lat;

[~, nan_idx1] = unzipnan(locdate);
[~, nan_idx2] = unzipnan(lon);
[~, nan_idx3] = unzipnan(lat);

nan_idx = unique([nan_idx1 ; nan_idx2 ; nan_idx3]);
locdate(nan_idx) = [];
lon(nan_idx) = [];
lat(nan_idx) = [];

% Remove locations taken within 1 hour of each other which signals its
% the same surfacing.
rm_idx = find(diff(locdate) < hours(1));
locdate(rm_idx) = [];
lon(rm_idx) = [];
lat(rm_idx) = [];

% Identify all locations up to the end of 2019.
last_day = datetime('31-Dec-2019 23:59:59.999', 'TimeZone', 'UTC');
idx = find(locdate <= last_day);

locdate = locdate(idx);
lat = lat(idx);
lon = lon(idx);

% Convert longitudes from GPS coordinates to 0:360.
lon(find(lon<0)) = lon(find(lon<0)) + 360;

days_deployed = days(locdate - locdate(1));
max_days_deployed = days(last_day - locdate(1));

cmap = jet(length(0:max_days_deployed));;
colormap(ha, cmap);
[col, cbticks, cbticklabels] = x2color(days_deployed, [], ...
                                       max_days_deployed, cmap, false);

%plot(ha, lon, lat, ':', 'Color', [0.6 0.6 0.6])
sc(1) = scatter(ha, lon, lat, scsize, col, 'filled');
mer_tx(1) = text(ha, lon(1), lat(1)+1, '08', 'FontSize', tsize);

cb = colorbar('Location', 'EastOutside');
cb.Ticks = cbticks(1:20:end);
cb.TickLabels = cbticklabels(1:20:end);

%% Repeat for the other floats, assuming P008 was the first (verified above).
for i = 2:length(name)
    sta = mer.(name{i});
    locdate = sta.locdate;
    lon = sta.lon;
    lat = sta.lat;

    [~, nan_idx1] = unzipnan(locdate);
    [~, nan_idx2] = unzipnan(lon);
    [~, nan_idx3] = unzipnan(lat);

    nan_idx = unique([nan_idx1 ; nan_idx2 ; nan_idx3]);
    locdate(nan_idx) = [];
    lon(nan_idx) = [];
    lat(nan_idx) = [];

    rm_idx = find(diff(locdate) < hours(1));
    locdate(rm_idx) = [];
    lon(rm_idx) = [];
    lat(rm_idx) = [];

    idx = find(locdate <= last_day);
    locdate = locdate(idx);
    lat = lat(idx);
    lon = lon(idx);
    lon(find(lon<0)) = lon(find(lon<0)) + 360;

    % Mark for removal the location taken while on the ship(?),
    % 17-Aug-2019 03:26:55 -- represents huge jump in location.
    if strcmp(name{i}, 'P023')
        rm_idx = find(lon == -149.641567 + 360);
        locdate(rm_idx) = [];
        lon(rm_idx) = [];
        lat(rm_idx) = [];

        % Plot a faint line connecting those points.
        plot(ha, lon(rm_idx-1:rm_idx), lat(rm_idx-1:rm_idx), ':', ...
             'Color', [0.6 0.6 0.6]);
    end

    days_deployed = days(locdate - locdate(1));
    col = x2color(days_deployed, [], max_days_deployed, cmap, false);

    sc(i) = scatter(ha, lon, lat, scsize, col, 'filled');
    mer_tx(i) = text(ha, lon(1), lat(1)+1, name{i}(3:4), 'FontSize', tsize);

end

%______________________________________________________________________________%
%% Plot "nearby" and CPPT stations.
[~, nb_sta, nb_lat, nb_lon] = readnearbytbl;

nb_lon(find(nb_lon<0)) = nb_lon(find(nb_lon<0)) + 360;
for i = 1:length(nb_sta)
    nb_pl(i) = plot(ha, nb_lon(i), nb_lat(i), 'kv', 'MarkerFaceColor', 'k');
    nb_tx(i) = text(ha, nb_lon(i), nb_lat(i)+1, nb_sta{i}, 'FontSize', ...
                    tsize, 'HorizontalAlignment', 'Center');

end

%______________________________________________________________________________%
%% Cosmetics

% Edges of "nearby" stations bouding box.
maxlat = 4;
maxlon = 251;
minlat = -33;
minlon = 176;
ha.XLim = [minlon maxlon];
ha.YLim = [minlat maxlat];
box on

xl = xlabel(ha, 'Longitude');
yl = ylabel(ha, 'Latitude');

ha.XTick = [180:10:250];
ha.XTickLabel = {'-180$^{\circ}$'  ...
                 '-170$^{\circ}$' ...
                 '-160$^{\circ}$' ...
                 '-150$^{\circ}$' ...
                 '-140$^{\circ}$' ...
                 '-130$^{\circ}$' ...
                 '-120$^{\circ}$' ...
                 '-110$^{\circ}$'};


ha.YTick = [-30:10:0];
ha.YTickLabel = flip({'0$^{\circ}$' ...
                    '-10$^{\circ}$' ...
                    '-20$^{\circ}$' ...
                    '-30$^{\circ}$'});
grid on

cb.Label.Interpreter = 'latex';

% This will identify the indices of th colorbar tick labels which are
% nearest the integer days 0 to 500.
ticks2keep = nearestidx([cbticklabels{:}], [0:100:500]);
cb.Ticks = cbticks(ticks2keep);
cb.TickLabels = {'0'   ...
                 '100' ...
                 '200' ...
                 '300' ...
                 '400' ...
                 '500'};
cb.Label.String = 'Days since deployment';
cb.FontSize = fs;
cb.Label.FontSize = fs;

longticks(ha, 3)
cb.TickDirection = 'out';
cb.TickLength = 0.015;


%% MERMAID
mer_tx(2).Position(2) = -10;
mer_tx(3).Position(2) = -15.5;
mer_tx(5).Position(2) = -13.25;
mer_tx(7).Position = [220.5 -10.2];
mer_tx(10).Position = [227.5 -15];
mer_tx(12).Position = [225 -25];
mer_tx(13).Position(1) = 222;
mer_tx(15).Position = [214  -23.5];
mer_tx(16).Position = [211  -20.5];


%% NEARBY
nb_tx(1).Position = [179.2 -14.5]; % FUTU

nb_tx(5).Position = [249  -26.16]; % VA02
nb_tx(7).Position = [248.5 -27.5];  % RPN
delete(nb_pl(7))

nb_tx(8).Position = [188.2227 -15.5]; % AFI

nb_tx(24).Position = [212 -12.7]; % VAH
delete(nb_pl(24));

nb_tx(25).Position = [208.5 -23.6]; % TBI

% Collect the station names will keep.
kpr = [2 15 16 17 18 20 21 22];
for i = kpr
    if i == 2
        % Don't move this out as initial value -- I want complete list in
        % 'kpr'.
        patch_str =  nb_tx(i).String;

    else
        patch_str = [patch_str newline nb_tx(i).String];

    end

end

% Delete those station names.
delete(nb_tx(kpr))

% Flip the symbol and make bigger to mark this cluster of
% stations. Use the first as the marker and delete the rest.
nb_pl(kpr(1)).MarkerSize = 12;
nb_pl(kpr(1)).Marker = '^';
delete(nb_pl(kpr(2:end)))

lg = legend(nb_pl(kpr((1))), patch_str, 'Interpreter', 'LaTeX');

latimes

tx = text(ha, 170, 5, '(a)', 'FontSize', 18, 'FontName', 'Times', 'Interpreter', 'LaTex');
moveh(cb.Label, 0.25)
savepdf('fig4a')

%______________________________________________________________________________%

function [net, sta, lat, lon] = readnearbytbl
filename = fullfile(getenv('GJI21_CODE'), 'data', 'nearbystations.tbl');

% Read the file.
s = readtext(filename);

% Remove empty \newline.
s(end) = [];

% Parse the relevant info.
for i = 1:length(s)
    sp = strtrim(strsplit(strrep(s{i}, '\\', '') , '&'));

    net{i} = sp{1};
    sta{i} = sp{2};
    lat(i) = str2double(sp{3});
    lon(i) = str2double(sp{4});

end
