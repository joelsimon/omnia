function [isupdated, new_EQ, old_EQ] = updatestloc(sacfile, evtdir)
% [isupdated, new_EQ, old_EQ] = UPDATESTLOC(sacfile, evtdir)
%
% Overwrite reviewed EQ.TaupTimes.
%
% Wrapper for `updatetauptimes.m` that takes evt/ directory rather than the
% associated .evt file as second input.
%
% Input:
% sacfile     Fullpath SAC filename
% evtdir      Path to events/ raw and reviewed sub-directories
%                 (def: $MERMAID/events)
%
% Output:
% isupdated   Logical true/false alerting if EQ.TaupTimes updated
% new_EQ      Current EQ structure, potentially updated
% old_EQ      Previous EQ structure, potentially equal to `new_EQ`
%
% See also: updatetauptimes.m, updateid.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 20-Sep-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default path to raw and reviewed .evt files.
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))

% Collect ONLY the reviewed EQ structure(s) path.
[~, evtfile] = getrevevt(sacfile, evtdir);

% Update EQ.TaupTimes.
[isupdated, new_EQ, old_EQ] = updatetauptimes(sacfile, evtfile);
