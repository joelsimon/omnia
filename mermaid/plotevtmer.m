function F = plotevtmer(id, evtdir, sacdir, returntype, incl_prelim)
% F = PLOTEVTMER(id, evtdir, sacdir, returntype, incl_prelim)
%
% Plot event location and location of array at time of event.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 07-Dec-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults.
defval('id', '10948555')
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('returntype', 'ALL')
defval('incl_prelim', true)

% Collect .sac files first.
sac = getsac(id, evtdir, sacdir, returntype, incl_prelim);

% Determine which are requested and which are detected.
[~, det_sac] = cellstrfind(sac, 'DET');
[~, req_sac] = cellstrfind(sac, 'REQ');

% Winnow SAC files down to unique floats -- there may be requested data, for
% example, for the same event with slightly different interpolated locations.
if ~isempty(det_sac)
    det_ser = getmerser(det_sac);

else
    det_ser = {};

end
if ~isempty(req_sac)
    req_ser = getmerser(req_sac);

else
    req_ser = {};

end

% Only plot MERMAID location once if multiple files exists for each event
% (e.g., REQ multiple phases for same event with slightly different
% interpolated locations).
[det_ser, det_idx] = unique(det_ser);
det_sac = det_sac(det_idx);

[req_ser, req_idx] = unique(req_ser);
req_sac = req_sac(req_idx);

% Determine which SAC files only exist as requests.
[req_only_ser, req_only_idx] = setdiff(req_ser, det_ser);
req_only_sac = req_sac(req_only_idx);

