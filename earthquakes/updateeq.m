function updated_old_EQ = updateeq(updated_EQ, old_EQ, sac, model, ph)
% updated_old_EQ = UPDATEEQ(updated_EQ, old_EQ, sac, model, ph)
%
% UPDATEEQ takes an updated EQ structure as input and applies those
% new metadata details to the old EQ structure, recomputing .TaupTimes
% phase arrivals on the way.
%
% Input old_EQ can be N times long, but updated_EQ must be a single EQ
% structure.  UPDATEEQ finds the proper event ID in old_EQ that
% matches the singular event ID in updated_EQ.
%
% Input:
% updated_EQ   EQ structure with (possibly) updated details
% old_EQ       Current EQ structure to be overwritten with updated details
% sac          Full path SAC filename associated with old_EQ
% model        Taup model (def: old_EQ.TaupTimes.model)
% ph           Taup phases (def: old_EQ.PhasesConsidered)
%
% Output:
% updated_old_EQ  Old EQ with event details updated and new TaupTimes
%                     (N.B. .Params field is set to NaN
%                      as it no longer applies post-update)
%
% See also: updateid.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 28-Nov-2019, Version 2017b on GLNXA64

% Defaults: will parse old_EQ (below) if necessary.
defval('model', [])
defval('ph', [])

if isempty(updated_EQ) || isempty(old_EQ)
    % There is nothing to update; event never matched with phase arrivals.
    updated_old_EQ = [];
    return

end

% Sanity.
if length(updated_EQ) > 1
    error('updated_EQ can only be of length 1')

end

% Find the matching event ID.
updated_ID = fx(strsplit(updated_EQ.PublicId, '='),  2);

% Find the matching event ID index in the old_EQ (which may of of length > 1).
for i = 1:length(old_EQ)
    old_ID{i} = fx(strsplit(old_EQ(i).PublicId, '='),  2);

end
ID_idx = find(strcmp(old_ID, updated_ID));

% Read the SAC header.
[~, h] = readsac(sac);

% Parse the taupTime parameters from the old EQ if they are not
% supplied as input.
if isempty(model)
    model = old_EQ(ID_idx).TaupTimes(1).model;

end
if isempty(ph)
    ph = old_EQ(ID_idx).PhasesConsidered;

end

% Pull event metadata from updated EQ.
evtdate = irisstr2date(updated_EQ.PreferredTime);
evla = updated_EQ.PreferredLatitude;
evlo = updated_EQ.PreferredLongitude;
evdp = updated_EQ.PreferredDepth;

% Compute arrival times with updated event metadata.
tt = arrivaltime(h, evtdate, [evla evlo], model, evdp, ph, h.B);
if isempty(tt)
    updated_old_EQ = [];
    return

end

% Overwrite the old EQ with the new event metadata and arrival times.
updated_old_EQ = old_EQ;
updated_old_EQ(ID_idx) = updated_EQ;
updated_old_EQ(ID_idx).Filename = strippath(old_EQ(ID_idx).Filename);
updated_old_EQ(ID_idx).Params = NaN;
updated_old_EQ(ID_idx).PhasesConsidered = ph;
updated_old_EQ(ID_idx).Picks = [];
updated_old_EQ(ID_idx).TaupTimes = tt;

% Compute the theoretical pressure of every updated phase arrival.
updated_old_EQ(ID_idx) = reidpressure(updated_old_EQ(ID_idx));
orderfields(updated_old_EQ);
