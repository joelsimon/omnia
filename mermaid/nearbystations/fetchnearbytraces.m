function [tr, merged] = fetchnearbytraces(id, redo, txtfile, evtdir, sacdir, model, ph)
% [tr, merged] = FETCHNEARBYTRACES(id, redo, txtfile, evtdir, sacdir, model, ph)
%
% Fetches hour long traces from 'nearby stations' that begin five
% minutes before the theoretical first-arriving phase of the
% corresponding to event ID and saves the returned SAC files to
% [sacdir]/[id]/*.SAC.
%
% If the traces are split (and thus saved as separate SAC files) due
% to missing data they are merged into a single SAC file using
% mergenearbytraces.m, which also sends those individual SAC files to
% a child directory named 'unmerged'.
%
% Any existing SAC files removed, e.g., in the case of redo = true,
% are printed to the screen.*
%
% Requires program: SAC
%
% Input:
% id        Event ID [last column of 'identified.txt'] (def: 11052554)
% redo      true to delete* existing [sacdir]/sac/[id]/ SAC files and
%               refetch SAC files (def: false)
% txtfile   Filename of textfile of station metadata from http://ds.iris.edu/gmap/
%               (def: $MERMAID/events/nearbystations/nearbystations.txt)
% evtdir    Path to directory containing 'raw/' and 'reviewed'
%               subdirectories (def: $MERMAID/events/)
% sacdir    Directory to write [id]/*.SAC
%               (def: $MERMAID/events/nearbystations/sac/)
% model     Taup model (def: 'ak135')
% ph        Taup phases (def: defphases)
%
% Output: (both empty in case of redo = false and refetch not required)
% tr        Cell of trace(s) returned by irisFetch.Traces,
%               if any (def: {})
% merged    Cell of merged filenames, if any (def: {})
%
% *git history, if it exists, is respected with gitrmdir.m.
%
% Ex:
%    [tr, merged] = FETCHNEARBYTRACES('11052554')
%
% See also: evt2txt.m, readidentified.m, mergenearbytraces.m, gitrmdir.m, mergesac
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 23-Nov-2019, Version 2017b on MACI64

% Defaults.
defval('id', '11052554')
defval('redo', false)
defval('txtfile', fullfile(getenv('MERMAID'), 'events', 'nearbystations', 'nearbystations.txt'))
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('sacdir', fullfile(getenv('MERMAID'), 'events', 'nearbystations', 'sac'))
defval('model', 'ak135')
defval('ph', defphases)
tr = {};
merged = {};

% Determine if execution of main should proceed based on the 'redo'
% flag and the existence (or not) of SAC files.
id = strtrim(num2str(id));
iddir = fullfile(sacdir, id);
if ~need2continue(redo, iddir)
    fprintf('ID %s .SAC files already fetched\n', id)
    return

end

% Get the EQ structures associated with this event.
[sac, EQ] = getsacevt(id, evtdir);

% Keep only the first: they may differ in origin time slightly
% depending on catalog and when they were last queried, but they
% should all be roughly the same.
EQ = EQ{1}(1);
evtdate = datetime(irisstr2date(EQ.PreferredTime));

% Get all the nearby stations.
[network, station, datacenter] =  parsenearbystations(txtfile);

tr_idx = 0;
for i = 1:length(station)
    % Determine the relevant web addresses (until the 'federated' option
    % works for RASPISHAKE this will have to suffice).
    switch upper(datacenter{i}{:})
      case 'IPGP'
        DATASELECTSERVICE = 'http://ws.ipgp.fr/fdsnws/dataselect/1/';
        STATIONSERVICE = 'http://ws.ipgp.fr/fdsnws/station/1/';

      case 'IRISDMC'
        DATASELECTSERVICE = 'http://service.iris.edu/fdsnws/dataselect/1/';
        STATIONSERVICE = 'http://service.iris.edu/fdsnws/station/1/';

      case 'RASPISHAKE'
        % Raspberry Shake naming convention: AM.R????.00.?HZ
        % SHZ:  50 sps
        % EHZ: 100 sps
        % https://manual.raspberryshake.org/stationNamingConvention.html
        DATASELECTSERVICE = 'https://fdsnws.raspberryshakedata.com/fdsnws/dataselect/1/';
        STATIONSERVICE = 'https://fdsnws.raspberryshakedata.com/fdsnws/station/1/';

      otherwise
        % Add more cases as issues arise.
        error('Unexpected datacenter: %s', datacenter)

    end

    % Consider all locations: they can be, e.g., '00', '10', etc., or '' (empty).
    location = '*';

    % See: https://ds.iris.edu/ds/nodes/dmc/data/formats/seed-channel-naming/
    % Here I consider channels most similar to MERMAID's sampling rate.
    channel = ['M*Z,' ...  %             Mid period: >   1 <  10 Hz
               'B*Z,' ...  %             Broad band: >= 10 <  80 Hz
               'H*Z,' ...  %        High broad band: >= 80 < 250 Hz
               'S*Z,' ...  %           Short period: >= 10 <  80 Hz (Raspbery Shake)
               'E*Z'];     % Extremely short period: >= 80 < 250 HZ (Raspbery Shake)

    % See: http://www.fdsn.org/pdf/SEEDManual_V2.4.pdf.
    % Choices are D, R, Q, M. M seems to assure best quality ("Data center
    % modified, time-series values have not been changed")
    % irisFetch.Traces also has B ("best") qaulity indicator that I
    % can't find in the SEED manual and thus don't trust.
    quality = 'M';

    % Find the location of the station on the day of the event
    % (stations move and maintain the same name, unfortunately).
    starttime = fdsndate2str(evtdate);
    endtime = fdsndate2str(evtdate + days(1));
    sta = irisFetch.Stations('STATION', network{i}, station{i}, ...
                             location, channel, 'start', starttime, ...
                             'end', endtime, 'baseurl', STATIONSERVICE);

    % Move to next station if this stations did not exist / was down on
    % the day of the event.
    if isempty(sta)
        continue

    end

    % The sta structure will almost always be of length 1.  It is
    % larger when the station is turned off/on, and/or moved.
    for j = 1:length(sta)
        % Compute theoretical arrival times of the requesetd phases at
        % this station.
        tt = taupTime(model, EQ.PreferredDepth, ph, ...
                      'station', [sta(j).Latitude sta(j).Longitude], ...
                      'event', [EQ.PreferredLatitude EQ.PreferredLongitude]);

        % Move to next station if there exist no phase arrivals of the type
        % requested at this station for this event.
        if isempty(tt)
            continue

        end

        % Ensure the station was at the purpoted location at the
        % time of the first arrival.
        first_TaupTime = tt(1);
        firstarrival_date = evtdate + seconds(first_TaupTime.time);
        if  ~isempty(sta(j).EndDate) % assume still active if EndDate empty
            if ~isbetween(firstarrival_date, ...
                          irisstr2date(sta(j).StartDate), irisstr2date(sta(j).EndDate))
                continue

            end
        end

        % Base the query time for the traces off the time of the
        % first-arriving phase.
        starttime = irisdate2str(firstarrival_date - minutes(5));
        endtime = irisdate2str(firstarrival_date + minutes(55));

        % Fetch and write.
        traces = irisFetch.Traces(network{i}, station{i}, location, ...
                                  channel, starttime, endtime, quality, ...
                                  ['DATASELECTURL:' DATASELECTSERVICE], ...
                                  ['STATIONURL:' STATIONSERVICE]);

        % Keep only nonempty traces.
        if ~isempty(traces)
            tr_idx = tr_idx + 1;
            tr{tr_idx} = traces;
            irisFetch.Trace2SAC(tr{tr_idx}, iddir);

        end
    end
end

% Merge split SAC files if necessary.
merged = mergenearbytraces(tr, id, sacdir);

%______________________________________________________________%
function cont = need2continue(redo, iddir)
% Output: cont --> logical continuation flag

% By default redo is false. However, if no SAC files exist main needs
% to continue execution.  Therefore, determine if SAC files exist and
% base continuation flag on the combination of the user-requested redo
% flag and the existence or lack thereof of SAC files.

sac_files_exist = false;
if exist(iddir, 'dir') == 7
    dsac = skipdotdir(dir(fullfile(iddir, '**/*SAC')));
    if ~isempty(dsac)
        sac_files_exist = true;

    end
end

if redo
    cont = true;
    if sac_files_exist
        % Delete all current SAC files before the requested redo.
        [git_removed, deleted] = gitrmdir(dsac)

    end

else
    if sac_files_exist
        cont = false;

    else
        cont = true;

    end
end
