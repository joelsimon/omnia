function [sac, evt, xtra_evt] = revsac(iup, sacdir, evtdir, returntype)
% [sac, evt, xtra_evt] = REVSAC(iup, sacdir, evtdir, returntype)
%
% REVSAC returns a list of fullpath .sac and .evt filenames
% whose event information has been reviewed and sorted with
% reviewevt.m into either:
%
% [evtdir]/reviewed/identified/evt,
% [evtdir]/reviewed/unidentified/evt, or
% [evtdir]/reviewed/purgatory/evt.
%
% Input:
% iup          [evtdir]/reviewed/ directory (def: 1)
%              1: identified
%             -1: unidentified
%              0: purgatory
% sacdir       Directory where .sac files are kept
%                  def($MERMAID/processed)
% evtdir       Path to directory containing 'raw/' and 'reviewed'
%                  subdirectories (def: $MERMAID/events/)
% returntype   For third-generation+ MERMAID only:
%              'ALL': both triggered and user-requested SAC files (def)
%              'DET': triggered SAC files as determined by onboard algorithm
%              'REQ': user-requested SAC files
% Output:
% sac          Cell array of SAC filenames whose corresponding
%                  .evt file is in the reviewed subdirectory of interest
% evt          Cell array of .evt filenames whose corresponding
%                  in the reviewed subdirectory of interest
% xtra_evt     Cell array of .evt filenames in the corresponding reviewed
%                  subdirectory with no complementary SAC file in sacdir
%
% Before running the example below run the example in reviewevt.m
%
% Ex: (load EQ data from an identified SAC file)
%    sacdir = fullfile(getenv('OMNIA'), 'exfiles')
%    evtdir = '~/cpsac2evt_example';
%    [sac, evt] = REVSAC(1, sacdir, evtdir);
%    load(evt{1}, '-mat')
%    EQ
%
% See also: getevt.m, reviewevt.m, fullsac.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu | joeldsimon@gmail.com
% Last modified: 30-Aug-2023, Version 9.3.0.713579 (R2017b) on GLNXA64

% Defaults.
defval('iup', 1)
defval('sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('returntype', 'ALL')

sacdir = strtrim(sacdir);
evtdir = strtrim(evtdir);

sac = [];
evt = [];
xtra_evt = [];

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
evt_path = fullfile(evtdir, 'reviewed', status, 'evt');
evtdir = dir([evt_path '/*.evt']);
if isempty(evtdir)
    warning('No .evt files found in %s', evt_path)
    return

end

% Compile list of all .evt files in evtdir.
for i = 1:length(evtdir)
    allevt{i} = fullfile(evtdir(i).folder, evtdir(i).name);

end

% Keep just those events in of the requested return type.
switch upper(returntype)
  case 'DET'
    idx = cellstrfind(allevt, 'MER.DET.*.evt');
    if isempty(idx)
        warning('No triggered (''DET'') .evt files found')
        return

    end

  case 'REQ'
    idx = cellstrfind(allevt, 'MER.REQ.*.evt');
    if isempty(idx)
        warning('No requested (''REQ'') .evt files found')
        return

    end

  case 'ALL'
    idx = [1:length(allevt)];

  otherwise
    error('Specify one of ''ALL'', ''DET'', or ''REQ'' for input: returntype')

end
allevt = allevt(idx);

% Compile list of all .sac files in sacdir.
allsac = fullsac([], sacdir, returntype);
if isempty(allsac)
    % No warning necessary here as it will be thrown in fullsac.m
    return

end

% Find the intersection between all SAC filenames and those in the specified review class.
allevt_nopath = cellfun(@(xx) strippath(xx), strrep(allevt(:), '.evt', ''), 'UniformOutput', false);
allsac_nopath = cellfun(@(xx) strippath(xx), strrep(allsac(:), '.sac', ''), 'UniformOutput', false);

[~, evt_idx, sac_idx] = intersect(allevt_nopath, allsac_nopath);
evt = allevt(evt_idx);
sac = allsac(sac_idx);

[~, xtra_evt_idx] = setdiff(allevt_nopath, allsac_nopath);
xtra_evt = allevt(xtra_evt_idx);

sac = sac(:);
evt = evt(:);
xtra_evt = xtra_evt(:);
