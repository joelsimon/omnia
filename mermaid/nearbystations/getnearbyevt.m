function [nearby_EQ, nearby_EQu, nearby_evt, nearby_evtu] = getnearbyevt(id, nearbydir)
% [nearby_EQ, nearby_EQu, nearby_evt, nearby_evtu] = GETNEARBYEVT(id, nearbydir)
%
% Return the EQ structures(s) in [nearbydir]/evt/[id].
%
% Input:
% id           IRIS public event identification number
%                  (def: 10948555)
% nearbydir    Path to directory containing nearby stations
%                   'sac/' and 'evt/' subdirectories
%                   (def: $MERMAID/events/nearbystations/)
%
% Output:
% nearby_EQ   Cell array of EQ structures related to nearby
%                 stations' SAC files
% nearby_EQu  Cell array of EQ structures related to nearby stations'
%                 unmerged SAC files
% nearby_evt  Full path to .mat file containing nearby_EQ
% nearby_evtu Full path to .mat file containing nearby_EQu
%
% See also: getnearbysacevt.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 25-Nov-2019, Version 2017b on GLNXA64

% Defaults.
defval('id', '10948555')
defval('nearbydir', fullfile(getenv('MERMAID'), 'events', 'nearbystations'))

% Fetch complete evt files in top-level directory.
evt_request =  fullfile(nearbydir, 'evt', id, '*.evt');
[nearby_EQ, nearby_evt] = getem(evt_request);

% Fetch split evt files in child directory.
evtu_request =  fullfile(nearbydir, 'evt', id, 'unmerged', '*.evt');
[nearby_EQu, nearby_evtu] = getem(evtu_request);

%_____________________________________________________________________________%
function [EQ, evt] = getem(evt_request)
evtdir = skipdotdir(dir(evt_request));
if ~isempty(evtdir)
    for i = 1:length(evtdir)
        if ~evtdir(i).isdir
            evt{i} = fullfile(evtdir(i).folder, evtdir(i).name);
            tmp = load(evt{i}, '-mat');
            EQ{i} = tmp.EQ;
            clearvars('tmp')

        end
    end
    [evt, idx] = sort(evt);
    evt = evt(:);
    EQ = EQ(idx);
    EQ = EQ(:);

else
    %warning('No .evt files found matching:\n %s', evt_request);
    evt = {};
    EQ = {};

end
