function sac = getsac(id, evtdir)
% sac = GETSAC(id, evtdir)
%
% GETSAC returns the SAC file(s) that match the input event ID in
% [evtdir]/reviewed/identified/txt/identified.txt, written with
% evt2txt.m
%
% Only returns the first (primary) event specified with reviewevt.m
%
% Input:
% id        Event identification number in last 
%               column of identified.txt(def: 10948555)
% evtdir    Path to directory containing 'raw/' and 'reviewed' 
%               subdirectories (def: $MERMAID/events/)
%
% Output:
% sac       Cell array of SAC files
%
% See also: evt2txt.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 26-Aug-2019, Version 2017b

% Defaults.
defval('id', 10948555)
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))

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
id = num2str(id);

% Separate event ID column.
all_event_ids = cellfun(@(xx) xx(event_id_column_idx), textlines, ...
                        'UniformOutput', false);

% Query that column for the input event id.
[this_event_idx, this_event_id] = cellstrfind(all_event_ids, id);

% Handle appropriate errors or warnings.
if isempty(this_event_idx)
    error(sprintf('\nNo matching event id: %s', id))

end

% Pull the SAC files (first column) using the index of matched lines in the large text file.
sac = cellfun(@(xx) strtrim(xx(1:columnsep(1))), textlines(this_event_idx), ...
              'UniformOutput', false);

% Warn user if any of the SAC files possibly contain energy from
% multiple earthquakes, designated by an asterisk.
for i = 1:length(this_event_id)
    if contains(this_event_id(i), '*')
        warning('\n%s may contain signals from multiple earthquakes\n', sac{i})

    end    
end
