function ha = gaa(f)
% ha = GAA(f)
%
% Get all axes handles.
%
% Input:
% f            Figure handle
%
% Output
% ha           Axes handles in figure
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 03-Aug-2017, Version 2017b

defval('f',gcf)
assert(all(isgraphics(f,'figure')),...
       'Please supply figure handle as input.')
ha = findobj(f,'type','axes');
