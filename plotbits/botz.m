function zmin = botz(lobj, ha)
% zmin = BOTZ(lobj, ha)
%
% BOTZ moves a LINE object to the bottom of the visual pile.  
%
% Simply removes 1 to the input axes' minimum ZData.  Defaults to use
% parent axes ZData, but user may supply other container as input.
% Stacks multiple line objects in order they are input, with last
% being on the bottom.
%
% Input:
% lobj          Line handle(s) to send to bottom
% ha            Axes handle whose ZData this queries (def: gca)
%
% Output:
% zmin          ZData value line object which now sits at bottom
%
% Ex: (alternate blue over red with intersecting lines)
%    figure; ha = gca; hold on; shg
%    x = linspace(0,4*pi,1e4); y = sin(x).^3;
%    plb = plot(x+.5*pi,y,'b','LineWidth',10);
%    plr = plot(x,y,'r','LineWidth',10);
%    zmin = BOTZ(plr); pause(2)
%    zmin = BOTZ(plb); pause(2)
%    zmin = BOTZ(plr); pause(2)
%    zmin = BOTZ(plb); pause(2); hold off
%
% See also: topz.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 14-Mar-2018, Version 2017b

% Default.
defval('ha', lobj(1).Parent)

% Sanity checks.
assert(all(isgraphics(lobj, 'Line')),...
       'Please pass LINE handle(s) as first argument.')
assert(all(isgraphics(ha, 'Axes')),...
       'Please pass AXES handle as second argument.')

% Nab current minimum ZData value.
zmin = ha.ZLim(1);

% Subtract 1 from zmin with every object and assign zmin to ZData
% vector of correct dimensions.
for i = 1:length(lobj)
    zmin = zmin - 1;
    lobj(i).ZData = repmat(zmin, size(lobj(i).YData));
end
