function [idx, sellout] = cellstrfind(sell, pattern)
% [idx, sellout] = CELLSTRFIND(sell, pattern)
%
% Returns the indices and strings in a cell which contain the pattern.
%
% Input:
% sell       Cell array of strings
% pattern    The string to search for
%
% Output:
% idx        The index of matches (def: {})
% sellout    Cell of matching strings, 
%                literally sell(idx) (def: {})
%
% Ex:
%    sell = {'dog' 'walk' 'on' 'a' 'soggy' 'log' 'with' 'a' 'frog'}
%    [idx, sellout] = CELLSTRFIND(sell, 'og')
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 23-May-2019, Version 2017b

matches = strfind(sell, pattern, 'ForceCellOutput', true);
idx = find(~cellfun(@isempty, matches));
sellout = sell(idx);
