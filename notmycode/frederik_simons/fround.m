function rounded=fround(numb,after)
% rounded=FROUND(numb,after)
%
% Rounds number to certain number of digits after the period sign.
%
% INPUT:
%
% numb      A number
% after     A number of digits
%
% OUTPUT:
%
% rounded   The rounded number
%
% SEE ALSO:
%
% ROUNDN, CHOP
%
% Last modified by fjsimons-at-alum.mit.edu, 10/26/1998

rounded=round(numb*10^after)/10^after;
