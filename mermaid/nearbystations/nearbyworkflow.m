function nearbyworkflow
% Fetches nearby traces, fetches the current SACPZ files and removes
% their instrument response, writes their corresponding event files,
% and updates all nearby and MERMAID event files assuming JDS system
% defaults.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 05-Mar-2020, Version 2017b on GLNXA64

clc

% Fetch all new traces.
[~, failed] = fetchnearbytracesall;
if ~isempty(failed)
    error('fetchnearbytracesall failed')

end

% Ensure SAC pole-zero files are up to date by downloading the latest.
fetchnearbypz

% Remove all traces' instrument response; transfer to 'none'
% (displacment), 'vel' and 'acc'.
[~, ~, failed] = rmnearbyrespall;
if ~isempty(failed.none) || ~isempty(failed.vel) || ~isempty(failed.acc)
    error('rmnearbyrespall failed')

end

% Write all .evt files associated with those traces.
[~, ~, failed] = nearbysac2evtall;
if ~isempty(failed)
    error('nearbysac2evtall failed')

end

% Update all .evt files globally to ensure each .evt associated with
% an individual ID has the same event metadata.
[~, ~, ~, failed] = updateidall;
if ~isempty(failed)
    error('fetchnearbytracesall failed')

end

fprintf('\nworkflow completed without error\n')
