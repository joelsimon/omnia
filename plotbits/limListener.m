function el = limListener(linObj,axlim)
% el = LIMLISTENER(linObj,axlim)
%
% Adds a listener to a vertical/horizontal line to change the
% YData/XData limits to reflect a changing parent container.
%
% Inputs:
% linObj            A line object with two data points
% axlim             'x', 'y', or 'z', case insensitive
%
% Output:
% el               proplistener attached to the line object's parent
%
% Ex: (vertical line's limits expand automatically with axes limits)
%    figure; shg; axObj = gca; linObj = plot([.5 .5],[0 10]);
%    el = LIMLISTENER(linObj,'Y'); pause(2)
%    axObj.YLim = [-15 15]; pause(2)
%    axObj.YLim = [-100 100]; 
%
% See also: vertline.m, horzline.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 17-Aug-2017, Version 2017b

% Determine which axes the data limits are pinned to.
axlim = upper(axlim);

% Data prep and Sanity checks.
assert(isgraphics(linObj,'Line'),'Must pass Line object as first input.')
assert(length(axlim)==1 && contains('XYZ',axlim), ['Plase specify ' ...
                    'only ''x'',''y'', or ''z'' for input axlim.'])
whichLim = [axlim(1) 'Lim'];
whichData = [axlim(1) 'Data'];
assert(length(linObj.(whichData))==2, ['Line''s .X/Y/ZData property ' ...
                    'can only be of length 2; e.g. the axes limits.'])

%% Main
% el tracks changes to the limits of the line object's parents.  If
% the parent changes, the line changes (shrinks or expands) with it.
el = addlistener(linObj.Parent,whichLim,'PostSet',@(src,evt) ...
                 updateLim(src,linObj,axlim,whichData));
end
%% End main

% This is the action to take if the listener is alerted; .X/Y/ZData
% limits of line are shrunk/expanded to equal the new axes limits.
function updateLim(src,linObj,axlim,whichData)
    linObj.(whichData) = linObj.Parent.(src.Name);
end
