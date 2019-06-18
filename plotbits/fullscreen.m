function ha = fullscreen(ha)
% ha = FULLSCREEN(ha)
%
% Makes a figure window full screen.  A new figure is generated if no
% handle is passed.
%
% Input/Output: 
% ha                   Figure handle.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 21-July-2017, Version 2017b

% Default.
defval('ha',[])

% Do it.
if ~nargin || isempty(ha)
    figure('units','normalized','outerposition',[0 0 1 1])

else
    % Sanity check: handle must of type figure.
    assert(isgraphics(ha,'figure'),['Must pass figure and not other ' ...
                    'graphics handle.'])
    set(ha,'units','normalized','outerposition',[0 0 1 1])

end
ha = gcf;
