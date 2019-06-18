function [xl,yl] = symaxes(ha,ax)
% [xl,yl] = SYMAXES(ha,ax)
%
% Adjusts axes so that they are symmetric about 0.
%
% Input:
% ha           Axis handle (def: gca)
% ax           'x', 'y', or 'both' (def: 'both')
%
% Output:
% xl/yl        New X/YLims, if adjusted (def: [])
%
% Ex: 
%    x = linspace(0,2*pi*1.7,1e3); y = sin(x).^3+1;
%    figure; plot(x,y,'r')
%    [xl,yl] = SYMAXES(gca,'both')
%    grid on; grid minor
%
% See also: sameaxes.m, doubleax.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 03-Aug-2017, Version 2017b

% Defaults.
defval('ha',gca)
defval('ax','both')
defval('xl',[])
defval('yl',[])

% Sanity check.
assert(all(isgraphics(ha,'Axes')),...
       'Please pass axes handle as first argument.')

% Adjust either x, y, or both axes.
ax = upper(ax);
switch ax
  case 'X'
    xl = relim(ha,'X');
  case 'Y'
    yl = relim(ha,'Y');
  case {'XY','YX','BOTH'}
    xl = relim(ha,'X');
    yl = relim(ha,'Y');
  otherwise
    error(['Unrecognized axes option: please specify ''x'', ''y'', ' ...
           'or ''both''.'])
end

% Get current limits, set new symmetric limits using largest current.
function lim = relim(ha,ax)
    largest = max(abs(eval(sprintf('[ha(:).%sLim]',ax))));
    lim = [-largest largest];
    ha.(sprintf('%sLim',ax)) = lim;
