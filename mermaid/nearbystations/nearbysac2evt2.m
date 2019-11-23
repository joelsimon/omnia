function EQ = nearbysac2evt2(id, redo, mer_evtdir, mer_sacdir, nearbydir, model, ph, baseurl)
% EQ = NEARBYSAC2EVT2(id, redo, mer_evtdir, mer_sacdir, nearbydir, model, ph, baseurl)
%
% NEARBYSAC2EVT2 is nearbysac2evt, but for the unmerged (incomplete)
% SAC files.  It is required you run the latter before this function.
%
% Input:
% id            Event ID [last column of 'identified.txt']
%                   defval('11052554')
% redo          true to delete* existing [nearbydir]/evt/[id]/ .evt files and
%                   refetch .evt files with sac2evt.m (def: false)
% mer_evtdir    Path to directory containing MERMAID 'raw/' and 'reviewed/'
%                   subdirectories (def: $MERMAID/events/)
% mer_sacdir    Path to directory to be (recursively) searched for
%                   MERMAID SAC files (def: $MERMAID/processed/)
% nearbydir     Path to directory containing nearby stations
%                   'sac/' and 'evt/' subdirectories
%                   (def: $MERMAID/events/nearbystations/)
% model         Taup model (def: 'ak135')
% ph            Taup phases (def: defphases)
% baseurl       1: 'http://service.iris.edu/fdsnws/event/1/' (def)
%               2: 'https://earthquake.usgs.gov/fdsnws/event/1/'
%               3: 'http://isc-mirror.iris.washington.edu/fdsnws/event/1/'
%               4: 'http://www.isc.ac.uk/fdsnws/event/1/'
%
% *git history, if it exists, is respected with gitrmdir.m.
%
% Output:
% *N/A*    (writes reviewed .evt file)
% EQ       EQ structures for each 'nearby' SAC file, 
%             or [] if already fetched and redo not required
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 26-Sep-2019, Version 2017b on GLNXA64

% Defaults.
defval('id', '10948555')
defval('redo', false)
defval('mer_evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('mer_sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('nearbydir', fullfile(getenv('MERMAID'), 'events', 'nearbystations'))
defval('model', 'ak135')
defval('ph', defphases)
defval('baseurl', 1);
EQ = [];

% Pull the MERMAID and nearby SAC & .evt files (the latter may not yet
% exist) and see what the current status is.
id = strtrim(num2str(id));
if strcmp(id(1), '*')
    id(1) = [];

end

[~, ~, nearby_sac2] = getnearbysacevt2(id, mer_evtdir, mer_sacdir, nearbydir);
if isempty(nearby_sac2)
    fprintf('ID %s contains no unmerged SAC files\n', id)
    return

end

% Decide where the .evt files exist/will be saved; make that folder if
% it does not exist.
evt_path = fullfile(nearbydir, 'evt', id, 'unmerged');

% Determine if continued execution of nearbysac2evt.m is necessary: if
% .evt files exist, their names match the corresponding SAC files, and
% redo=false, continuation is not warranted.
if ~need2continue(id, redo, nearby_sac2, nearbydir, evt_path)
    fprintf(['\nID %s already run: %s/\nSet ''redo'' = true to rerun ' ...
             '%s\n\n'], id, evt_path, mfilename)

    return

end
[~, foo] = mkdir(evt_path);

% Instead of fetching once, we use the nearby_EQ as a template.
[~, ~, ~, nearby_EQ] = getnearbysacevt(id, mer_evtdir, mer_sacdir, nearbydir); % N.B. not getnearbysacevt2.m!
EQ_template = nearby_EQ{1};
clearvars('nearby_EQ');
EQ_template = rmfield(EQ_template, 'Filename');
EQ_template = rmfield(EQ_template, 'TaupTimes');

% Parse event metadata information, the same for all nearby SAC files
% (we are working with a single event), for arrivaltime.m
evtdate = irisstr2date(EQ_template.PreferredTime);
evla = EQ_template.PreferredLatitude;
evlo = EQ_template.PreferredLongitude;
evdp = EQ_template.PreferredDepth;

indexed_EQ{1} = EQ;
for i = 1:length(nearby_sac2)
    % Read the header specific to this nearby SAC file.
    [~, h] = readsac(nearby_sac2{i});

    % Compute the theoretical phase arrival times.
    tt = arrivaltime(h, evtdate, [evla evlo], model, evdp, ph, h.B);

    EQ = EQ_template;
    EQ.Filename = strippath(nearby_sac2{i});
    EQ.TaupTimes = tt;
    EQ = reidpressure(EQ);
    EQ = orderfields(EQ);

    evt_name = fullfile(evt_path, strippath(EQ.Filename));
    sac_suffix = suf(evt_name);
    evt_name(end-length(sac_suffix):end) = '.evt';

    save(evt_name, 'EQ', '-mat')

    indexed_EQ{i} = EQ;
    clearvars('EQ')

end
EQ = indexed_EQ;

%______________________________________________________________%
function cont = need2continue(id, redo, nearby_sac2, nearbydir, evt_path)
% Output: cont --> logical continuation flag

% Sanity: ensure nearby SAC files exist to convert to generate .evt files.
if isempty(nearby_sac2)
    error('No nearbystations SAC files associated with event id: %s', id)
    cont = false;
    return

end

% If .evt files already exist verify their filenames match those, and
% only those, of the SAC files.
evt_dir = dir(fullfile(evt_path, '*.evt'));
if ~isempty(evt_dir)
    evt_files_exist = true;
    if length(evt_dir) ~= length(nearby_sac2)
        evt_matches_sac = false;

    else
        for i = 1:length(nearby_sac2)
            nopath_sac{i} = strippath(nearby_sac2{i});
            nopath_evt{i} = evt_dir(i).name;

            nopath_sac{i}(end-3:end) = [];
            nopath_evt{i}(end-3:end) = [];

        end
        nopath_sac = sort(nopath_sac);
        nopath_evt = sort(nopath_evt);

        if isequal(nopath_sac, nopath_evt)
            evt_matches_sac = true;

        else
            evt_matches_sac = false;

        end
    end
else
    evt_files_exist = false;

end

% Determine continuation.
% Files are removed with gitrmdir.m in two cases:
% (1) redo is true and .evt files exist
% (2) redo is false but .evt filenames do not match .SAC filenames
if redo
    cont = true;
    if evt_files_exist
        [git_removed, deleted] = gitrmdir(evt_dir)

    end
else
    if evt_files_exist
        if evt_matches_sac
            cont = false;

        else
            cont = true;
            [git_removed, deleted] = gitrmdir(evt_dir)

        end
    else
        cont = true;

    end
end
