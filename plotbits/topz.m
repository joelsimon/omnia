function zmax = topz(lobj, ha)
% zmax = TOPZ(lobj,ha)
%
% TOPZ moves a LINE object to the top of the visual pile.
%
% Simply adds 1 to the input axes' maximum ZData.  Defaults to use
% parent axes ZData, but user may supply other container as input.
% Stacks multiple line objects in order they are input, with last
% being on the top.
%
% Input:
% lobj          Line handle(s) to send to top
% ha            Axes handle whose ZData this queries (def: gca)
%
% Output:
% zmax          ZData value line object which now sits at top
%
% Ex: (alternate red over blue with intersecting lines)
%    figure; ha = gca; hold on; shg
%    x = linspace(0,4*pi,1e4); y = sin(x).^3;
%    plr = plot(x,y,'r','LineWidth',10);
%    plb = plot(x+.5*pi,y,'b','LineWidth',10);
%    zmax = TOPZ(plr); pause(2)
%    zmax = TOPZ(plb); pause(2)
%    zmax = TOPZ(plr); pause(2)
%    zmax = TOPZ(plb); pause(2); hold off
%
% See also: botz.m
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

% Nab current maximum ZData value.
zmax = ha.ZLim(2);

% Add 1 to zmax with every object and assign zmax to ZData vector of
% correct dimensions.
for i = 1:length(lobj)
    zmax = zmax + 1;
    lobj(i).ZData = repmat(zmax, size(lobj(i).YData));
end
