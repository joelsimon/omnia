function b = commasepstr2cell(a, delimiter)
% b = COMMASEPSTR2CELL(a, delimiter)
%
% Returns a cell array containing every char array between the
% specified delimiters of an input string.
%
% COMMASEPSTR2CELL is the opposite of cell2commasepstr.m
%
% Input:
% a          Char array with N entries and N-1 delimiters
% delimiter  Delimiter between list entries (def: ',')
%
% Output:
% b          Cell of chars splitting up the input list
%
% Ex:
%    a = 'apple,  orange,  pear,  banana,  kumquat';
%    b = COMMASEPSTR2CELL(a, ',')
%    a = 'apple   orange   pear   banana   kumquat'
%    b = COMMASEPSTR2CELL(a, '   ')
%    a = 'apple | orange | pear | banana | kumquat'
%    b = COMMASEPSTR2CELL(a, '|')
%
% See also: cell2commasepstr.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 11-Sep-2019, Version 2017b on GLNXA64

defval('delimiter', ',')

if ~ischar(a)
    error('Input arg 1 must be a char')

end

if ~ischar(delimiter)
    error('Input arg 2 must be char')

end

idx = strfind(a, delimiter);
if isempty(idx);
    error('Input: %s\ndoes not include specified delimiter: ''%s''', ...
          a, delimiter)

end

b{length(idx)+1} = [];
b{1} = strtrim(a(1:idx(1)-1));
b{end} = strtrim(a(idx(end)+1:end));
for i = 2:length(idx)
    b{i} = strtrim(a(idx(i-1)+1:idx(i)-1));

end
