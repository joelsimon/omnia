function isupdated = updatetauptimes(sacfile, evtfile)
% isupdated = UPDATETAUPTIMES(sacfile, evtfile)
%
% Overwrite reviewed EQ.TaupTimes.
%
% UPDATETAUPTIMES updates the phase-arrival times due to a change in station
% or event metadata.
%
% UPDATETAUPTIMES does not update the station or event metadata themselves
% (see updateid.m to accomplish the latter).
%
% UPDATETAUPTIMES does not update the phase-arrival times of the corresponding
% raw events, nor does it update the corresponding raw or reviewed .CP files.
%
% Input:
% sacfile     Fullpath .SAC filename
% evtfile     Fullpath .evt (EQ structure) filename
%
% Output:
% isupdated   true if evtfile updated with new EQ struct (def: false)
%
% Output:
% isupdated   Logical true/false alerting if EQ.TaupTimes updated
%
% See also: updateid.m, updatestloc.m (a wrapper; uses SAC filename)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 05-Mar-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Read the EQ structure.
tmp = load(evtfile, 'EQ', '-mat');
EQ = tmp.EQ;

% Read the (possibly updated) SAC-file header.
[~, h] = readsac(sacfile);

% Overwrite .TaupTimes if that sub-structure requires an update.
[new_EQ, isupdated] = main(EQ, h);

% Verify this EQ structure corresponds to this SAC file -- may have to chop
% off, e.g., 'vel', from the end of this sac file.
sac_nopath = strippath(sacfile);
sac_idx = strfind(lower(sac_nopath), 'sac');
sac_nopath = sac_nopath(1:sac_idx+2);
if ~strcmpi(sac_nopath, EQ.Filename)
    error('sacfile and evtfile do not correspond to one another')

end

if isupdated
    EQ = new_EQ;
    save(evtfile, 'EQ', '-mat')
    warning('Updated %s', evtfile)

end

%%______________________________________________________________________________________%%
% Update the earthquake structures

function [new_EQ, isupdated] = main(old_EQ, h)

% Copy old EQ so that it may be compared with (possibly) updated EQ
new_EQ = old_EQ;

isupdated = false;
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

    % Flag any updates.
    if ~isequaln(new_EQ(i), old_EQ(i))
        isupdated = true;

    end
end
