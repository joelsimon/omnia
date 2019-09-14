function a = cell2commasepstr(b, delimiter)
% a = CELL2COMMASEPSTR(b, delimiter)
%
% Returns a char array that concatenates every char array contained
% in each index of an input 1D cell.
%
% CELL2COMMASEPSTR is the opposite of commasepstr2cell.m
%
% Input:
% b          Cell of chars
% delimiter  Delimiter between list entries (def: ', ')
%
% Output:
% a          Char array with N entries and N-1 delimiters
%
% Ex:
%    b = {'apple' 'orange' 'pear' 'banana' 'kumquat'};
%    a = CELL2COMMASEPSTR(b, ',  ')
%    a = CELL2COMMASEPSTR(b, '   ')
%    a = CELL2COMMASEPSTR(b, ' | ')
%
% See also: commasepstr2cell.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 11-Sep-2019, Version 2017b on GLNXA64

defval('delimiter', ',')

if ~iscell(b)
    error('Input arg 1 must be a char')

end

if ~ischar(delimiter)
    error('Input arg 2 must be char')

end

a = [];
for i = 1:length(b)
    if ~ischar(b{i})
        error('Input arg 1 must be a cell of char arrays')

    end
    a = [a delimiter b{i}];
    
end
a(1:length(delimiter)) = [];
