function matchreq2evt(sacfile, eventid, evtdir)
% MATCHREQ2EVT(SACFILE, EVENTID, EVTDIR)
%
% Writes .evt of identified earthquake associated with requested .sac file.
% (really, this will work for any SAC, not just requested SAC...)
%
% Input:
% sacfile    SAC filename
% eventid    IRIS event ID to associated with SAC filename
% evtdir     Path to directory containing 'raw/' and 'reviewed'
%                 subdirectories (def: $MERMAID/events/)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 22-Nov-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default directory path.
defval('evtdir', fullfile(getenv('MERMAID'), 'events'));

% Use ak135 model and compute arrival times for all default phases plus the
% fastest surface waves (4 kmps Rayleigh, 1.5 kmps Scholte and T wave).
% T-wave  ~ 5 Hz+ (high freq)
% Scholte ~ 0.1 - 0.3 Hz (low freq)
% [search for Scholte, T-wave at same arrival time but differing frequency bands]
phases = [defphases  ',4kmps,1.5kmps'];

% Fetch most up-to-date info from IRIS.
EQ = sac2evt(sacfile, [], phases, [], 'eventid', eventid);

% Save EQ struct in .evt file.
evtfile = strrep(strippath(sacfile), '.sac', '.evt');
evtfile = fullfile(evtdir, 'reviewed', 'identified', 'evt', evtfile);
save(evtfile, 'EQ', '-mat')

fprintf('Wrote %s\n', evtfile)
