function EQ = rematch_merazur(sac, ga_diro, evt_diro, redo)
% EQ = REMATCH_MERAZUR(sac, ga_diro, evt_diro, redo)
%
% Rematches GeoAzur 'identified' SAC files to cataloged events, using
% the origin time of the "event" in the header as a small time window
% in which to search for events whose phases arrive in the time window
% of the seismogram (and possibly location and magnitude information
% as well).
%
% REMATCH_MERAZUR is useful to update the magnitude, time, location of the
% preliminary/initial matches.
%
% Input:
% sac       Full path SAC filename (def: 'm12.20130416T105310.sac')
% ga_diro   Path to GeoAzur parent directory, fetched with fetch_mermaid
%               (def: $MERAZUR)
% evt_diro  Path to 'raw' .evt directory (def: $MERMAID/events/geoazur)
% redo      logical true to rerun and overwrite any previous *.raw.evt/pdf files
%           logical false to skip redundant sac2evt.m execution (def: false)
%
% Output:
% EQ        Event structure that concatenates output structures 
%               from irisFetch.Events and taupTime.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 18-Mar-2019, Version 2017b

% Defaults.
defval('sac', 'm12.20130416T105310.sac')
defval('ga_diro', getenv('MERAZUR'))
defval('evt_diro', fullfile(getenv('MERMAID'), 'events', 'geoazur'))
defval('redo', false)

% Read data and parse header event (not station) information.
[~, h] = readsac(sac);
lat = h.EVLA;
lon = h.EVLO;
hmag = h.MAG;

% Nab reported event time.
[~, ~, ~, ~, hdate] = seistime(h);

% Time and location search parameters, formatted per FDSNWS specification.
stime = fdsnwstime(hdate - seconds(30));
etime = fdsnwstime(hdate + seconds(30));
maxradius = 5; % degrees
minmag = hmag - 1;

% Number of wavelet scales is based on sampling frequency.
if efes(h) == 20
    n = 5;

else
    n = 3;

end

% Path to the events file.
evtfile = fullfile(ga_diro, 'events', 'events.txt');

% Locate the event line associated with this SAC file in 'events.txt'.
[~, evtline] = mgrep(evtfile, strippath(sac), 1);

% Parse phase from matching line in 'events.txt'.
ga_phase = strtrim(evtline{1}(103:110));

% Reformat phase into 'purist' notation for taupTime
ga_phase = purist(ga_phase);

% In some very rare cases, exotic phases which would never ACTUALLY be
% recorded by MERMAID are reported in events.txt (SnSn, SKiKP) for
% example.  To ensure we are comparing apples-to-apples for any given
% event, append that phase to JDS' defaults.
all_phases = defphases;
if ~contains(all_phases, ga_phase)
    all_phases = [all_phases ', ' ga_phase];

end

% For some reason the four SAC files below gave me trouble.  If you
% look at the URL request output in the error message, and swap the
% IRIS baseurl for USGS, it works in the web browser. Annoyingly, it
% does not work if you switch the baseurl in cpsac2evt.m.  In that
% those cases, just rematch everything using the narrow time window.
try
    % These break:
    % s = {'m31.20140629T173408.sac', ...
    %      'm31.20140910T053727.sac', ...
    %      'm32.20140629T173341.sac', ...
    %      'm33.20150211T191949.sac'};
    EQ = cpsac2evt(sac, redo, [], n, [], [], all_phases, evt_diro, ...
                   1, 'start', stime, 'end', etime, 'minmag', ...
                   minmag, 'maxradius', maxradius, 'lat', lat, 'lon', lon);
    
catch
    EQ = cpsac2evt(sac, redo, [], n, [], [], all_phases, evt_diro, ...
                   1, 'start', stime, 'end', etime);

end
