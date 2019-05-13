function [floats, startdate, enddate, alldate] = gafloats(plt, ...
                                                  merazur, updated, rematch)
% [floats, startdate, enddate, alldate] = GAFLOATS(plt, merazur, updated, rematch)
%
% GAFLOATS returns the float numbers and dates of the first/last
% "identified" seismograms contained (recursively) in the path
% 'merazur', and plots a global map (Robinson projection) showing
% events and the stations that recorded them, connected by their great
% circle path
%
% Input: 
% plt             true to plot crude map of ray paths (def: false)
% merazur         A path to GeoAzur MERMAID data (def: $MERAZUR)
% updated         true: use JDS updated event information (def: true)
%                 false: use event information from SAC header 
% rematch         Directory to find reviewed .evt files for updated 
%                     event info (def: $MERAZUR/rematch/)
%            
%
% Output:
% floats          Array of 2-digit float numbers
% start/enddate   Date of first/last identified seismogram
% alldate         All dates of identified seismograms
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 13-May-2019, Version 2017b

% Default.
defval('plt', false)
defval('merazur', getenv('MERAZUR'))
defval('updated', true)
defval('rematch', fullfile(getenv('MERAZUR'), 'rematch'))

% Fetch all data and parse relevant info from filename.
s = mermaid_sacf('id', merazur);
for i = 1:length(s)
    [~, h] = readsac(s{i});

    [seisdate, ~, seisertime] = seistime(h);
    sdate(i) = seisdate.B;
    snum(i) = seisertime.B;

   % Get STATION location.
    stla(i) = h.STLA;
    stlo(i) = h.STLO;

    % Get EVENT location
    if ~updated
        evla(i) = h.EVLA;
        evlo(i) = h.EVLO;

    else
        EQ = getevt(s{i}, rematch);
        evla(i) = EQ.PreferredLatitude;
        evlo(i) = EQ.PreferredLongitude;

    end
        
    % Compute great circle between them.
    [trla{i}, trlo{i}] = track2(stla(i), stlo(i), evla(i), evlo(i));

    % Nab the float number.
    filename = strippath(s{i});
    floats(i) = str2double(filename(2:3));

end

if plt
    % Set up map axes.
    axesm('MapProjection','Robinson','MapLatLimit',[-90 90], 'MapLonLimit', [-180 180])
    geoshow('landareas.shp', 'FaceColor', repmat(0.95, 1, 3))
    hold(gca, 'on')

    % MarkerSize and LineWidth.
    S = 20;
    lw = 0.5;

    % Plot location of MERMAID at time of recording, location of event,
    % and great circle path between them.
    for i = 1:length(s)
        pltr(i) = plotm(trla{i}, trlo{i}, 'Color', repmat(0.25, 1, 3), 'LineWidth', lw);


    end
    plev = scatterm(evla, evlo,  S, 'r', '*');
    plst = scatterm(stla, stlo, S, 'y', '^');

    % Cosmetic adjustments.
    set(plst.Children, 'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'k', 'LineWidth', lw, 'SizeData', 40)
    framem('on')
    set(gca, 'Visible', 'off', 'Box', 'off')
    savepdf(mfilename)

end

% Sort the outputs by date of seismogram.
floats = unique(floats);
[~, idx] = sort(snum);
alldate = sdate(idx);
startdate = alldate(1);
enddate = alldate(end);
