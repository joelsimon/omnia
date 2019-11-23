function [mer_sac, mer_EQ, nearby_sac2, nearby_EQ2] = ...
    getnearbysacevt2(id, mer_evtdir, mer_sacdir, nearbydir, check4update, returntype)
% [mer_sac, mer_EQ, nearby_sac2, nearby_EQ2] = ...
%      GETNEARBYSACEVT2(id, mer_evtdir, mer_sacdir, nearbydir, check4update, returntype)
%
% GETNEARBYSACEVT2 is getnearbysacevt, but for the unmerged (incomplete) SAC files.
%
% Input:
% id            Event identification number in last
%                   column of identified.txt (def: 11052554)
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
% nearby_sac2   Cell array of unmerged 'nearby stations' SAC files*
% mer_EQ        Reviewed EQ structures for each MERMAID SAC file
% nearby_EQ2    EQ structures for each unmerged 'nearby stations' SAC file
%
% Ex:
%    [mer_sac, mer_EQ, nearby_sac2, nearby_EQ2] = ...
%      GETNEARBYSACEVT('10948555')
%
% See also: fetchnearbytraces.m, getsacevt.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 01-Oct-2019, Version 2017b on MACI64

% Defaults.
defval('id', '11052554')
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

nearby_SAC2dir = skipdotdir(dir(fullfile(nearbydir, 'sac', id, 'unmerged', '*.SAC')));
nearby_sac2dir = skipdotdir(dir(fullfile(nearbydir, 'sac', id, 'unmerged', '*.sac')));
nearby_sac2dir = [nearby_SAC2dir ; nearby_sac2dir];
if ~isempty(nearby_sac2dir)
    for i = 1:length(nearby_sac2dir)
        if ~nearby_sac2dir(i).isdir
            nearby_sac2{i} = fullfile(nearby_sac2dir(i).folder, nearby_sac2dir(i).name);

        end
    end
else
    %warning('Empty: %s', fullfile(nearbydir, 'sac', 'unmerged', id))
    nearby_sac2 = {};

end
nearby_sac2 = unique(nearby_sac2(:));

% We want the number of SAC files and .evt files to be allowed to
% differ if we add more SAC files and have not yet made the associated
% .evt files, e.g., in nearbysac2evt.m.  There call this function with
% just 3 outputs.
if nargout == 4
    nearby_evtdir = skipdotdir(dir(fullfile(nearbydir, 'evt', id, 'unmerged', '*.evt')));
    if ~isempty(nearby_evtdir)
        if length(nearby_evtdir) ~= length(nearby_sac2)
            error(['The number of nearby SAC files and nearby .evt files ' ...
                   'differs for event ID: %s'], id)

        end

        for i = 1:length(nearby_sac2);
            nearby_evt_file = strippath(nearby_sac2{i});
            nearby_evt_file = nearby_evt_file(1:end-3);
            nearby_evt_file = [nearby_evt_file 'evt'];
            tmp = load(fullfile(nearby_evtdir(i).folder, nearby_evt_file), '-mat');
            nearby_EQ2{i} = tmp.EQ;
            clearvars('tmp')

        end
    else
        %warning('Empty: %s', fullfile(nearbydir, 'evt', 'unmerged', id))
        nearby_EQ2 = {};

    end
    nearby_EQ2 = nearby_EQ2(:);

    % Test if we need to update the files associated with this event ID.
    if check4update && need2updateid([mer_EQ ; nearby_EQ2], id)
        warning(['Event metadata differs between EQ structures.\nTo ' ...
                 'update run updateid(''%s'')'], id)

    end
end