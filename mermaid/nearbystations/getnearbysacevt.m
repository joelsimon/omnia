function [mer_sac, mer_EQ, nearby_sac, nearby_EQ, nearby_sacu, nearby_EQu] = ...
    getnearbysacevt(id, mer_evtdir, mer_sacdir, nearbydir, check4update, returntype, otype, sac2evtfunc) %**
% [mer_sac, mer_EQ, nearby_sac, nearby_EQ, nearby_sacu, nearby_EQu] = ...
%      GETNEARBYSACEVT(id, mer_evtdir, mer_sacdir, nearbydir, check4update, returntype, otype)
%
% GETNEARBYSACEVT returns SAC filenames and EQ structures corresponding
% to an input event ID for MERMAID and 'nearby' seismic stations.
%
% SAC files and EQ structures associated with 'nearby' stations are only
% returned if corresponding MERMAID data exist for that event ID, for
% that returntype (see Ex2).  To return 'nearby' SAC or EQ information
% regardless of that datas' existence in the MERMAID record, see
% getnearbysac.m and getnearbyevt.m.
%
% Input:
% id            Event identification number in last
%                   column of identified.txt (def: 10948555)
% mer_evtdir    Path to directory containing MERMAID 'raw/' and 'reviewed'
%                   subdirectories (def: $MERMAID/events/)
% mer_sacdir    Path to directory to be (recursively) searched for
%                   MERMAID SAC files (def: $MERMAID/processed/)
% nearbydir     Path to directory containing nearby stations
%                   'sac/' and 'evt/' subdirectories
%                   (def: $MERMAID/events/nearbystations/)
% check4update  true verify EQ metadata does not differ across EQ structures
%                   (def: true; see need2updateid.m)
% returntype    For third-generation+ MERMAID only:
%               'ALL': both triggered and user-requested SAC files (def)
%               'DET': triggered SAC files as determined by onboard algorithm
%               'REQ': user-requested SAC files
% otype         Nearby SAC file output type, see rmnearbyresp.m
%               []: (empty) return raw time series (def)
%               'none': return displacement time series (nm)
%               'vel': return velocity time series (nm/s)
%               'acc': return acceleration time series (nm/s/s)
%
% Output:
% mer_sac       Cell array of MERMAID SAC files
% mer_EQ        Reviewed EQ structures for each MERMAID SAC file
% nearby_sac    Cell array of SAC files from nearby stations
% nearby_EQ     Cell array of EQ structures related to nearby
%                   stations' SAC files
% nearby_sacu   Cell array of unmerged SAC files from nearby stations,
%                   if they exist (see mergenearbytraces.m)
% nearby_EQu    Cell array of EQ structures related to nearby stations'
%                   unmerged SAC files
%
% Ex1:
%    [mer_sac, mer_EQ, nearby_sac, nearby_EQ, nearby_sacu, nearby_EQu] = ...
%      GETNEARBYSACEVT('10948555')
%
% Ex2: (nearby .evt data, though they exist, are not returned because there are
%       no requested ('REQ') MERMAID SAC files associated with this event ID)
%    [a, b, c, d] = GETNEARBYSACEVT('10932551', [], [], [], [], 'DET')
%    [a, b, c, d] = GETNEARBYSACEVT('10932551', [], [], [], [], 'REQ')
%
% See also: fetchnearbytraces.m, nearbysac2evt.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 01-Feb-2020, Version 2017b on MACI64

% Defaults.
defval('id', '10948555')
defval('mer_evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('mer_sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('nearbydir', fullfile(getenv('MERMAID'), 'events', 'nearbystations'))
defval('check4update', true)
defval('returntype', 'ALL')
defval('otype', [])
defval('sac2evtfunc', 'nearbysac2evt') %**

%% MERMAID data --

% Fetch MERMAID SAC files and EQ structures.
id = strtrim(num2str(id));
[mer_sac, mer_EQ] = getsacevt(id, mer_evtdir, mer_sacdir, false, returntype);

% If MERMAID did not see this event, then do not return any
% corresponding nearby SAC or event files.
if isempty(mer_sac) % mer_EQ is empty as well
    nearby_sac = {};
    nearby_EQ = {};
    nearby_sacu = {};
    nearby_EQu = {};
    return

end
%% Nearby station data --

% Remove leading asterisks from ID number, if one exists.
% Already ample warnings about possible multiple events in getsacevt.m.
if strcmp(id(1), '*')
    id(1) = [];

end

% Get nearby SAC files.
[nearby_sac, nearby_sacu] = getnearbysac(id, otype, nearbydir);

% Get nearby EQ structures and their full paths for filename comparison.
[nearby_EQ, nearby_EQu, nearby_evt, nearby_evtu] = getnearbyevt(id, nearbydir);

% Verify the list of nearby EQ structures corresponds exactly to the
% list of nearby SAC files.
all_nearby_sac = [nearby_sac ; nearby_sacu];
all_nearby_evt = [nearby_evt ; nearby_evtu];

if ~isempty(otype)
    all_nearby_sac = cellfun(@(xx) strrep(strippath(xx), ['.' otype], ''), all_nearby_sac, 'UniformOutput', false);

end
all_nearby_sac =  cellfun(@(xx) strrep(strippath(xx), '.SAC', ''), all_nearby_sac, 'UniformOutput', false);

% There is no suffix applied to the 'nearby' stations' .evt filenames --
% the event metadata is unrelated to the output type of the SAC file.
all_nearby_evt =  cellfun(@(xx) strrep(strippath(xx), '.evt', ''), all_nearby_evt, 'UniformOutput', false);

if ~isequal(all_nearby_sac, all_nearby_evt)
    error(['The lists of nearby .SAC and .evt files differ for ID: ' ...
    '%s\nRemake the latter with: %s(%s, true)'], id, sac2evtfunc, id)

end

%% Verify all EQ structures contain the same event metadata and do not require update --

if check4update && need2updateid([mer_EQ ; nearby_EQ ; nearby_EQu], id)
    warning(['Event metadata differs between EQ structures.\nTo ' ...
             'update run updateid(''%s'')'], id)

end

% ** N.B.: sac2evtfunc is an undocumented input to adjust warning in case
% all_nearby_sac and all_nearby_evt lists differ because this function
% is called for CPPT data as well (getcpptsacevt.m is just a wrapper
% that points here), and if THOSE data need update then the warning
% should say cpptsac2evt.m, not nearbysac2evt.m.
