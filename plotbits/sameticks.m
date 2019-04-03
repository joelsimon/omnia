function sameticks(proto,has,ax)
% SAMETICKS(proto,has,ax)
%
% Like sameaxes.m, but also adjusts all ticks and tick labels to be
% equal to the prototypical example. Only works on major/minor tick
% positions and labels. 
%
% Input:
% proto        Prototypical axes to be copied
% has          Vector of axes handles to copy to
% ax           'x', 'y', or 'both' (def: 'both')
%
% Output:
% None
%
% Ex: (top is proto; bottom rescaled and axes copied from top)
%    figure; shg
%    p1 = subplot(2,1,1);
%    p2 = subplot(2,1,2);
%    plot(p1,[0:12],'k-o','MarkerFaceColor','k');
%    plot(p2,[10:-2:2],'r-o','MarkerFaceColor','r');
%    pause(2)
%    p1.XTick = [4 8 11]; p1.XAxis.MinorTick = 'on'; pause(2)
%    p1.XTickLabel = {'4th Tick' '8th Tick' '11th Tick'}; pause(2)
%    p1.YTickLabel = []; pause(2)
%    SAMETICKS(p1,p2,'both')
%
% See also: sameaxes.m, symaxes.m, doubleax.m.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 30-Oct-2017, Version 2017b

% Defaults.
defval('ax','both')

% Sanity check: verify 'axes' and not 'figure' or other handles passed.
if ~all(isgraphics([proto has],'axes'))
    errstr = ['At least one handle passed was not an axes handle.' ...
              '\nPlease verify all types of ''has'' are ''axes''.'];
    error(sprintf(errstr));
end

% Adjust either x, y, or both axes.
ax = upper(ax);
switch ax
  case 'X'
    relabel(proto,has,'X');
  case 'Y'
    relabel(proto,has,'Y');
  case {'XY','YX','BOTH'}
    relabel(proto,has,'X');
    relabel(proto,has,'Y');
  otherwise
    error(['Unrecognized axes option: please specify ''x'', ''y'', ' ...
           'or ''both''.'])
end

% Save the current limits, tick positions, and tick labels, and
% copy them to every handle supplied.
function relabel(proto,has,ax)
    % Switch field depending on XAxis, YAxis.*
    XY = sprintf('%sAxis',ax);    
    lim = proto.(XY).Limits;
    ticks = proto.(XY).TickValues;
    labels = proto.(XY).TickLabels;
    dirs = proto.(XY).TickDirection;
    len = proto.(XY).TickLength;
    isminor = strcmp(proto.(XY).MinorTick,'on');
    if isminor
        minorticks = proto.(XY).MinorTickValues;
    end
    
    % Deal the copies out.
    for i = 1:length(has)
        has(i).(XY).Limits = lim;
        has(i).(XY).TickValues = ticks;
        has(i).(XY).TickLabels = labels;
        has(i).(XY).TickDirection = dirs;
        has(i).(XY).TickLength = len;
        % Minor ticks, maybe.
        if isminor
            has(i).(XY).MinorTick = 'on';
            has(i).(XY).MinorTickValues = minorticks;
        end
    end

%* Teachable moment: it seems dynamic field names, proto.(field),
% where you switch the field with some evaluated function (e.g.,
% proto.(sprintf('%sAxis',ax))), doesn't work if that field has a dot,
% '.'.  Makes sense; that is the marker for new field. Must use
% separate statement for each field; can't use
% proto.('XAxis.MinorTick'); use proto.('XAxis').MinorTick;
