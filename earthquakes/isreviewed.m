function tf = isreviewed(sacfile, evtdir)
% ISREVIEWED(sacfile, evtdir)
%
% Returns true if the input .sac has an associated reviewed .evt file.
%
% Input:
% sacfile    SAC filename
% evtdir     Path to directory containing 'raw/' and 'reviewed'
%                 subdirectories (def: $MERMAID/events/)
% Output:
%            logical true or false
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 11-Apr-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('evtdir', fullfile(getenv('MERMAID'), 'events'))

evtfile = strrep(strippath(lower(sacfile)), '.sac', '.evt');
D = dir(fullfile(evtdir, 'reviewed', sprintf('**/*%s', evtfile)));
if isempty(D)
   tf = false;

else
    tf = true;

end
