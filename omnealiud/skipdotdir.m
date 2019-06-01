function d = skipdotdir(d)
% d = SKIPDOTDIR(d)
%
% Skip Dot ('.') Directory Files.
%
% Removes dot '.*' files from a directory structure.
%
% Input:
% d      Directory struct output from dir.m
%
% Output:
% d      Directory struct output from dir.m with
%            dot files removed
%
% Ex:
%    d1 = dir('~')
%    d2 = SKIPDOTDIR(d1)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 28-Jan-2018, Version 2017b

% Sanity.
if isa(d, 'struct') == false
    error('Input argument ''d'' must be a directory structure.')

end

% Return only those d.names which don't start with '.'.
d = d(find(~strncmp('.', {d(:).name}, 1)));
