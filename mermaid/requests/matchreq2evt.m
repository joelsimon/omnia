function [EQ, evtfile] = matchreq2evt(sacfile, eventid, model, phases, eventdir)
% [EQ, evtfile] = MATCHREQ2EVT(sacfile, eventid, eventdir, phases)
%
% Writes .evt of identified earthquake associated with requested .sac file.
% (really, this will work for any SAC, not just requested SAC...)
%
% Input:
% sacfile    .sac filename (or cell array of filenames)
% eventid    IRIS event ID to associated with SAC filename,
%                or [] to mark as "unidentified"
% eventdir   Path to directory containing 'raw/' and 'reviewed'
%                subdirectories (def: $MERMAID/events/)
% model      Model in which to compute phase arrival times (def: 'ak135')
% phases     Phases to compute arrival times for in EQ.TaupTimes struct
%                (def: [defphases  ',4kmps,1.5kmps'])*
% Output:
% EQ         EQ structure from sac2evt.m
% evtfile    .evt filename saved by this function
%
% * Approx. velocity of first-arriving surface waves (4kmps Rayleigh, 1.5kmps Scholte [and T wave])
%   Scholte ~ 0.1--0.3 Hz (low frequency)
%   T-wave ~ 5 Hz+ (high frequency)
%   See especially Fig. 3 of Hable et al., 2019 [doi: 10.1093/gji/ggz333]
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 06-Dec-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

%% Recursive

% Default directory path.
defval('eventdir', fullfile(getenv('MERMAID'), 'events'));
defval('model', 'ak135')
defval('phases', [defphases  ',4kmps,1.5kmps'])

if iscell(sacfile)

    %% Recursion.

    for i = 1:length(sacfile)
        [EQ(i), evtfile{i}] = matchreq2evt(sacfile{i}, eventid, model, phases, eventdir);

    end
    return

end

if ~isempty(eventid)
    % Fetch most up-to-date info from IRIS.
    EQ = sac2evt(sacfile, model, phases, [], 'eventid', num2str(eventid));
    status = 'identified';
else
    EQ = [];
    status = 'unidentified';

end

% Save EQ struct in .evt file.
evtfile = strrep(strippath(sacfile), '.sac', '.evt');
evtfile = fullfile(eventdir, 'reviewed', status, 'evt', evtfile);
save(evtfile, 'EQ', '-mat')

fprintf('Wrote %s\n', evtfile)
