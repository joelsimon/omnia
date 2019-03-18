function EQ = rematch(sac, diro, redo)
% EQ = REMATCH(sac, diro, redo)
%
% Rematches GeoAzur 'identified' SAC files to cataloged events.
% updates the origin time in the header to the current valu
%
% *0.5 degrees of latitude/longitude
% *1.0 magnitude value
% *10. seconds
%
% REMATCH is useful to update the magnitude, time, location of the
% preliminary/initial matches.
%
% Input:
% sac       Full path SAC filename
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
% Last modified: 16-Mar-2019, Version 2017b

defval('sac', 'm12.20130416T105310.sac');
defval('redo', false)

% Read data and parse header EVENT information.
[~, h] = readsac(sac);
lat = h.EVLA;
lon = h.EVLO;
hmag = h.MAG;

% Nab reported event time.
[~, ~, ~, ~, hdate] = seistime(h);

stime = fdsnwstime(hdate - seconds(30));
etime = fdsnwstime(hdate + seconds(30));
maxradius = 5;
minmag = hmag - 1;

if efes(h) == 20
    n = 5;

else
    n = 3;

end

EQ = cpsac2evt(sac, redo, [], n, [], [], defphases, diro, 1, 'start', ...
               stime, 'end', etime, 'minmag', minmag, 'maxradius', ...
               maxradius, 'lat', lat, 'lon', lon);




