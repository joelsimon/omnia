function isupdated = updatestloc(sac, evtdir)
% isupdated = UPDATESTLOC(sac, evtdir)
%
% Overwrite reviewed EQ.TaupTimes.
%
% UPDATETAUPTIMES updates the phase-arrival times due to a change in station
% or event metadata. 
%
% UPDATETAUPTIMES does not update the station or event metadata themselves
% (see updateid.m to accomplish the latter).
%
% UPDATETAUPTIMES does not update the phase-arrival times of the corresponding
% raw events, nor does it update the corresponding raw or reviewed .CP files.
%
% UPDATESTLOC is a wrapper for updatetauptimes.m
%
% Input:
% sac         Fullpath SAC filename
% evtdir      Path to events/ raw and reviewed sub-directories
%                 (def: $MERMAID/events)
%
% Output:
% isupdated   Logical true/false alerting if EQ.TaupTimes updated
%
% See also: updatetauptimes.m, updateid.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 05-Mar-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default path to raw and reviewed .evt files.
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))

% Collect ONLY the reviewed EQ structure(s) path.
[~, ~, ~, ~, evt] = getevt(sac, evtdir);

% Update EQ.TaupTimes.
isupdated = updatetauptimes(sac, evt);
