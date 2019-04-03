function [xl,yl] = sameaxes(has,ax)
% [xl,yl] = SAMEAXES(has,ax)
%
% Like linkaxes.m except that it sets requested axes to the largest
% (in an absolute sense) limits of the input handles; linkaxes.m
% chooses the smallest limits.  Sets X/YTickLabels to auto and
% therefore overrides any manual setting. Use this function first to
% open up all axes to the same size, and adjust tick labels later.
%
% E.g., if has(1).Xlim = [-5 2], has(2).XLim = [-3 10], it will set
% all axes XLims to [-5 10]. Only works for 2D axes.
%
% Input:
% has          Vector of axes handles (def: gaa)
% ax           'x', 'y', or 'both' (def: 'both')
%
% Output:
% x/yl        New X/YLims, if adjusted (def: [])
%
% Ex: (set to largest, then link)
%    p1 = subplot(2,1,1);
%    p2 = subplot(2,1,2);
%    plot(p1,1:10,11:20);
%    plot(p2,-3:3,7:13,'r'); shg; pause(2)
%    [xl,yl] = SAMEAXES([p1 p2],'both'); pause(2)
%    linkaxes([p1 p2]); pause(2)
%    p1.XLim = [-4 6];
%
% See also: sameticks.m, symaxes.m, doubleax.m, gaa.m.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 08-Aug-2017
% Last modified by jdsimon@princeton.edu, 08-August-2017.

% Defaults.
defval('has',gaa)
defval('ax','both')
defval('xl',[])
defval('yl',[])

% Sanity check: verify 'axes and not 'figure' or other handles passed.
if ~all(isgraphics(has,'axes'))
    errstr = ['At least one handle passed was not an axes handle.' ...
              '\nPlease verify all types of ''has'' are ''axes''.'];
    error(sprintf(errstr));
end

% Adjust either x, y, or both axes.
ax = upper(ax);
switch ax
  case 'X'
    xl = relim(has,'X');
    adjust(has,'X',xl);
  case 'Y'
    yl = relim(has,'Y');
    adjust(has,'Y',yl);
  case {'XY','YX','BOTH'}
    xl = relim(has,'X');
    adjust(has,'X',xl);
    yl = relim(has,'Y');
    adjust(has,'Y',yl);
  otherwise
    error(['Unrecognized axes option: please specify ''x'', ''y'', ' ...
           'or ''both''.'])
end

% Nab the min and max of the specified axes for every handle.
% [has(:).Xlim] (note the brackets) places everything into an array
% that can be passed to minmax. The 'eval' switches 'XLim' or 'YLim'.
function lim = relim(has,ax)
    lim = minmax(eval(sprintf('[has(:).%sLim]',ax)));

% And then set the desired limit(s) to the min and max just found.
function adjust(has,ax,lim)
% Before you adjust check state of TickLabels; if they are
% currently empty, don't add them!
    for i = 1:length(has)
        has(i).(sprintf('%sLim',ax)) = [lim(1) lim(2)];
        has(i).(sprintf('%sTickLabelMode',ax)) = 'auto';
    end
