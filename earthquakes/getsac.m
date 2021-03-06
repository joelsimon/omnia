function sac = getsac(id, evtdir, sacdir, returntype)
% sac = GETSAC(id, evtdir, sacdir, returntype)
%
% GETSAC returns the SAC file(s) that match the input event ID in
% [evtdir]/reviewed/identified/txt/identified.txt, written with
% evt2txt.m
%
% Only returns the first (primary) event specified with reviewevt.m
%
% Input:
% id           Event identification number in last
%                  column of identified.txt(def: '10948555')
% evtdir       Path to directory containing 'raw/' and 'reviewed'
%                  subdirectories (def: $MERMAID/events/)
% sacdir       Path to directory to be (recursively) searched for
%                 SAC files (def: $MERMAID/processed/)
% returntype   For third-generation+ MERMAID only:
%              'ALL': both triggered and user-requested SAC files (def)
%              'DET': triggered SAC files as determined by onboard algorithm
%              'REQ': user-requested SAC files
%
% Output:
% sac          Cell array of SAC files
%                  ({} if none exist for that returntype)
%
% See also: evt2txt.m, getsacevt.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 05-Mar-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults.
defval('id', '10948555')
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('returntype', 'ALL')

% Assumes Princeton-owned, third-generation MERMAID float SAC file
% naming convention (NOT older, GeoAzur SAC files).  Assuming
% identified.txt is formatted such that:
% (1) SAC filename is first column,
% (2) event ID is last column,
% (3) every line is formatted identically,
% (4) the column separator is a space,
% this method of arbitrary reading should be robust.
% See evt2text.m for details of 'textfile' write.
textfile = fullfile(evtdir, 'reviewed', 'identified', 'txt', 'identified.txt');
textlines = readtext(textfile);
columnsep = strfind(textlines{1}, ' ');

% Don't add +1 to columnsep(end) here because that +1 might include an
% asterisk "*", indicating possible multiple events in other textlines
% which are not the first.
event_id_column_idx = [columnsep(end):length(textlines{1})];

% Find the lines in identified.txt which include that event
% identification number.
id = strtrim(num2str(id));

% Separate event ID column.
all_event_ids = cellfun(@(xx) xx(event_id_column_idx), textlines, ...
                        'UniformOutput', false);
all_event_ids = strtrim(all_event_ids);

% Remove prefixed asterisks (signaling possible multiple events)
star_idx = cellstrfind(all_event_ids, '*');
for i = 1:length(star_idx)
    all_event_ids{star_idx(i)}(1) = [];

end

% Query that column for the input event id.
this_event_idx = find(strcmp(all_event_ids, id));
if isempty(this_event_idx)
    error('Event ID: %s not found in %s', id, textfile)

end

% Pull the SAC files (first column) using the index of matched lines in the large text file.
for i = 1:length(this_event_idx)
    sac{i} = fx(strsplit(strtrim(textlines{this_event_idx(i)})), 1);

end

% Separate 'DET' (triggered) and 'REQ' (requested) data for MERMAID.
switch upper(returntype)
  case 'DET'
    idx = cellstrfind(sac, 'MER.DET.*.sac');
    if isempty(idx)
        warning('No triggered (''DET'') SAC files found for ID: %s', id)
        sac = {};
        return

    end

  case 'REQ'
    idx = cellstrfind(sac, 'MER.REQ.*.sac');
    if isempty(idx)
        warning('No requested (''REQ'') SAC files found for ID: %s', id)
        sac = {};
        return

    end

  case 'ALL'
    idx = [1:length(sac)];

  otherwise
    error('Specify one of ''ALL'', ''DET'', or ''REQ'' for input: returntype')

end
sac = sac(idx);

% And retrieve the full path to each SAC file.
for i = 1:length(sac)
    sac{i} = fullsac(sac{i}, sacdir);

end

% Warn user if any of the SAC files possibly contain energy from
% multiple earthquakes, designated by an asterisk.
[~, multi_idx] = intersect(this_event_idx, star_idx);
if ~isempty(multi_idx)
    for i = 1:length(multi_idx)
        warning('\n%s may contain signals from multiple earthquakes\n', sac{multi_idx(i)})

    end
end
