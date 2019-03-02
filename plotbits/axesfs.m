function axesfs(fig, axfs, txfs)
% axesfs(fig, axfs, txfs)
%
% Axes FontSize adjuster.  
%
% AXESFS adjusts all axes fontsizes (e.g., tick labels and axes
% labels) to size specified by 'axfs', and all (if any) text (e.g.,
% from text.m) in an input figure to size specified by 'txfs'
%
% Inputs:
% fig       Figure handle (def: gcf)
% axfs      Font size of figure axes    
% txfs      Font size of any text in figure
%
% Output:   Adjusts all fontsizes to your liking
%
% Ex: (make axes and text box, wait 2 seconds, enlarge both fonts)
%    fig = figure; ax = axes(fig);
%    text(ax, 0.1, 0.5, 'here''s some text');
%    pause(2)
%    AXESFS(fig, 25, 25)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 13-Mar-2018, Version 2017b

% Defaults
defval('fig', gcf)
defval('axfs', [])
defval('txfs', [])

% Sanity check.
if ~isgraphics(fig, 'Figure') 
    error('Pass only figure, not axes, handle as first input argument.')

end

% Find all instances and adjust accordingly.
if ~isempty(axfs)
    set(findall(fig, 'type', 'axes'), 'FontSize', axfs)

end
if ~isempty(txfs)
    set(findall(fig, 'type', 'text'), 'FontSize', txfs)
    set(findall(fig, 'type', 'legend'), 'FontSize', txfs)

end
