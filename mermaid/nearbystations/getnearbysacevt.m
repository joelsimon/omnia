function [mer_sac, mer_EQ, nearby_sac, nearby_EQ] = ...
    getnearbysacevt(id, mer_evtdir, mer_sacdir, nearbydir, check4update, returntype)
% [mer_sac, mer_EQ, nearby_sac, nearby_EQ] = ...
%      GETNEARBYSACEVT(id, mer_evtdir, mer_sacdir, nearbydir, check4update, returntype)
%
% GETNEARBYSACEVT returns SAC filenames and EQ structures corresponding
% to an input event ID for MERMAID data and their nearby stations.
%
% Input:
% id            Event identification number in last
%                   column of identified.txt(def: 10948555)
% mer_evtdir    Path to directory containing MERMAID 'raw/' and 'reviewed'
%                   subdirectories (def: $MERMAID/events/)
% mer_sacdir    Path to directory to be (recursively) searched for
%                   MERMAID SAC files (def: $MERMAID/processed/)
% nearbydir     Path to directory containing nearby stations
%                   'sac/' and 'evt/' subdirectories
%                   (def: $MERMAID/events/nearbystations/)
% check4update  true to determine if resultant EQs need updating
%                   (def: true)
% returntype    For third-generation+ MERMAID only:
%               'ALL': both triggered and user-requested SAC files (def)
%               'DET': triggered SAC files as determined by onboard algorithm
%               'REQ': user-requested SAC files
%
% Output:
% mer_sac       Cell array of MERMAID SAC files
% nearby_sac    Cell array of 'nearby stations' SAC files*
% mer_EQ        Reviewed EQ structures for each MERMAID SAC file
% nearby_EQ     EQ structures for each 'nearby stations' SAC file
%
% Ex:
%    [mer_sac, mer_EQ, nearby_sac, nearby_EQ] = ...
%      GETNEARBYSACEVT('10948555')
%
% See also: fetchnearbytraces.m, getsacevt.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 01-Oct-2019, Version 2017b on MACI64

% Defaults.
defval('id', '10948555')
defval('mer_evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('mer_sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('nearbydir', fullfile(getenv('MERMAID'), 'events', 'nearbystations'))
defval('check4update', true)
defval('returntype', 'ALL')

%% MERMAID data --

% Can use getsacevt.m because dir structure organized as getsacevt.m
% expects.
id = strtrim(num2str(id));
[mer_sac, mer_EQ] = getsacevt(id, mer_evtdir, mer_sacdir, false, returntype);

%% Nearby station data --

if strcmp(id(1), '*')
    % Remove leading asterisks from ID number, if one exists.
    % Already ample warnings about possible multiple events in getsacevt.m.
    id(1) = [];

end

% N.B. the above note only applies to MERMAID data: nearbysac2evt.m
% automatically queries a SINGLE event and the .evt file only every
% has a SINGLE EQ structure.

nearby_SACdir = skipdotdir(dir(fullfile(nearbydir, 'sac', id, '*.SAC')));
nearby_sacdir = skipdotdir(dir(fullfile(nearbydir, 'sac', id, '*.sac')));
nearby_sacdir = [nearby_SACdir ; nearby_sacdir];
if ~isempty(nearby_sacdir)
    for i = 1:length(nearby_sacdir)
        if ~nearby_sacdir(i).isdir
            nearby_sac{i} = fullfile(nearby_sacdir(i).folder, nearby_sacdir(i).name);

        end
    end
else
    warning('Empty: %s', fullfile(nearbydir, 'sac', id))
    nearby_sac = {};

end
nearby_sac = unique(nearby_sac(:));

nearby_evtdir = skipdotdir(dir(fullfile(nearbydir, 'evt', id, '*.evt')));
if length(nearby_evtdir) ~= length(nearby_sac)
    error(['The number of nearby SAC files and nearby .evt files ' ...
           'differs for event ID: %s'], id)

end

if ~isempty(nearby_evtdir)
    for i = 1:length(nearby_sac);
        nearby_evt_file = strippath(nearby_sac{i});
        nearby_evt_file = nearby_evt_file(1:end-3);
        nearby_evt_file = [nearby_evt_file 'evt'];
        tmp = load(fullfile(nearby_evtdir(i).folder, nearby_evt_file), '-mat');
        nearby_EQ{i} = tmp.EQ;
        clearvars('tmp')

    end
else
    warning('Empty: %s', fullfile(nearbydir, 'evt', id))
    nearby_EQ = {};

end
nearby_EQ = nearby_EQ(:);

% Test if we need to update the files associated with this event ID.
if check4update && need2updateid([mer_EQ ; nearby_EQ], id)
    warning(['Event metadata differs between EQ structures.\nTo ' ...
             'update run updateid(''%s'')'], id)

end
