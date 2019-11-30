function [idx, sellout] = cellstrfind(sell, pattern)
% [idx, sellout] = CELLSTRFIND(sell, pattern)
%
% Returns the indices and strings in a cell which contain the regexp
% pattern.
%
% Input:
% sell       Cell array of strings
% pattern    Regular expression (e.g., '-P-\d\d\/')
%
% Output:
% idx        The index of matches (def: {})
% sellout    Cell of matching strings,
%                literally sell(idx) (def: {})
%
% Ex1:
%    sell = {'dog' 'froggy' 'hop' 'on' 'a' 'soggy' 'log' 'in' 'a' 'bog'}
%    [idx, sellout] = CELLSTRFIND(sell, 'og')
%    [idx, sellout] = CELLSTRFIND(sell, '[^0-9]og.y')
%
% Ex2: (?i) turns on case-insensitivity; (?-i) turns off case-insensitivity
%    sell = {'UPPERCASE', 'lowercase', 'MiXeDcAsE', 'mIxEdCaSe'}
%    [idx, sellout] = CELLSTRFIND(sell, 'case')
%    [idx, sellout] = CELLSTRFIND(sell, '(?i)case')
%    [idx, sellout] = CELLSTRFIND(sell, '(?i)ca(?-i)se')
%    [idx, sellout] = CELLSTRFIND(sell, '(?i)cas(?-i)e')
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 28-Nov-2019, Version 2017b on GLNXA64

matches = regexp(sell, pattern);
idx = find(~cellfun(@isempty, matches));
sellout = sell(idx);
