function S = rmstructindex(S, index, skipfield)
% S = RMSTRUCTINDEX(S, index, skipfield)
%
% Removes the specified indices of each array contained in a structure, with the
% option to skip fields.
%
% Input:
% S           Structure of arrays
% index       Indices to remove or replace; S.(fieldname)(index) = []
% skipfield   Cell array of fieldnames to NOT apply deletion (def: [])
%
% Output:
% S           Structure of arrays with requested indices of those arrays removed
%
% Ex:
%    S1.f1 = [-1:9];
%    S1.f2 = [0:10];
%    S1.f3 = [1:11]
%    S12 = RMSTRUCTINDEX(S1, [2:10])
%    S2 = S1;
%    S2.header = 'Some header info you don''t want indexed'
%    S22 = RMSTRUCTINDEX(S2, [2:10], {'header'})
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 13-Jul-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default.
defval('skipfield', [])

% Sanity checks.
if ~isstruct(S)
    error('''S'' must be a structure of arrays')

end

if ~all(isint(index))
    error('''index'' must be an array of integers (indices)')

end

if ~isempty(skipfield)
    if ~iscell(skipfield) || ~all(cellfun(@ischar, skipfield))
        error('''skipfield'' must be a cell array of chars')

    end
end

% Get the fieldnames.
names = fieldnames(S);

% Skip the requested fieldnames by removing them from the list.
if ~isempty(skipfield)
    names(find(ismember(names, skipfield))) = [];

end

%% MAIN

% Loop over the fieldnames and remove the requested indices.
for i = 1:length(names)
    S.(names{i})(index) = [];

end
