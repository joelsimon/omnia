function [nearby_EQ, nearby_EQu] = nearbysac2evt(id, redo, mer_evtdir, mer_sacdir, nearbydir, model, ph, baseurl)
% [nearby_EQ, nearby_EQu] = NEARBYSAC2EVT(id, redo, mer_evtdir, mer_sacdir, nearbydir, model, ph, baseurl)
%
% NEARBYSAC2EVT runs sac2evt.m on all SAC files related to a single
% event ID contained in [nearbydir]/sac/[id], and saves the output EQ
% structures in .evt files in [nearbydir]/evt/[id].
%
% Any existing .evt files removed, e.g., in the case of redo = true,
% are printed to the screen.*
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
% Last modified: 26-Nov-2019, Version 2017b on GLNXA64

% Defaults.
defval('id', '10948555')
defval('redo', false)
defval('mer_evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('mer_sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('nearbydir', fullfile(getenv('MERMAID'), 'events', 'nearbystations'))
defval('model', 'ak135')
defval('ph', defphases)
defval('baseurl', 1);
nearby_EQ = {};
nearby_EQu = {};

% Pull the MERMAID and nearby SAC & .evt files (the latter may not yet
% exist) and see what the current status is.
id = strtrim(num2str(id));
if strcmp(id(1), '*')
    id(1) = [];

end

% Grab all nearby stations' SAC files.
[nearby_sac, nearby_sacu] = getnearbysac(id, [], nearbydir);

%
if ~isempty(nearby_sac)
    evt_path = fullfile(nearbydir, 'evt', id);
    nearby_EQ = main(id, redo, nearby_sac, evt_path, model, ph, baseurl);

end

if ~isempty(nearby_sacu)
    evtu_path = fullfile(nearbydir, 'evt', id, 'unmerged');
    nearby_EQu = main(id, redo, nearby_sacu, evtu_path,  model, ph, baseurl);

end

%________________________________________________________________________________%
function EQ = main(id, redo, sac, evt_path, model, ph, baseurl)

% Determine if continued execution of nearbysac2evt.m is necessary: if
% .evt files exist, their names match the corresponding SAC files, and
% redo=false, continuation is not warranted.
if ~need2continue(id, redo, sac, evt_path)
    fprintf('ID %s .evt files already fetched\n', id)
    return

end
[~, foo] = mkdir(evt_path);

% Run sac2evt.m once for this specific event using the first nearby
% SAC file.  Fetch the updated metadata once and then recompute phase
% arrival times the next 2:end cases below.

len_empty = 0;
for i = 1:length(sac)
    EQ_template = sac2evt(sac{i}, model, ph, baseurl, 'eventid', id);
    if ~isempty(EQ_template)
        % We only need one EQ for a template against which we may compute
        % theoretical arrival times; the corresponding event will be
        % the same for all SAC files.
        % Copy the updated event into an template which will be customized for
        % each nearby SAC file.
        EQ_template = rmfield(EQ_template, 'Filename');
        EQ_template = rmfield(EQ_template, 'TaupTimes');
        EQ_template.Picks = []; % I currently do not save picks, but for future...

        % Parse event metadata information, the same for all nearby SAC files
        % (we are working with a single event), for arrivaltime.m
        evtdate = irisstr2date(EQ_template.PreferredTime);
        evla = EQ_template.PreferredLatitude;
        evlo = EQ_template.PreferredLongitude;
        evdp = EQ_template.PreferredDepth;
        break

    else
        len_empty = len_empty + 1;

    end
end

for i = 1:length(sac)
    if i > len_empty
        % Read the header specific to this nearby SAC file.
        [~, h] = readsac(sac{i});

        % Compute the theoretical phase arrival times.
        tt = arrivaltime(h, evtdate, [evla evlo], model, evdp, ph, h.B);

        % If phases theoretically arrive in the time window of the seismogram
        % attach that info and compute their 'expected' pressure.
        if ~isempty(tt)
            EQ = EQ_template;
            EQ.Filename = strippath(sac{i});
            EQ.TaupTimes = tt;
            EQ = reidpressure(EQ);
            EQ = orderfields(EQ);

        else
            % If no phases arrive in the time window save an empty EQ structure.
            EQ = [];

        end
    else
        % Save an empty EQ structure if you already looped past this SAC file
        % in search of an EQ template and found no phase arrivals.
        EQ = [];

    end

    % Save the EQ structure in an appropriately named .evt file.
    evt_name = fullfile(evt_path, strrep(strippath(sac{i}), 'SAC', 'evt'));
    save(evt_name, 'EQ', '-mat')
    EQ_list{i} = EQ;
    clearvars('EQ')

end
EQ = EQ_list(:);

%________________________________________________________________________________%
function cont = need2continue(id, redo, sac, evt_path)
% Output: cont --> logical continuation flag

% If .evt files already exist verify their filenames match those, and
% only those, of the SAC files.
evt_dir = dir(fullfile(evt_path, '*.evt'));
if ~isempty(evt_dir)
    evt_files_exist = true;
    if length(evt_dir) ~= length(sac)
        evt_matches_sac = false;

    else
        for i = 1:length(sac)
            nopath_sac{i} = strippath(sac{i});
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
