function nearbyworkflow
% Fetches nearby traces, removes their instrument response, writes
% their corresponding event files, and updates all nearby and MERMAID
% event files assuming JDS system defaults.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 02-Jan-2020, Version 2017b on GLNXA64

clc
[~, failed] = fetchnearbytracesall;
if ~isempty(failed)
    error('fetchnearbytracesall failed')

end

[~, ~, failed] = rmnearbyrespall;
if ~isempty(failed.none) || ~isempty(failed.vel) || ~isempty(failed.acc)
    error('rmnearbyrespall failed')

end

[~, ~, failed] = nearbysac2evtall;
if ~isempty(failed)
    error('nearbysac2evtall failed')

end

[~, ~, ~, failed] = updateidall;
if ~isempty(failed)
    error('fetchnearbytracesall failed')

end

fprintf('\nworkflow completed without error\n')
