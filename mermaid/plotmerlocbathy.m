function plotmerlocbathy
% Originally: $SIMON2020_CODE/SIMON2020_PLOTMERLOC_BATHY
%
% Combines simon2020_plotmerloc.m and simon2020_bathy.m to plot MERMAID drift
% trajectories on a GEBCO 2019 basemap.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 13-Nov-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

%%______________________________________________________________________________________%%
%%                           simon2020_plotmerloc.m                                     %%
%%______________________________________________________________________________________%%

clc
close all

figure
ha_bathy = simon2020_bathy_local(false);
ha = axes;
set(ha, 'Color', 'None', 'Position', ha_bathy.Position)
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

% Read the lcoation data.
locdir =  fullfile(getenv('MERMAID'), 'locations');
mer = readmerloc(locdir);

%% Do everthing once for P008, the starndard for logest deployed.  The
%% assumes P008 is the first in the structure
name = fieldnames(mer);
if ~isequal(mer.(name{1}), mer.P008);
    error('P008 is not the first float in the list')

end

% We know mer.P008 is the first station in the list.
sta  = mer.P008;
locdate = sta.locdate;
lon = sta.lon;
lon(find(lon<0)) = lon(find(lon<0)) + 360; % convert longitudes from GPS coordinates to 0:360
lat = sta.lat;

[~, nan_idx1] = unzipnan(locdate);
[~, nan_idx2] = unzipnan(lon);
[~, nan_idx3] = unzipnan(lat);

nan_idx = unique([nan_idx1 ; nan_idx2 ; nan_idx3]);
locdate(nan_idx) = [];
lon(nan_idx) = [];
lat(nan_idx) = [];

% Remove locations taken within 1 hour of each other which signals it's
% the same surfacing.
rm_idx = find(diff(locdate) < hours(1));
locdate(rm_idx) = [];
lon(rm_idx) = [];
lat(rm_idx) = [];

% Find the last location reported by any MERMAID to generate the "days deployed" color axis
last_day = max(structfun(@(xx) max(xx.locdate), mer, 'UniformOutput', true));

days_deployed = days(locdate - locdate(1));
max_days_deployed = days(last_day - locdate(1));

cmap = jet(length(0:max_days_deployed));;
colormap(ha, cmap);
[col, cbticks, cbticklabels] = x2color(days_deployed, [], ...
                                       max_days_deployed, cmap, false);

%plot(ha, lon, lat, ':', 'Color', [0.6 0.6 0.6])
sc(1) = scatter(ha, lon, lat, scsize, col, 'filled');
mer_tx(1) = text(ha, lon(1), lat(1)+1, '08', 'FontSize', tsize);

cb = colorbar('Location', 'SouthOutside');
cb.Ticks = cbticks(1:20:end);
cb.TickLabels = cbticklabels(1:20:end);

%% Repeat for the other floats.
for i = 2:length(name)
    sta = mer.(name{i});
    locdate = sta.locdate;
    lon = sta.lon;
    lon(find(lon<0)) = lon(find(lon<0)) + 360; % convert longitudes from GPS coordinates to 0:360
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

    % Mark for removal the location taken while on the ship(?),
    % 17-Aug-2019 03:26:55 -- represents huge jump in location.
    if strcmp(name{i}, 'P023')
        rm_idx = find(lon == -149.641567 + 360);
        locdate(rm_idx) = [];
        lon(rm_idx) = [];
        lat(rm_idx) = [];

        % Plot a faint line connecting those points.
        plot(ha, lon(rm_idx-1:rm_idx), lat(rm_idx-1:rm_idx), ':', ...
             'Color', [0 0 0], 'LineWidth', 1);

        % Note again its still MERMAID 23.
        mer_tx_23 = text(ha, 200, -29, '23', 'FontSize', tsize);
        mer_tx_redploy = text(ha, 202, -31.5, '(redeployed)', 'FontSize', tsize, 'HorizontalAlignment', 'Center');

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
    nb_pl(i) = plot(ha, nb_lon(i), nb_lat(i), 'kv', 'MarkerFaceColor', 'none');
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

cb.Label.Interpreter = 'latex';

% This will identify the indices of th colorbar tick labels which are
% nearest the integer days 0 to 500.
ticks2keep = nearestidx([cbticklabels{:}], [0:100:800]);
cb.Ticks = cbticks(ticks2keep);
cb.TickLabels = {'0'   ...
                 '100' ...
                 '200' ...
                 '300' ...
                 '400' ...
                 '500' ...
                 '600' ...
                 '700' ...
                 '800'};
cb.Label.String = 'Days since deployment';
cb.FontSize = fs;
cb.Label.FontSize = fs;

longticks(ha, 3)
cb.TickDirection = 'out';
cb.TickLength = 0.015;


%% MERMAID
mer_tx(1).Position = [186 -11.75];  % P008
mer_tx(2).Position(2) = -10;        % P009
mer_tx(3).Position(2) = -15.5;      % P009
mer_tx(5).Position(2) = -13.25;     % P012
mer_tx(7).Position = [220.5 -10.2]; % P016
mer_tx(10).Position = [227.5 -15];  % P019
mer_tx(12).Position = [226 -25];    % P021
mer_tx(13).Position(1) = 222;       % P022
mer_tx(15).Position = [214  -23.5]; % P024
mer_tx(16).Position = [211  -20.5]; % P025

