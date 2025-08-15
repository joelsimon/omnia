function fig1
% FIG1
%
% Figure 1: Map with bathymetry/topography
%
% Developed as: hunga_plotevtmerbathy2.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 30-Sep-2024, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

clc
close all

invert = false;
colorsat = 0.5;

hundir = getenv('HUNGA');
sacdir = fullfile(hundir, 'sac');
imsdir = fullfile(sacdir, 'ims');
imssac = globglob(imsdir, '*sac.pa');
staticdir = fullfile(hundir, 'code', 'static');

sac = globglob(sacdir, '*.sac');
imssac = ordersac_geo(imssac, 'gcarc');

sac = [sac ; imssac];

sac = rmbadsac(sac);
sac = rmgapsac(sac);
sigtype = catsac;

% % Order by azimuth with P0023 last, so that its marker sits atop
% sac = ordersac_geo(sac, 'azimuth2');
% sac(end+1) = sac(1);
% sac(1) = [];

evtdir = fullfile(hundir, 'evt');
evt = fullfile(evtdir, '11516993.evt');
evt = load(evt, '-mat');
EQ = evt.EQ;

% Cut all but a single H03, H11 because we use their mean locations.
h11_idx = cellstrfind(sac, 'H11');
sac(h11_idx(2:end)) = [];

h03_idx = cellstrfind(sac, 'H03');
sac(h03_idx(2:end)) = [];

% Draw main map.
F = plotevtmer_local_all(sac, EQ, sigtype, colorsat);

%% ___________________________________________________________________________ %%
%% Map 1: MERMAID and IMS

xl = [160 290];
yl = [-50 30];

axesfs([], 8, 8)

set(F.ha, 'XLim', xl, 'XTick', xl(1):10:xl(2))
set(F.ha, 'YLim', yl, 'YTick', yl(1):10:yl(2))

set(F.pl, 'MarkerSize', 10);
set(F.tx, 'FontSize', 5);

% set(F.ha, 'XTickLabels', degrees(F.ha.XTick))
% set(F.ha, 'YTickLabels', degrees(F.ha.YTick))

set(F.ha, 'XTickLabels', degrees2(longitude180(F.ha.XTick)))
set(F.ha, 'YTickLabels', degrees2(F.ha.YTick))

F.ha.XLabel.FontSize = 8;
F.ha.YLabel.FontSize = 8;
F.cb.Label.FontSize = 8;

%% Manually adjust IMS labels -- they look a little left-biased.
 F.tx(end-1).Position(1) = 167.1;
F.tx(end).Position(1) = 281.4;

if invert
    F.bathy.CData = 1 - F.bathy.CData;
    keyboard
    % I don't know why this doesn't work inline.
    warning('Joel -- have the input the next line manually in command line\n')
    %set(F.cb, 'Colormap', 1 - get(F.cb, 'Colormap'))

end

savepdf('map1')
keyboard

%% ___________________________________________________________________________ %%
%% Map 2: MERMAID only

xl = [170 260];
yl = [-40 10];

set(F.ha, 'XLim', xl, 'XTick', xl(1):10:xl(2))
set(F.ha, 'YLim', yl, 'YTick', yl(1):10:yl(2))

set(F.pl, 'MarkerSize', 15)
set(F.tx, 'FontSize', 10)

% set(F.ha, 'XTickLabels', degrees(F.ha.XTick))
% set(F.ha, 'YTickLabels', degrees(F.ha.YTick))
set(F.ha, 'XTickLabels', degrees2(F.ha.XTick))
set(F.ha, 'YTickLabels', degrees2(F.ha.YTick))

idx = find(contains({F.tx.String}, {'H1' 'H0'}));
for i = 1:length(idx)
    delete(F.pl(idx(i)))
    F.tx(idx(i)).String = [];

end

keyboard
savepdf('map2')

%% ___________________________________________________________________________ %%

function F = plotevtmer_local_all(sac, EQ, sigtype, colorsat)
% Plot event location and location of array at time of event.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 01-Mar-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

evt_lon = EQ.PreferredLongitude;
evt_lon360 = longitude360(evt_lon);
evt_lat = EQ.PreferredLatitude;
evt_date = irisstr2date(EQ.PreferredTime);

% Plot basemap.
cax = [-6000 2000];
F = plotgebcopacific(cax, colorsat);
F.cb.Label.String = 'GEBCO Elevation [m]';
hold(F.ha, 'on')

% Plot event location.
F.evt = plot(F.ha, evt_lon360, evt_lat, 'r^', 'MarkerFaceColor', 'r', ...
             'MarkerEdgeColor', 'k', 'MarkerSize', 12);

