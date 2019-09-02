function [sac, EQ] = getsacevt(id, evtdir)
% [sac, EQ] = GETSACEVT(id, evtdir)
%
% GETSACEVT combines getsac.m and getevet.m to return the list of SAC
% files and reviewed EQ structures corresponding to an event ID.
%
% Input:
% id        Event identification number in last 
%               column of identified.txt(def: 10948555)
% evtdir    Path to directory containing 'raw/' and 'reviewed' 
%               subdirectories (def: $MERMAID/events/)
%
% Output:
% sac       Cell array of SAC files
% EQ        Reviewed EQ structures for each SAC file
%
% See also: getsac.m, getevt.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 27-Aug-2019, Version 2017b

% Defaults.
defval('id', 10948555)
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))

% This function is just simple wrapper.
sac = getsac(id, evtdir);
for i = 1:length(sac)
    % Must be cell in case multiple EQ's corresponding to one SAC file.
    EQ{i}  = getevt(sac{i}, evtdir);

end