function [mer_evt, mer_EQ, nearby_evt, nearby_EQ, nearby_evtu, nearby_EQu, cppt_EQ, cppt_evt] = ...
    updateid(id, force, mer_evtdir, mer_sacdir, nearbydir, cpptdir, model, ph, baseurl)
% [mer_evt, mer_EQ, nearby_evt, nearby_EQ, nearby_evtu, nearby_EQu, cppt_EQ, cppt_evt] = ...
%     UPDATEID(id, force, mer_evtdir, mer_sacdir, nearbydir, cpptdir, model, ph, baseurl)
%
% UPDATEID refetches event metadata from IRIS and updates (overwrites)
% the associated .evt files for a given event ID.
%
% This function requires irisFetch.Events and an internet connection.
%
% N.B.: ONLY THE EVENT DETAILS ARE CONSIDERED in determining if an
% update is required, e.g., if the .PhasesConsidered differ between EQ
% structures, but the underlying event metadata to which they apply
% are equal, this function will not continue unless force is true.
%
% Input:
% id            Event identification number in last
%                   column of identified.txt(def: 10948555)
% force         true to force update (refetch) even when not required
%                   (def: false)
% mer_evtdir    Path to directory containing MERMAID 'raw/' and 'reviewed'
%                   subdirectories (def: $MERMAID/events/)
% mer_sacdir    Path to directory to be (recursively) searched for
%                   MERMAID SAC files (def: $MERMAID/processed/)
% nearbydir     Path to directory containing nearby stations
%                   'sac/' and 'evt/' subdirectories
%                   (def: $MERMAID/events/nearbystations/)
% cpptdir     Path to directory containing CPPT stations
%                   'sac/' and 'evt/' subdirectories
%                   (def: $MERMAID/events/cpptstations/)
% model         Taup model (def: 'ak135')
% ph            Taup phases (def: defphases)
%                   N.B.: use force=true to update with new phases
%                   in the case that update not required
% baseurl       1: 'http://service.iris.edu/fdsnws/event/1/' (def)
%               2: 'https://earthquake.usgs.gov/fdsnws/event/1/'
%               3: 'http://isc-mirror.iris.washington.edu/fdsnws/event/1/'
%               4: 'http://www.isc.ac.uk/fdsnws/event/1/'
%
% Output:
% *N/A*        Overwrites relevant .evt files with updated
%                  event metadata
% *_evt      Full path to updated reviewed .evt files
%                  (MERMAID, 'nearby' stations including unmerge, and CPPT)
% *_EQ       Updated EQ structures
%                  (MERMAID, 'nearby' stations including unmerged, and CPPT)
%
% *git history, if it exists, is respected with gitrmdir.m.
%
% See also: need2updateid.m, updateeq.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 01-Feb-2020, Version 2017b on GLNXA64

% Defaults.
defval('id', '10937574')
defval('force', false)
defval('mer_evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('mer_sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('nearbydir', fullfile(getenv('MERMAID'), 'events', 'nearbystations'))
defval('cpptdir', fullfile(getenv('MERMAID'), 'events', 'cpptstations'))
defval('model', 'ak135')
defval('ph', defphases)
defval('baseurl', 1);

mer_sac = {};
mer_evt = {};
mer_EQ = {};

nearby_sac = {};
nearby_evt = {};
nearby_EQ = {};
nearby_sacu = {};
nearby_evtu = {};
nearby_EQu = {};

cppt_sac = {};
cppt_evt = {};
cppt_EQ = {};


% Retrieve all MERMAID EQ files associated with this event -- will
% always exist because you matched on that event. No need to
% check4update because that happens here, next.
id = num2str(id);
[mer_sac, mer_EQ] = getsacevt(id, mer_evtdir, mer_sacdir, false, 'ALL');

%% Do not retrieve mer_* info in getnearbysacevt.m or getcpptsacevt.m
%% because those will fail if nearby/CPPT data do not exist.  We do not
%% want to make the retrieval of MERMAID data hinge on the existence of
%% other data; MERMAID data will always exist here and thus this
%% function sill always AT LEAST check those EQ structures.

% Retrieve all 'nearby' EQ files associated with this event. N.B.:
% 'otype' is irrelevant here because it applies to the .SAC files, not
% the .evt files, which apply to the same SAC files regardless of
% 'otype'.
nearby_idpath = fullfile(nearbydir, 'evt', id);
nearby_iddir = dir(fullfile(nearby_idpath, '**/*.evt'));
if ~isempty(nearby_iddir)
    [~, ~, nearby_sac, nearby_EQ, nearby_sacu, nearby_EQu] = ...
        getnearbysacevt(id, mer_evtdir, mer_sacdir, nearbydir, false, 'ALL');

end

% Repeat the same fetch for CPPT data.
cppt_idpath = fullfile(cpptdir, 'evt', id);
cppt_iddir = dir(fullfile(cppt_idpath, '**/*.evt'));
if ~isempty(cppt_iddir)
    [~, ~, cppt_sac, cppt_EQ] = ...
        getcpptsacevt(id, mer_evtdir, mer_sacdir, cpptdir, false, 'ALL');

end

% Determine if the EQ structures differ and exit if they do not.
if ~force && ~need2updateid([mer_EQ; nearby_EQ; nearby_EQu; cppt_EQ], id)
    fprintf('ID %s: update not required, all metadata match\n', id)
    return

end

% Fetch the most up-to-date information associated with this event.
% Okay to do this just once because we know this SAC file is matched
% to this event ID; so unless this event was removed after
% seismologist review or something the metadata should still exist.
updated_EQ = sac2evt(mer_sac{1}, model, ph, baseurl, 'eventid', id);

%% Apply the updated info to all EQ structs.

% MERMAID -- EQ will always exist because this is what you matched on.
[mer_evt, mer_EQ] = main(updated_EQ, mer_EQ, mer_sac, fullfile(mer_evtdir, 'reviewed', 'identified', 'evt'), model, ph);

% Nearby stations -- may not exist.
[nearby_evt, nearby_EQ] = main(updated_EQ, nearby_EQ, nearby_sac, fullfile(nearbydir, 'evt', id), model, ph);

% Nearby stations, unmerged -- may not exist.
[nearby_evtu, nearby_EQu] = main(updated_EQ, nearby_EQu, nearby_sacu, fullfile(nearbydir, 'evt', id, 'unmerged'), model, ph);

% CPPT stations -- may not exist.
[cppt_evt, cppt_EQ] = main(updated_EQ, cppt_EQ, cppt_sac, fullfile(cpptdir, 'evt', id), model, ph);

%___________________________________________________________________________________________%
function [rev_evt, rev_EQ] = main(updated_EQ, old_EQ, sac, evt_path, model, ph)
% This function applies the updated EQ metadata.

rev_evt = {};
rev_EQ = {};
if ~isempty(old_EQ)
    idx = 0;
    for i = 1:length(old_EQ)
        idx = idx + 1;
        EQ = updateeq(updated_EQ, old_EQ{i}, sac{i}, model, ph);

        % Do not use strrep due to determine .evt file name because of
        % different suffix: .sac (MERMAID) and .SAC (nearby)
        sacname = strippath(sac{i});
        rev_evt{idx} = fullfile(evt_path, [sacname(1:end-3) 'evt']);
        save(rev_evt{idx}, 'EQ', '-mat')

        rev_EQ{i} = EQ;
        clearvars('EQ')

    end
    rev_evt = rev_evt(:);
    rev_EQ = rev_EQ(:);
end
