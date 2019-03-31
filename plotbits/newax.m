function f = newax(ha)
% f = NEWAX(ha)
%
% Determines if new axes need to be generated. If you pass in a handle
% it returns that axes and figure handle.  Conversely, if ha is empty
% or NaN, new figure and axes objects are created and handles
% returned.  Useful for sending things to subplot panels.
%
% Input:
% ha       Axes (not figure) handle (def: [])
%
% Output:
% f        Struct with f.ha (axes handle), f.f (figure handle)
%
% Ex1: (generate new figure)
%    f = NEWAX;
%
% Ex2: (don't generate new figure)
%    p2 = subplot(2,3,[5 6])
%    f = NEWAX(p2)
%    plot(f.ha,1:10)
%    f.f.Color = 'r'; % have full control over figure...
%    title(f.ha,'This is the subplot title') % and children...
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 28-Jul-2017, Version 2017b

% Default.
defval('ha',[])

if isempty(ha) 
    f.f = figure;
    f.ha = axes;
else
    % Verify ha is axes handle.
    assert(all(isgraphics(ha,'axes')),...
           'Please pass axes handle as first argument.')
    f.ha = ha;
    f.f = ha.Parent;
end
