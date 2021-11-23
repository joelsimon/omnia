function [sac, EQ] = getsacevt(id, evtdir, sacdir, check4update, returntype, incl_prelim)
% [sac, EQ] = GETSACEVT(id, evtdir, sacdir, check4update, returntype, incl_prelim)
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
%                   (def: true)
% returntype    For third-generation+ MERMAID only:
%               'ALL': both triggered and user-requested SAC & .evt files (def)
%               'DET': triggered SAC & .evt files as determined by onboard algorithm
%               'REQ': user-requested SAC & .evt files
% incl_prelim    true to include 'prelim.sac' (def: true)
%
% Output:
% sac           Cell array of SAC files
%                 ({} if none exist for that returntype)
% EQ            Reviewed EQ structures for each SAC file
%                 ({} if none exist for that returntype)
%
% See also: getnearbysacevt.m, getsac.m, getevt.m (getrevevt.m)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 23-Nov-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults.
defval('id', '10948555')
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('check4update', true)
defval('returntype', 'ALL')
defval('incl_prelim', true)

% Tired fingers make mistakes.
if ~islogical(check4update)
    error('Input `check4update` must be logical')

end
if ~islogical(incl_prelim)
    error('Input `incl_prelim` must be logical')

end

% This function is just simple wrapper.
id = num2str(id);
sac = getsac(id, evtdir, sacdir, returntype, incl_prelim);
if isempty(sac)
    EQ = {};
    return

end

for i = 1:length(sac)
    % Must be cell in case multiple EQs corresponding to one SAC file.
    EQ{i}  = getrevevt(sac{i}, evtdir);

end
EQ = EQ(:);

% Test if we need to update the files associated with this event ID.
if check4update && need2updateid(EQ, id)
    warning(['Event metadata differs between EQ structures.\nTo ' ...
             'update run updateid(''%s'')'], id)

end
