function add1XTick(ax, xory)
% ADD1XTICK(ax, xory)
%
% Tries to add an XTick (or YTick) at x = 1 (or y = 1) for every input
% axis handle.  Only works if all current XTicks > 1 (or YTicks > 1).
%
% Input:
% ax       Axis handle (def: gca)
% xory     'X' or 'Y' (def: 'X')
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 27-May-2019, Version 2017b

% Default.
defval('ax', gca)
defval('xory', 'X')

% Sanity check.
if ~all(isgraphics(ax,'axes'))
    error('Pass axes handle as second argument')
end

% Do it.
for i = 1:length(ax)
    switch lower(xory)
      case 'x'
        ticktype = 'XTick';

      case 'y'
        ticktype = 'YTick';

      otherwise
        error('Specify ''X'' or ''Y'' for input: xory')

    end

    try
        ax(i).XTick = [1 ax(i).(ticktype)];

    end
end
