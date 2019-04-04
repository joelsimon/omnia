function add1XTick(axs)
% ADD1XTICK(axs)
%
% Tries to add an XTick at x = 1 for every input axis handle.  Only
% works if all current XTicks > 1. Default axs = gca.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 01-Dec-2017, Version 2017b

% Default.
defval('axs',gca)

% Sanity check.
if ~all(isgraphics(axs,'axes'))
    error('Pass axes handle as second argument')
end

% Do it.
for i = 1:length(axs)
    try
        axs(i).XTick = [1 axs(i).XTick];
    end
end
