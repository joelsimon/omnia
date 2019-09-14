function rev_evt = updateid(id, force, mer_evtdir, mer_sacdir, nearbydir, model, ph, baseurl)
% rev_evt = UPDATEID(id, force, mer_evtdir, mer_sacdir, nearbydir, model, ph, baseurl)
%
% UPDATEID refetches event metadata from IRIS and updates (overwrites)
% the associated .evt files for a given event ID.
%
% This function requires irisFetch.Events and an internet connection.
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
% model         Taup model (def: 'ak135')
% ph            Taup phases (def: defphases)
% baseurl       1: 'http://service.iris.edu/fdsnws/event/1/' (def)
%               2: 'https://earthquake.usgs.gov/fdsnws/event/1/'
%               3: 'http://isc-mirror.iris.washington.edu/fdsnws/event/1/'
%               4: 'http://www.isc.ac.uk/fdsnws/event/1/'
%
% Output:
% *N/A*        Overwrites relevant .evt files with updated
%                  event metadata
% rev_evt      Full path to updated reviewed .evt files,
%                  or [] if update not required
%
% *git history, if it exists, is respected with gitrmdir.m.
%
% See also: need2updateid.m, updateeq.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 14-Sep-2019, Version 2017b on GLNXA64

% Defaults.
defval('id', '10937574')
defval('force', false)
defval('mer_evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('mer_sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('nearbydir', fullfile(getenv('MERMAID'), 'events', 'nearbystations'))
defval('model', 'ak135')
defval('ph', defphases)
defval('baseurl', 1);

% Retrieve all EQ files associated with this event.
[mer_sac, mer_EQ, nearby_sac, nearby_EQ] = getnearbysacevt(id, mer_evtdir, mer_sacdir, nearbydir);

% Determine if the EQ structures differ and exit if they do not.
if ~force && ~need2updateid([mer_EQ nearby_EQ], id)
    fprintf('ID %s: update not required, all metadata match\n', id)
    rev_evt = [];
    return

end

% Fetch the most up-to-date information associated with this event.
updated_EQ = sac2evt(mer_sac{1}, model, ph, baseurl, 'eventid', id);

% Apply the updated info to all EQ structs.
idx = 0;
for i = 1:length(mer_EQ)
    idx = idx + 1;
    EQ = updateeq(updated_EQ, mer_EQ{i}, mer_sac{i});

    % .Filename is the same for all EQ indices.
    rev_evt{idx} = fullfile(mer_evtdir, 'reviewed', 'identified', 'evt', ...
                        strippath(EQ(1).Filename)); 
    sac_suffix = suf(rev_evt{idx});
    rev_evt{idx}(end-length(sac_suffix):end) = '.evt';

    save(rev_evt{idx}, 'EQ', '-mat')

    mer_EQ{i} = EQ;
    clearvars('EQ')

end

if ~isempty(nearby_EQ)
    for i = 1:length(nearby_EQ)
        idx = idx + 1;
        EQ = updateeq(updated_EQ, nearby_EQ{i}, nearby_sac{i});

        rev_evt{idx} = fullfile(nearbydir, 'evt', id, strippath(EQ(1).Filename));
        sac_suffix = suf(rev_evt{idx});
        rev_evt{idx}(end-length(sac_suffix):end) = '.evt';

        save(rev_evt{idx}, 'EQ', '-mat')

        nearby_EQ{i} = EQ;
        clearvars('EQ')


    end
end
