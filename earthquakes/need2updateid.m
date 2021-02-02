function TF = need2updateid(EQ, id)
% TF = NEED2UPDATEID(EQ, id)
%
% NEED2UPDATEID inspects every EQ structure associated with a given event ID
% (both for MERMAID data, and nearby station data if it exists) and compares the
% preferred and MbMl* event metadata associated with that event ID.  If metadata
% differs between EQ structures (e.g., an event location was updated)
% NEED2UPDATEID returns true.
%
% *Does not compared EQ.Magnitudes, EQ.Origins etc.; see full list in
% subfunction.
%
% Input:
% EQ         Cell of EQ structures, e.g. from getnearbysacevt.m
% id         The event ID number to cross-reference
%
% Output:
% TF         true: metadata differs across EQ structures
%            false: metadata is identical across EQ structures
%
% See also: updateid.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 02-Feb-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default.
TF = false;

% Sanity.
if ~iscell(EQ)
    error('EQ list must be cell array of structures')

end

% Theory of this function: for every EQ struct associated with a given
% event ID there is a "base" EQ structure whose metadata should not
% differ across all EQs.  Ergo, remove the relevant fields that do
% differ and step through the list of EQs checking if the current EQ
% info is different from the last.

EQ(find(cellfun(@(xx) isempty(xx), EQ))) = [];
if isempty(EQ) || length(EQ) == 1
    % There is nothing to check -- all empty or only a single EQ.
    return

end

% Initialize the a prev_EQ struct against which to check the
% others.
id = strtrim(num2str(id));
prev_EQ = strip_EQ(EQ{1}, id);

% Check the current against the last former; exit if they differ.
for i = 2:length(EQ)
    this_EQ = strip_EQ(EQ{i}, id);

    if ~isequaln(prev_EQ, this_EQ)
        TF = true;
        return

    else
        prev_EQ = this_EQ;

    end
end

% ___________________________________________________________%
function base_EQ = strip_EQ(EQ, id)
ID_idx = [];
for i = 1:length(EQ)
    ID_idx{i} = fx(strsplit(EQ(i).PublicId, '='),  2);

end
ID_idx = find(strcmp(ID_idx, id));

if isempty(ID_idx)
    error('ID %s not found in EQ structure related to SAC file: %s', id, EQ(i).Filename)

end

base_EQ = EQ(ID_idx);
base_EQ = rmfield(base_EQ, 'Filename');
base_EQ = rmfield(base_EQ, 'Magnitudes'); % Cut this struct; only compare PreferredMagnitude
base_EQ = rmfield(base_EQ, 'Origins'); % Cut this struct; only compare PreferredOrigin
base_EQ = rmfield(base_EQ, 'Params');
base_EQ = rmfield(base_EQ, 'Picks');
base_EQ = rmfield(base_EQ, 'PhasesConsidered');
base_EQ = rmfield(base_EQ, 'QueryTime');
base_EQ = rmfield(base_EQ, 'TaupTimes');