hold(F.ha, 'on')
for i = 1:length(sac)
    if ~isimssac(sac{i})
        [~, h] = readsac(sac{i});

    else
        h = mean_ims_loc(sac{i});

    end

    mer_lon = h.STLO;
    mer_lon360 = longitude360(mer_lon);
    mer_lat = h.STLA;
    mer_ser = getmerser(sac{i});
    if contains(strippath(sac{i}), 'H11')
        mer_ser = 'H1';

    elseif contains(strippath(sac{i}), 'H03')
        mer_ser = 'H0';

    else
        mer_ser = mer_ser(end-1:end);

    end

    [trla, trlo] = track2('gc', evt_lat, evt_lon, mer_lat, mer_lon);
    trlo360 = longitude360(trlo);

    if strcmp(sigtype.(h.KSTNM), 'A')
        Color = 'blue';

    elseif strcmp(sigtype.(h.KSTNM), 'B')
        Color = 'black';

    elseif strcmp(sigtype.(h.KSTNM), 'C')
        Color = [0.6 0.6 0.6];

    else
        error('unexpected signal type')

    end

    % %% << Plot Fresnel-zone tracks; COLUMNS of output
    % fz = hunga_fresnel_zone_gebco(h.KSTNM);
    % for j = 1:size(fz.lo, 2);
    %     F.fz_track(j) =  plot(F.ha, longitude360(fz.lo(:, j)), fz.la(:, j), ...
    %                           'Color', 'white');
    % end
    % %% />>

    F.gc(i) = plot(F.ha, trlo360, trla, 'k-');

    if ~isimssac(sac{i})
        F.pl(i) = plot(F.ha, mer_lon360, mer_lat, 'v', 'MarkerFaceColor', Color, ...
                       'MarkerEdgeColor', 'black', 'MarkerSize', 15);


    else
        F.pl(i) = plot(F.ha, mer_lon360, mer_lat, 'd', 'MarkerFaceColor', Color, ...
                       'MarkerEdgeColor', 'black', 'MarkerSize', 15);
    end

    F.tx(i) = text(F.ha, mer_lon360, mer_lat, sprintf('%s', mer_ser), ...
                   'HorizontalAlignment', 'Center', 'Color', 'white');
    F.info{i} = sprintf('%2i: MERMAID %s', i, mer_ser);

end
hold(F.ha, 'off')

xlabel(F.ha, 'Longitude');
ylabel(F.ha, 'Latitude');

latimes2
longticks(F.ha, 2)
box(F.ha, 'on')
%axesfs(F.f, 7, 9)
%F.cb.Label.Interpreter = 'LaTeX';
F.cb.Label.Interpreter = 'tex';
F.cb.Label.FontName = 'times'
F.cb.Label.FontSize = 7;
%F.cb.Ticks = [-7000:1000:1000 01500];
F.cb.Ticks = [-6000:1000:2000];
F.cb.TickDirection = 'out';
F.tl.FontSize = 12;

%keyboard
uistack([F.gc F.bathy], 'bottom')

%% ___________________________________________________________________________ %%

function F = annotate_stdp(F)
error('Replace `hunga_readstdp` with h.STDP')

stdp = hunga_readstdp;
hold(F.ha, 'on')
for i = 1:length(F.pl)
    mer_ser = F.tx(i).String;
    kstnm = ['P00' mer_ser];
    if isfield(stdp, kstnm)
        lon = F.pl(i).XData;
        lat = F.pl(i).YData;
        meters = sprintf('%i m', stdp.(kstnm));
        % F.stdp(i) = text(lon, lat+2, meters, 'FontName', 'Times', ...
        %                      'Interpreter', 'LaTex', 'HorizontalAlignment', ...
        %                      'Center');
        F.stdp(i) = text(lon, lat+2, meters, 'FontName', 'Times', ...
                             'Interpreter', 'tex', 'HorizontalAlignment', ...
                             'Center');

    end
end
hold(F.ha, 'off')

%% ___________________________________________________________________________ %%

function h = mean_ims_loc(sac);
% This was done quickly by hand for all IMS stations, including H03N3.

if contains(sac, 'H03')
    h.STLA = -33.6361;
    h.STLO = -78.8919;
    h.KSTNM = 'H03N1'; % Assign mean loc to actual KSTNM for `catsac.m`

elseif contains(sac, 'H11')
    h.STLA =  19.1094;
    h.STLO =  166.7985;
    h.KSTNM = 'H11N1'; % Assign mean loc to actual KSTNM for `catsac.m`

end