nb_tx(7).Position = [248.5 -27.5]; % RPN
delete(nb_pl(7))
nb_tx(8).Position = [189 -15.25];  % AFI
nb_tx(24).Position = [212 -12.7];  % VAH
delete(nb_pl(24));
nb_tx(25).Position = [208.5 -23.6]; % TBI

% Collect the station names we will keep.
kpr = [2 15 16 17 18 20 21 22];
for i = kpr
    if i == 2
        % Don't move this out as initial value -- I want complete list in 'kpr'.
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
lg.Color = 'None';
%lg.Position(4) = 0.2;

latimes
set(ha, 'Color', 'None', 'Position', ha_bathy.Position)
%tx = text(ha, 170, 5, '(a)', 'FontSize', 18, 'FontName', 'Helvetica', 'Interpreter', 'LaTex');

ha.XTick = [];
ha.YTick = [];
movev(cb, -0.06)

savepdf('merlocbathy')
keyboard

%______________________________________________________________________________%

function [net, sta, lat, lon] = readnearbytbl
filename = fullfile(getenv('SIMON2020_CODE'), 'data', 'nearbystations.tbl');

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

%%______________________________________________________________________________________%%
%%                                   simon2020_bathy.m                                  %%
%%______________________________________________________________________________________%%

function ha = simon2020_bathy_local(plot_mermaids)
% ha = SIMON2020_BATHY_LOCAL(PLOT_MERMAIDS)
%
% Local version of FJS' polynesia.m with some extra formatting touches.
% (for him, last modified by fjsimons-at-alum.mit.edu, 03/12/2020)
%
% Modiyfing author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 16-Jun-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('plot_mermaids', true)

close all

load(fullfile(getenv('IFILES'),'TOPOGRAPHY','POLYNESIA','732c10d12f3c1ff02b85522b39bfd9ee1aa42244.mat'))

% This from Joel Simon
% http://ds.iris.edu/gmap/#network=*&starttime=2018-06-01&maxlat=4&maxlon=251&minlat=-33&minlon=176&drawingmode=box&planet=earth
defval('c11',[176   4])
defval('cmn',[251 -33])
% Get the topography parameters
defval('vers',2019);
defval('npc',20);
defval('mult',1); mult=round(mult);

% Begin with a new figure, minimize it right away
defval('fs',6);
% Color limits
% The reference global color rendition would be
% imagefnan(c11,cmn,z,'demmap',[-7473 5731])
% cax=[-4000 0.75*max(z(:))];
% cax=halverange(minmax(z),75);
defval('cax',[-7000 1500]);

% Note that the print resolution for large images is worse than the
% detail in the data themselves. One could force print with more dpi.
clf
% Color bar first...
[cb,cm]=cax2dem(cax,'hor');
% then map
imagefnan(c11,cmn,z,cm,cax)
% then colorbar again for adequate rendering
[cb,cm]=cax2dem(cax,'hor');
% Cosmetics
% plotplates(c11,cmn) is just not good enough
%deggies(gca)
set(gca,'FontSize',fs)
xlabel('Longitude')
ylabel('Latitude')
cb.XLabel.String=sprintf('GEBCO %i elevation (m)',vers);
cb.XTick=unique([cb.XTick minmax(cax)]);
warning off MATLAB:hg:shaped_arrays:ColorbarTickLengthScalar
warning on MATLAB:hg:shaped_arrays:ColorbarTickLengthScalar

%%______________________________________________________________________________________%%
%%                                  Joel Edits                                          %%
%%______________________________________________________________________________________%%

fig2print(gcf, 'flandscape')

xlim([176 251])
ylim([-33 4])
ha = gca;
hold(ha, 'on')
set(ha, 'DataAspectRatio', [1 1 1])

fs = 13;

cb.FontSize = fs;
cb.Label.FontSize = fs;
cb.Label.Interpreter = 'latex';

movev(gca, 0.1)
movev(cb, 0.1)
cb.Ticks(9) = [];

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

longticks(ha, 3)
cb.TickLength = 0.015;
cb.TickDirection = 'out';

axesfs(gcf, fs, fs+3)
latimes
cb.Location = 'EastOutside';


%%______________________________________________________________________________________%%
%%                    Overlay the MERMAID deployment locations
%%______________________________________________________________________________________%%
if plot_mermaids

    % This is stripped from simon2020_globalstations.m

    % Get the locations of all floats at the time of their deployment.
    datadir = fullfile(getenv('SIMON2020_CODE'), 'data');
    str = readtext(fullfile(datadir, 'misalo.txt'));

    mlat = cellfun(@(xx) str2double(xx(31:40)), str);
    mlon = cellfun(@(xx) str2double(xx(43:53)), str);

    % Assuming this file is sorted...
    P008_idx = cellstrfind(str, 'P008')';
    P025_idx = cellstrfind(str, 'P025')';
    Princeton_idx = P008_idx:P025_idx;

    % Convert to from 0:180 = -180:0 to 0:360 longitude convection.
    mlon(find(mlon<0)) = mlon(find(mlon<0)) + 360;

    % Plot MERMAIDs.
    pl = plot(ha, mlon(Princeton_idx), mlat(Princeton_idx), 'v', 'MarkerFaceColor', ...
              porange, 'MarkerEdgeColor', 'k', 'MarkerSize', 12);


end
%%______________________________________________________________________________________%%

moveh(ha, -0.03)
moveh(cb.Label, 0.25)
