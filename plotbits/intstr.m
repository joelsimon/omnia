function str = intstr(x,precision)
% str = INTSTR(x,precision)
%
% Returns x as a formatted string.  If x is an integer, returns
% integer string. If it is not an integer, sets precision (decimal
% places) of sprintf to that specified. Useful for plotting
% annotations given arbitrary data.
%
% Input:
% x                 A number
% precision         (integer) Precision format specifier (def: 1)
%
% Output:
% str               x as a formatted string
%
% See also: isint.m
%
% Ex: 
%     str = intstr(4)
%     >> str = '4'
%     str = intstr(4.2312,2)
%     >> str = '4.23'
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 03-July-2017, Version 2017b

% Default precision.
defval('precision',1)

% Override precision = 0
if precision == 0
    precision = 1;
end

% Check if int and use %i; otherwise %f.
if isint(x)
    str = sprintf('%i',x);
else
    % Easy to pass in '.2' when '2' is meant; remove decimal.
    precision = str2num(strtok(num2str(precision),'0.'));
    str = sprintf('%.*f',precision,x);
end
