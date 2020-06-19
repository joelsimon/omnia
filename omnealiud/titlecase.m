function str = titlecase(str, exceptions)
% str = TITLECASE(str, exceptions)
%
% Capitalizes the first letter of every (hyphenated) word in a character array,
% unless that word is in the list of exceptions.
%
% Input:
% str              A character array
% exceptions       A cell array (or []) of words not to be capitalized (def: [])
%
% Output:
% str              The input character array in title case
%
% Ex:
%    str = ['recording earthquakes in the oceans for global seismic tomography ' ...
%           'by freely-drifting robots'];
%    TITLECASE(str)
%    TITLECASE(str, {'in' 'the' 'for' 'by'})
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 19-Jun-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default and error checking.
defval('exceptions', [])
assert(ischar(str), '''str'' must be char')

% Basic title case with no exceptions.
words = cellfun(@(xx) [upper(xx(1)) lower(xx(2:end))], strsplit(str), ...
                'UniformOutput', false);

% Identify any exceptions and make those words lowercase.
if ~isempty(exceptions)
    assert(iscell(exceptions), '''exceptions'' must be cell of char')

    % Interval upper.m for IgnoreCase
    idx = find(ismember(upper(words), upper(exceptions)));
    for i = 1:length(idx)
        words{idx(i)} = lower(words{idx(i)});

    end
end

% Capitalize first letter after hyphens.
str = strjoin(words);
hyphens = strfind(str, '-');
for i = 1:length(hyphens)
    if i <= length(str)
        str(hyphens(i)+1) = upper(str(hyphens(i)+1));

    end
end

% Ensure first letter capitalized (it may be in the list of exceptions).
str(1) = upper(str(1));
