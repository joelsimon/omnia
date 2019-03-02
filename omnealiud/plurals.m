function str = plurals(str,i)
% str = PLURALS(str,i)
%
% Adds s to string if i ~= abs(1).
%
% Ex: str = plurals('sample',1)
%     >> str = 'sample'
%     str2 = plurals('sample',2)
%     >> str2 = 'samples'
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 08-Jun-2017, Version 2017b

if abs(i) ~= 1
    str =[str 's'];
end
