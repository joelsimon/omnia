function d = skipdotdir(d)
% d = SKIPDOTDIR(d)
%
% SKIPDOTDIR removes dot '.*' directories and filenames from a
% directory structure.
%
% Input:
% d      Directory struct output from dir.m
%
% Output:
% d      Directory struct output from dir.m with
%            dot folders and names removed
%
% Ex:
%    d1 = dir('~')
%    d2 = SKIPDOTDIR(d1)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 28-Jan-2018, Version 2017b

% Sanity.
if ~isa(d, 'struct')
    error('Input argument ''d'' must be a directory structure.')

end

% Return only those d.names which don't start with '.'.
d = d(find(~strncmp('.', {d(:).name}, 1)));
