function [sac, evt] = revsac(iup, sacdir, revdir)
% [sac, evt] = REVSAC(iup, sacdir, revdir)
%
% REVSAC returns a list of fullpath .sac and .evt filenames associated
% whose event information has been reviewed and sorted with
% reviewevt.m into either:
%
% [revdir]/reviewed/identified/evt,
% [revdir]/reviewed/unidentified/evt, or
% [revdir]/reviewed/purgatory/evt.
%
% Input:
% iup       [revdir]/reviewed/ directory (def: 1)
%           1 identified
%          -1 unidentified
%           0 purgatory
% sacdir    Directory where .sac files are kept
%                def($MERMAID/processed)
% revdir    Directory where .evt files are kept
%                def($MERMAID/events)
%
% Output:
% sac       Cell array of SAC filenames whose corresponding 
%              .evt file is in the reviewed subdirectory of interest
% evt        Cell array of .evt filenames whose corresponding 
%              in the reviewed subdirectory of interest
%           
% Before running the example below run the example in reviewevt.m
%
% Ex: (load EQ data from an identified SAC file)
%    sacdir = fullfile(getenv('OMNIA'), 'exfiles')
%    revdir = '~/cpsac2evt_example';
%    [sac, evt] = REVSAC(1, sacdir, revdir);
%    load(evt{1}, '-mat')
%    EQ
%
% See also: getevt.m, reviewevt.m, fullsac.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 24-Oct-2018, Version 2017b

% Defaults.
defval('iup', 1)
defval('sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('revdir', fullfile(getenv('MERMAID'), 'events'))

sac = [];
evt = [];

% Switch the reviewed directory of interest.
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

% Find the relevant paths. 
evt_path = fullfile(revdir, 'reviewed', status, 'evt');
revdir = dir([evt_path '/*.evt']);
if isempty(revdir)
    warning('No .evt files found in %s', evt_path)

end

for i = 1:length(revdir)
    evt{i} = fullfile(revdir(i).folder, revdir(i).name);

end

% Replace the filename extension.
sac = strrep({revdir.name}, '.evt', '.sac');

% To find the fullpath SAC filenames: start with all SAC fullpath
% filenames.
allsac = fullsac([], sacdir);
if isempty(allsac)
    sac = []; % No warning necessary here as it will be thrown in fullsac.m
    return

end

% Find the intersection between all SAC filenames and those in the
% specified review class.
allsac_nopath = cellfun(@(xx) strippath(xx), allsac, 'UniformOutput', false);
[~, ~, idx] = intersect(sac, allsac_nopath);
sac = allsac(idx);


