function F = plotevtmer(id, evtdir, sacdir, returntype, incl_prelim)
% F = PLOTEVTMER(id, evtdir, sacdir, returntype, incl_prelim)
%
% Plot event location and location of array at time of event.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 06-Dec-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

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

% Keep only uniq
[det_ser, det_idx] = unique(det_ser);
det_sac = det_sac(det_idx);

[req_ser, req_idx] = unique(req_ser);
req_sac = req_sac(req_idx);

% Determine which SAC files only exist as requests.
[~, req_only_idx] = setdiff(req_ser, det_ser);
req_only_sac = req_sac(req_only_idx);

% Collect a single matching .evt file (the event location is the same for all
% SAC and it's the only event info we need).
EQ = getevt(det_sac{1}, evtdir, false);

evt_lon = EQ.PreferredLongitude;
evt_lon360 = longitude360(evt_lon);
evt_lat = EQ.PreferredLatitude;

% Plot basemap.
F.f = figure;
F.ha = gca;
plotcont([0 90], [360 -90], 7)
hold(F.ha, 'on')

% Plot event location.
F.evt = plot(F.ha, longitude360(EQ.PreferredLongitude), EQ.PreferredLatitude, ...
             'b*', 'MarkerSize', 10);

% Plot MERMAID DET locations (triggered) in black.
F = plotit(F, det_sac, evt_lat, evt_lon);

% Plot only those MERMAID REQ (requested) locations in red only if that MERMAID
% was not also triggered (not necessarily to surface).
F = plotit(F, req_only_sac, evt_lat, evt_lon);

% Cosmetics.
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

function F = plotit(F, sac_files, evt_lat, evt_lon)

for i = 1:length(sac_files)
    [x, h] = readsac(sac_files{i});

    mer_lon = h.STLO;
    mer_lon360 = longitude360(mer_lon);
    mer_lat = h.STLA;
    mer_ser = getmerser(sac_files{i});

    [trla, trlo] = track2('gc', evt_lat, evt_lon, mer_lat, mer_lon);
    trlo360 = longitude360(trlo);

    if contains(sac_files{i}, 'DET')
        det_req = 'DET';
        MarkerFaceColor = 'w';
        TrackColor = 'k-';

    else
        det_req = 'REQ';
        MarkerFaceColor = 'r';
        TrackColor = 'r--';

    end

    F.pl(i) = plot(F.ha, mer_lon360, mer_lat, 'v', 'MarkerFaceColor', MarkerFaceColor, ...
                   'MarkerEdgeColor', 'black', 'MarkerSize', 15);
    F.gc(i) = plot(F.ha, trlo360, trla, TrackColor);
    F.tx(i) = text(F.ha, mer_lon360, mer_lat, sprintf('%s', mer_ser), ...
                   'HorizontalAlignment', 'Center');
    F.info{i} = sprintf('%i: MERMAID %s (%s)', i, mer_ser, det_req);

end
