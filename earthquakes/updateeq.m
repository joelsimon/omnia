function updated_old_EQ = updateeq(updated_EQ, old_EQ, sac)
% updated_old_EQ = UPDATEEQ(updated_EQ, old_EQ, sac)
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
%
% Output:
% updated_old_EQ  Old EQ with event details updated and new TaupTimes
%
% See also: updateid.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 10-Sep-2019, Version 2017b on GLNXA64

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

% Compute theoretical phase arrival times.
if ~isempty(old_EQ(ID_idx).TaupTimes)
    % Parse the taupTime parameters from the old EQ.
    model = old_EQ(ID_idx).TaupTimes(1).model; 
    ph = old_EQ(ID_idx).PhasesConsidered;

    % Pull event metadata from updated EQ.
    evtdate = irisstr2date(updated_EQ.PreferredTime);
    evla = updated_EQ.PreferredLatitude;
    evlo = updated_EQ.PreferredLongitude;
    evdp = updated_EQ.PreferredDepth;

    % Compute arrival times with updated event metadata.
    tt = arrivaltime(h, evtdate, [evla evlo], model, evdp, ph, h.B);

else
    tt = [];

end

% Overwrite the old EQ with the new event metadata and arrival times.
updated_old_EQ = old_EQ;
updated_old_EQ(ID_idx) = updated_EQ;
updated_old_EQ(ID_idx).Filename = strippath(old_EQ(ID_idx).Filename);
updated_old_EQ(ID_idx).Picks = [];
updated_old_EQ(ID_idx).TaupTimes = tt;

% Compute the theoretical pressure of every updated phase arrival.
updated_old_EQ(ID_idx) = reidpressure(updated_old_EQ(ID_idx));
orderfields(updated_old_EQ);
