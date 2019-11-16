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
% mergenearbytraces.m.
%
% Any existing SAC files removed, e.g., in the case of redo = true,
% are printed to the screen.*
%
% Requires program: SAC
%
% Input:
% id        Event ID [last column of 'identified.txt']
%               defval('11052554')
% redo      true to delete* existing [sacdir]/sac/[id]/ SAC files and
%               refetch SAC files (def: false)
% txtfile   Filename of textfile of station metadata from http://ds.iris.edu/gmap/
%               (def: $MERMAID/events/nearbystations/nearbystations.txt)
% evtdir    Path to directory containing 'raw/' and 'reviewed'
%               subdirectories (def: $MERMAID/events/)
% sacdir    Directory to write [id]/*.SAC
%               (def: $MERMAID/events/nearbystations/sac/)
% model         Taup model (def: 'ak135')
% ph            Taup phases (def: defphases)
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
% Last modified: 14-Sep-2019, Version 2017b on GLNXA64

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
    fprintf('ID %s already fetched\n', id)
    return

end

% Get the EQ structures associated with this event.
[sac, EQ] = getsacevt(id, evtdir);

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
    tt = taupTime(model, EQ.PreferredDepth, ph, 'station', ...
                  [station_latitude{i} station_longitude{i}], 'event', ...
                  [EQ.PreferredLatitude EQ.PreferredLongitude]);
    if isempty(tt)
        continue

    end

    % Base the query time off the first arriving phase.
    first_TaupTime = tt(1);
    firstarrival_date = evtdate + seconds(first_TaupTime.time);

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
        includePZ  = true;

      case 'IRISDMC'
        DATASELECTSERVICE = 'http://service.iris.edu/fdsnws/dataselect/1/';
        STATIONSERVICE = 'http://service.iris.edu/fdsnws/station/1/';
        CHANNEL = 'BHZ';
        includePZ  = true;

      case 'RASPISHAKE'
        DATASELECTSERVICE = 'https://fdsnws.raspberryshakedata.com/fdsnws/dataselect/1/';
        STATIONSERVICE = 'https://fdsnws.raspberryshakedata.com/fdsnws/station/1/';
        CHANNEL = '*Z';
        includePZ  = false; % true breaks the call to irisFetch.Traces...

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
        irisFetch.Trace2SAC(tr{tr_idx}, iddir);

        % Write a pole-zero file.
        fetchsacpz(tr{tr_idx}, '/home/jdsimon/mermaid/events/nearbystations/sacpz')

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
    lower_dsac = skipdotdir(dir(fullfile(iddir, '**/*sac')));
    upper_dSAC = skipdotdir(dir(fullfile(iddir, '**/*SAC')));

    %% N.B.: By default Mac systems are case-insensitive, so the
    %% above will duplicate *.sac and *SAC -- filename uniqueness
    %% is ensured via recursivedir.m, called by gitrmdir.m.
    dsac = [lower_dsac ; upper_dSAC];

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
