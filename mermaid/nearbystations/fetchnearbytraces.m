function [tr, merged] = fetchnearbytraces(id, txtfile, evtdir, writedir)
% [tr, merged] = FETCHNEARBYTRACES(id, txtfile, evtdir, writedir)
%
% Fetches hour long traces from 'nearby stations' that begin five
% minutes before the theoretical first-arriving phase of the
% corresponding to event ID and saves the returned SAC files to
% [writedir]/[id]/*.sac.
%
% If the traces are split (and thus saved as separate SAC files) due
% to missing data they are merged into a single SAC file using
% mergenearbytraces.m.
%
% Input:
% id        Event ID [last column of 'identified.txt']
%               defval('11052554')
% txtfile   Textfile of station metadata from http://ds.iris.edu/gmap/
%               (def: $MERMAID/events/nearbystations/nearbystations.txt)
% evtdir    Path to directory containing 'raw/' and 'reviewed'
%               subdirectories (def: $MERMAID/events/)
% writedir  Directory to write [id]/*.sac
%               (def: $MERMAID/events/nearbystations/sac/)
%
% Output:
% tr        Cell of trace(s) returned by irisFetch.Traces
% merged    Merged filenames, if any (def: []) 
%
% Ex:
%    [tr, merged] = FETCHNEARBYTRACES('11052554')
%
% See also: evt2txt.m, readidentified.m, mergenearbytraces.m, mergesac
% 
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 02-Sep-2019, Version 2017b

% Wish list:
%
% [1] sac2evt.m: Do it once for first in list, then copy event details to all.
%                --pull TaupTimes struct creation out of sac2evt.m

% Defaults.
defval('id', '11052554')
defval('txtfile', fullfile(getenv('MERMAID'), 'events', 'nearbystations', 'nearbystations.txt'))
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('writedir', fullfile(getenv('MERMAID'), 'events', 'nearbystations', 'sac'))

% Get the EQ structures associated with this event.
[~, EQ] = getsacevt(id, evtdir);

% Keep only the first: they may differ in origin time slightly
% depending on catalog and when they were last queried, but they
% should all be roughly the same.
EQ = EQ{1}(1);
evtdate = datetime(irisstr2date(EQ.PreferredTime));

% Get all the nearbystations.
[network, station, station_latitude, station_longitude, datacenter, url] = ...
    parsenearbystations(txtfile);

tr_idx = 0;
for i = 1:length(station)
    % Compute theoretical arrival times.
    tt = taupTime(EQ.TaupTimes(1).model, EQ.PreferredDepth, EQ.PhasesConsidered, ...
                  'station', [station_latitude{i} station_longitude{i}], ...
                  'event', [EQ.PreferredLatitude EQ.PreferredLongitude]);

    % They should already be sorted but in the off chance they are not...
    if ~isempty(tt)
        [~, idx] = sort([tt.time], 'ascend');
        tt = tt(idx);

    else
        continue

    end

    % Base the query time off the first arriving phase.
    tt = tt(1);
    firstarrival_date = evtdate + seconds(tt.time);

    starttime_date = firstarrival_date - minutes(5);
    starttime = irisdate2str(starttime_date);

    endtime_date = firstarrival_date + minutes(55);
    endtime = irisdate2str(endtime_date);

    % Until the 'federated' option works for RASPISHAKE this will have to be hardcoded.
    switch upper(datacenter{i}{:})
      case 'IPGP'
        DATASELECTSERVICE = 'http://ws.ipgp.fr/fdsnws/dataselect/1/';
        STATIONSERVICE = 'http://ws.ipgp.fr/fdsnws/station/1/';
        CHANNEL = 'BHZ';
        includePZ  = true

      case 'IRISDMC'
        DATASELECTSERVICE = 'http://service.iris.edu/fdsnws/dataselect/1/';
        STATIONSERVICE = 'http://service.iris.edu/fdsnws/station/1/';
        CHANNEL = 'BHZ';
        includePZ  = true;

      case 'RASPISHAKE'
        DATASELECTSERVICE = 'https://fdsnws.raspberryshakedata.com/fdsnws/dataselect/1/';
        STATIONSERVICE = 'https://fdsnws.raspberryshakedata.com/fdsnws/station/1/';
        CHANNEL = '*Z';
        includePZ  = false;

      otherwise
        % Add more cases as issues arise.
        error('Unexpected datacenter: %s', datacenter)

    end  

    % Fetch it.
    if includePZ
        traces = irisFetch.Traces(network{i}, station{i}, '00', CHANNEL, starttime, endtime, ...
                                 ['DATASELECTURL:' DATASELECTSERVICE], ...
                                 ['STATIONURL:' STATIONSERVICE], ...
                                 'includePZ');

    else
        traces = irisFetch.Traces(network{i}, station{i}, '00', CHANNEL, starttime, endtime, ...
                                 ['DATASELECTURL:' DATASELECTSERVICE], ...
                                 ['STATIONURL:' STATIONSERVICE]);

    end
    
    % Keep only nonempty traces.
    if ~isempty(traces)
        tr_idx = tr_idx + 1;
        tr{tr_idx} = traces;
        irisFetch.Trace2SAC(tr{tr_idx}, fullfile(writedir, num2str(id)))

    end
end

% Merge split SAC files if necessary.
merged = mergenearbytraces(tr, id, writedir);
