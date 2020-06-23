function pos = axpos(ha)
% pos = AXPOS(ha)
%
% Returns struct containing (x,y) corners and midpoints of a graphics object
% (e.g., an axes or colorbar) in reference to the CONTAINER (figure or uipanel).
%
% Input:
% ha            Graphics object handle (def: gca)
%
% Output:
% pos           Axes position struct with fields:
%               .ll: lower left corner
%               .ul: upper left corner
%               .lr: lower right corner
%               .ur: upper right corner
%               .bottommid: bottom middle point
%               .topmid: top middle point
%               .leftmid: left middle point
%               .rightmid: right middle point.
%
% Ex: (ll corner of small red axes hits all corners/midpoints of larger axes)
%    pos = AXPOS('demo')
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 23-Jun-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default.
defval('ha',gca)

% Demo, maybe.
if isstr(ha)
    pos = demo;
    return

end

% Parse.
left = ha.Position(1);
bottom = ha.Position(2);
width = ha.Position(3);
height = ha.Position(4);

% Collect corners.
pos.ll = [left  bottom];
pos.ul = [left bottom+height];
pos.lr = [left+width bottom];
pos.ur = [left+width bottom+height];

% Collect midpoints.
pos.bottommid = [(width/2)+left bottom];
pos.topmid = [(width/2)+left bottom+height];
pos.leftmid = [left bottom+(height/2)];
pos.rightmid = [left+width bottom+(height/2)];

% Rotate axes 2 clockwise about axes 1, starting upper left corner.
function pos = demo
    figure
    ha1 = subplot(4,4,[6 7 10 11]);
    grid on; grid minor
    ha2 = subplot(4,4,1);
    ha2.Color = 'red';
    pos = axpos(ha1);
    shg; pause(1)
    ha2.Position(1:2) = pos.ul; pause(1)
    ha2.Position(1:2) = pos.topmid; pause(1)
    ha2.Position(1:2) = pos.ur; pause(1)
    ha2.Position(1:2) = pos.rightmid; pause(1)
    ha2.Position(1:2) = pos.lr; pause(1)
    ha2.Position(1:2) = pos.bottommid; pause(1)
    ha2.Position(1:2) = pos.ll; pause(1)
    ha2.Position(1:2) = pos.leftmid; pause(1)
