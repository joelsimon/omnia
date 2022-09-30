function [dead, loc] = deadmermaid(fetchesoloc)
% [dead, loc] = DEADMERMAID(fetchesoloc)
%
% Return list of (possibly) dead MERMAIDs that have not surfaced in 30+ days.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 26-Sep-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('fetchesoloc', true)

% Pull all new ESO locations from website.
if fetchesoloc
    system(fullfile('$OMNIA', 'mermaid', 'fetchesoloc'))

end

% Reads all last locations.
loc = readesoloc;
mermaid = fieldnames(loc);
for i = 1:length(mermaid)
    lastloc = loc.(mermaid{i}).date(end);
    if lastloc < datetime('now', 'TimeZone', 'UTC') - days(30)
        dead.(mermaid{i}) = lastloc;

    end
end
