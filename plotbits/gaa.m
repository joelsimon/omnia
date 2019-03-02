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
% Last modified by jdsimon@princeton.edu, 03-August-2017

defval('f',gcf)
assert(all(isgraphics(f,'figure')),...
       'Please supply figure handle as input.')
ha = findobj(f,'type','axes');
