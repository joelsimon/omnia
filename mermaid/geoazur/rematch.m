function EQ = rematch(sac, diro, redo)
% EQ = REMATCH(sac, diro, redo)
%
% Rematches GeoAzur 'identified' SAC files to cataloged events, using
% the origin time of the "event" in the header as a small time window
% in which to search for events whose phases arrive in the time window
% of the seismogram (and possibly location and magnitude information
% as well).
%
% REMATCH is useful to update the magnitude, time, location of the
% preliminary/initial matches.
%
% Input:
% sac       Full path SAC filename (def: 'm12.20130416T105310.sac')
% diro      Path to 'raw' directory (def: $MERMAID/events/geoazur)
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
defval('sac', 'm12.20130416T105310.sac');
defval('diro', fullfile(getenv('MERMAID'), 'events', 'geoazur'));
defval('redo', false)

% Read data and parse header EVENT information.
[~, h] = readsac(sac);
lat = h.EVLA;
lon = h.EVLO;
hmag = h.MAG;

% Nab reported event time.
[~, ~, ~, ~, hdate] = seistime(h);

% Time and location search parameters.
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
    EQ = cpsac2evt(sac, redo, [], n, [], [], defphases, diro, 1, 'start', ...
                   stime, 'end', etime, 'minmag', minmag, 'maxradius', ...
                   maxradius, 'lat', lat, 'lon', lon);
    
catch
    EQ = cpsac2evt(sac, redo, [], n, [], [], defphases, diro, 1, ...
                   'start', stime, 'end', etime);

end
