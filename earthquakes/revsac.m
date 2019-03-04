function [sac, evt] = revsac(iup, diro)
% [sac, evt] = REVSAC(iup, diro)
%
% REVSAC returns a list of *.evt (with full path) and *.sac (without
% full path) filenames associated with SAC files whose event
% information has been reviewed and sorted with reviewevt.m into
% either:
%
% [diro]/reviewed/identified/evt,
% [diro]/reviewed/unidentified/evt, or
% [diro]/reviewed/purgatory/evt.
%
% Inputs:
% iup       [diro]/reviewed/ directory (def: 1)
%           1 identified
%          -1 unidentified
%           0 purgatory
% diro      Path to directory containing 'reviewed' subdirectory
%               def: fullfile(getenv('MERMAID'), 'events'))
%
% Output:
% sac       Cell array of SAC file names whose corresponding 
%              .evt file is in the reviewed subdirectory of interest
%           
% Before running the example below run the example in reviewevt.m
%
% Ex: (load EQ data from an identified SAC file)
%    diro = '~/sac2evt_example';
%    [sac, evt] = REVSAC(1, diro);
%    load(evt{1}, '-mat')
%    EQ
%
% See also: getevt.m, reviewevt.m, fullsac.m
%
% Last modified in Ver. 2017b by jdsimon@princeton.edu, 24-Oct-2018.

defval('iup', 1)
defval('diro', fullfile(getenv('MERMAID'), 'events'))
sac = [];
evt = [];

switch iup
  case 1
    status = 'identified';
    
  case -1
    status = 'unidentified';
    
  case 0
    status = 'purgatory';

  otherwise
    error('Specify 1, -1, or 0 for first input.')

end

% Note: an empty directory (maybe purgatory has been cleared by
% reviewevt.m) will throw an error here.
evt_path = fullfile(diro, 'reviewed', status, 'evt');
diro = dir([evt_path '/*.evt']);
if isempty(diro)
    warning('No .evt files found in %s', evt_path)

end

for i = 1:length(diro)
    evt{i} = fullfile(diro(i).folder, diro(i).name);

end
sac = strrep({diro.name}, '.evt', '.sac');