% Collect a single matching .evt file (the event location is the same for all
% SAC and it's the only event info we need).
EQ = getrevevt(det_sac{1}, evtdir);
EQ = EQ(1);

evt_lon = EQ.PreferredLongitude;
evt_lon360 = longitude360(evt_lon);
evt_lat = EQ.PreferredLatitude;
evt_date = irisstr2date(EQ.PreferredTime);

% Plot basemap.
F.f = figure;
F.ha = gca;
plotcont([0 90], [360 -90], 7)
hold(F.ha, 'on')

% Plot event location.
F.evt = plot(F.ha, longitude360(EQ.PreferredLongitude), EQ.PreferredLatitude, ...
             'bd', 'MarkerFaceColor', 'b', 'MarkerSize', 10);

% Mark interpolated locations of MERMAIDs that neither recorded a DET or REQ
% file (update as needed; better use kstnm...).
gps = readgps([], false);
all_mer_ser = {'08', '09', '10', '11', '12', '13', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25'};
miss_ser = setdiff(all_mer_ser, [det_ser req_only_ser]);
F.miss = plotmiss(F.ha, miss_ser, gps, evt_date);

% Plot MERMAID DET locations (triggered) in black.
F.det = plotsac(F.ha, det_sac, evt_lat, evt_lon);

% Plot only those MERMAID REQ (requested) locations in red only if that MERMAID
% was not also triggered (not necessarily to surface).
F.req = plotsac(F.ha, req_only_sac, evt_lat, evt_lon);

% Cosmetics.
magtype = EQ.PreferredMagnitudeType;
if ~strcmpi(magtype(1:2), 'mb')
    magstr = sprintf('\\textit{%s}$_{\\mathrm{%s}}$ %2.1f', upper(magtype(1)), ...
                     lower(magtype(2)), EQ.PreferredMagnitudeValue);

else
    magstr = sprintf('\\textit{%s}$_{\\mathrm{%s}}$ %2.1f', lower(magtype(1)), ...
                     lower(magtype(2:end)), EQ.PreferredMagnitudeValue);

end
depthstr = sprintf('%2.1f km depth', EQ.PreferredDepth);
locstr = titlecase(EQ.FlinnEngdahlRegionName, {'of'});
F.tl = title([datestr(evt_date) ' ' magstr ' ' locstr ' at ' depthstr]);

F.ha.XLim = [0 360];
F.ha.YLim = [-90 90];

F.ha.XTick = [0:60:360];
F.ha.YTick = [-90:30:90];

set(F.ha, 'XTickLabels', {'0$^{\circ}$' '60$^{\circ}$E' ...
                    '120$^{\circ}$E' '180$^{\circ}$' '120$^{\circ}$W' ...
                    '60$^{\circ}$W' '0$^{\circ}$'})
set(F.ha, 'YTickLabels', {'90$^{\circ}$S' '60$^{\circ}$S' ...
                    '30$^{\circ}$S' '0$^{\circ}$' '30$^{\circ}$N' ...
                    '60$^{\circ}$N' '90$^{\circ}$N'})

xlabel(F.ha, 'Longitude');
ylabel(F.ha, 'Latitude');

latimes
longticks(F.ha, 2)
grid(F.ha, 'on')
box(F.ha, 'on')
axesfs(F.f, 7, 9)
stack_order = [F.miss.pl ...
              F.req.pl  ...
              F.det.pl  ...
              F.miss.tx ...
              F.req.tx  ...
              F.det.tx];
for i = 1:length(stack_order)
    uistack(stack_order(i))

end
uistack([F.det.gc F.req.gc], 'bottom')

if length(F.det.pl) + length(F.req.pl) + length(F.miss.pl) ~= length(all_mer_ser)
    error('The number of floats plotted does not equal the expected total')

end

%% ___________________________________________________________________________ %%

function F = plotsac(ax, sac_files, evt_lat, evt_lon)
% DET or REQ file exists for this MERMAID.

if ~isempty(sac_files)
    for i = 1:length(sac_files)
        [x, h] = readsac(sac_files{i});

        mer_lon = h.STLO;
        mer_lon360 = longitude360(mer_lon);
        mer_lat = h.STLA;
        mer_ser = getmerser(sac_files{i});

        [trla, trlo] = track2('gc', evt_lat, evt_lon, mer_lat, mer_lon);
        trlo360 = longitude360(trlo);

        if contains(sac_files{i}, 'DET')
            MarkerFaceColor = [0.6 0.6 0.6];
            TrackColor = 'k-';

        else
            MarkerFaceColor = 'r';
            TrackColor = 'r--';

        end

        hold(ax, 'on')
        F.pl(i) = plot(ax, mer_lon360, mer_lat, 'v', 'MarkerFaceColor', MarkerFaceColor, ...
                       'MarkerEdgeColor', 'black', 'MarkerSize', 15);
        F.gc(i) = plot(ax, trlo360, trla, TrackColor);
        F.tx(i) = text(ax, mer_lon360, mer_lat, sprintf('%s', mer_ser), ...
                       'HorizontalAlignment', 'Center');
        F.info{i} = sprintf('%i: MERMAID %s', i, mer_ser);
        hold(ax, 'off')

    end
else
    F.pl = [];
    F.gc = [];
    F.tx = [];
    F.info =  [];

end

function F = plotmiss(ax, miss_ser, gps, evt_date)
% No DET or REQ file exists for this MERMAID.

if ~isempty(miss_ser)
    for i = 1:length(miss_ser)
        mer_ser = miss_ser{i};
        kstnm = sprintf('P00%s', mer_ser);
        mer_struct = gps.(kstnm);
        [mer_lat, mer_lon] = interpmerloc(mer_struct, evt_date);
        mer_lon360 = longitude360(mer_lon);


        hold(ax, 'on')
        F.pl(i) = plot(mer_lon360, mer_lat, 'v', 'MarkerFaceColor', 'w', ...
                       'MarkerEdgeColor', 'k', 'MarkerSize', 15);
        F.tx(i) = text(mer_lon360, mer_lat, sprintf('%s', mer_ser), ...
                       'HorizontalAlignment', 'Center');
        F.info{i} = sprintf('%i: MERMAID %s', i, mer_ser);
        hold(ax, 'off')

    end
else
    F.pl = [];
    F.tx = [];
    F.info =  [];

end
