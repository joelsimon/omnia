function [dup, dup_idx, uni, uni_idx] = strdup(s)
% [dup, dup_idx, uni, uni_idx] = STRDUP(s)
%
% Find duplicate entries in a cell array of strings.
%
% Input:
% s       Cell array of strings
%
% Output:
% dup       Duplicate strings in s
% dup_idx   Index of duplicate strings in s
% uni       Unique strings in s
% uni_idx   Index of unique strings in s
%
% Ex: ('hi' at s([1,4,6]); 'hello' at s([3,8]): 'hey' at s([7,10,11,12]))
%    s = {'hi' 'j' 'hello' 'hi' 'k', 'hi' 'hey' 'hello' 'l' 'hey' 'hey' 'hey'}
%    [dup, dup_idx] = STRDUP(s);
%    dup{:}
%    dup_idx{:}
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 30-Nov-2019, Version 2017b on GLNXA64

dup = {};
dup_idx = {};

[uni, ~, uni_idx] = unique(s, 'stable');
count = hist(uni_idx, unique(uni_idx));
duplicates = find(count > 1);
if ~isempty(duplicates)
    for i = 1:length(duplicates)
        dup{i} = uni(duplicates(i));
        dup_idx{i} = find(uni_idx == duplicates(i));

    end
end
