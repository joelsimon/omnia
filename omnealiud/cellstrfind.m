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
% Ex:
%    sell = {'dog' 'froggy' 'hop' 'on' 'a' 'soggy' 'log' 'in' 'a' 'bog'}
%    [idx, sellout] = CELLSTRFIND(sell, 'og')
%    [idx, sellout] = CELLSTRFIND(sell, '[^0-9]og.y')
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 07-Aug-2019, Version 2017b

matches = regexp(sell, pattern);
idx = find(~cellfun(@isempty, matches));
sellout = sell(idx);
