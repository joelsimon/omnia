function updated = updatestloc(sac, evtdir)
% updated = UPDATESTLOC(sac, evtdir)
%
% Overwrite reviewed EQ.TaupTimes due to changes in SAC file.
%
% UPDATESTLOC updates the phase-arrival times due to a change in STATION
% metadata, not event metadata.
%
% UPDATESTLOC DOES NOT update the phase-arrival times of the corresponding raw
% events, nor does it update the corresponding raw or reviewed .CP files.
%
% Input:
% sac         Fullpath SAC filename
% evtdir      Path to events/ raw and reviewed sub-directories
%                 (def: $MERMAID/events)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 16-Nov-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default path to raw and reviewed .evt files.
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))

% Collect ONLY the reviewed EQ structure(s).
[EQ, ~, ~, ~, evtfile] = getevt(sac, evtdir);

% Read (possibly updated) SAC-file header.
[~, h] = readsac(sac);

% Overwrite .TaupTimes if that sub-structure requires an update.
[EQ, updated] = update_TaupTimes(EQ, h);

if updated
    save(evtfile, 'EQ', '-mat')
    warning('Updated %s', evtfile)

end

%%______________________________________________________________________________________%%
% Update the earthquake structures

function [new_EQ, updated] = update_TaupTimes (old_EQ, h)

% Copy old EQ so that it may be compared with (possibly) updated EQ
new_EQ = old_EQ;

updated = false;
for i = 1:length(new_EQ)
    % Parse old event parameters that are unchanged (this function updates
    % the phase-arrival times due to a change in STATION location, not EVENT location)
    evdate = irisstr2date(old_EQ(i).PreferredTime, 1);
    mod = old_EQ(i).TaupTimes(1).model; % same model for all phases
    evla = old_EQ(i).PreferredLatitude;
    evlo = old_EQ(i).PreferredLongitude;
    evdp = old_EQ(i).PreferredDepth;
    ph = old_EQ(i).PhasesConsidered;
    pt0 = h.B; % time in seconds assigned to first sample

    % Attach (possibly updated .TaupTime sub-structure to new EQ) and recompute
    % theoretical reid.m pressures associated with each phase.
    new_EQ(i).TaupTimes =  arrivaltime(h, evdate, [evla evlo], mod, evdp, ph, pt0);
    new_EQ(i) = reidpressure(new_EQ(i));

    if ~isequaln(new_EQ(i), old_EQ(i))
        updated = true;

        % Log automaid version that wrote this SAC file.
        automaid_version = h.KUSER0;

        % Generate note-to-self to be attached to EQ, if updated.
        note = sprintf('%s: Overwrote .TaupTimes using SAC written with automaid %s', ...
                       irisdate2str(datetime('now', 'TimeZone', 'UTC')), automaid_version);

        % Append or add a new note-to-self field,
        if isfield(new_EQ(i), 'Notes')
            new_EQ(i).Notes = [new_EQ(i).Notes {note}];

        else
            new_EQ(i).Notes = {note};

        end
    end
end
