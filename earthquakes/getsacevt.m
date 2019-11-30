function [sac, EQ] = getsacevt(id, evtdir, sacdir, check4update, returntype)
% [sac, EQ] = GETSACEVT(id, evtdir, sacdir, check4update, returntype)
%
% GETSACEVT combines getsac.m and getevet.m to return the list of SAC
% files and reviewed EQ structures corresponding to an event ID.
%
% Input:
% id            Event identification number in last
%                   column of identified.txt(def: '10948555')
% evtdir        Path to directory containing 'raw/' and 'reviewed/'
%                   subdirectories (def: $MERMAID/events/)
% sacdir        Path to directory to be (recursively) searched for
%                   SAC files (def: $MERMAID/processed/)
% check4update  true to determine if resultant EQs need updating
%                   (def: false)
% returntype    For third-generation+ MERMAID only:
%               'ALL': both triggered and user-requested SAC & .evt files (def)
%               'DET': triggered SAC & .evt files as determined by onboard algorithm
%               'REQ': user-requested SAC & .evt files
%
% Output:
% sac           Cell array of SAC files
% EQ            Reviewed EQ structures for each SAC file
%
% See also: getnearbysacevt.m, getsac.m, getevt.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 27-Aug-2019, Version 2017b

% Defaults.
defval('id', '10948555')
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('check4update', false)
defval('returntype', 'ALL')

% This function is just simple wrapper.
id = num2str(id);
sac = getsac(id, evtdir, sacdir, returntype);
for i = 1:length(sac)
    % Must be cell in case multiple EQ's corresponding to one SAC file.
    EQ{i}  = getevt(sac{i}, evtdir);

end
EQ = EQ(:);

% Test if we need to update the files associated with this event ID.
if check4update && need2updateid(EQ, id)
    warning(['Event metadata differs between EQ structures.\nTo ' ...
             'update run updateid(''%s'')'], id)

end
