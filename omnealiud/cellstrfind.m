function [idx, sellout] = cellstrfind(sell, pattern)
% [idx, sellout] = CELLSTRFIND(sell, pattern)
%
% Return indices and strings in cell array which contain the regexp pattern.
%
% Input:
% sell       Cell array of strings
% pattern    Regular expression (e.g., '-P-\d\d\/')
%                (accepts cell arrays)
% Output:
% idx        The index of matches (def: [])
% sellout    Cell of matching strings,
%                literally sell(idx) (def: {})
%
% Ex1:
%    sell = {'dog' 'froggy' 'hop' 'on' 'a' 'soggy' 'log' 'in' 'a' 'bog'}
%    [idx, sellout] = CELLSTRFIND(sell, 'og')
%    [idx, sellout] = CELLSTRFIND(sell, '[^0-9]og.y')
%    [idx, sellout] = CELLSTRFIND(sell, {'dog', 'bog', 'froggy'})
%
% Ex2: (?i) turns on case-insensitivity; (?-i) turns off case-insensitivity
%    sell = {'UPPERCASE', 'lowercase', 'MiXeDcAsE', 'mIxEdCaSe'}
%    [idx, sellout] = CELLSTRFIND(sell, 'case')
%    [idx, sellout] = CELLSTRFIND(sell, '(?i)case')
%    [idx, sellout] = CELLSTRFIND(sell, '(?i)ca(?-i)se')
%    [idx, sellout] = CELLSTRFIND(sell, '(?i)cas(?-i)e')
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 15-Apr-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

%% RECURSIVE.

if iscell(pattern)

    %% RECURSION.

    idx = [];
    sellout = {};
    for i = 1:length(pattern)
        [A, B] = cellstrfind(sell, pattern{i});
        idx = [idx ; A];
        sellout = [sellout ; B];

    end
    return

end

% Main.
matches = regexp(sell, pattern);
idx = find(~cellfun(@isempty, matches));
sellout = sell(idx);
