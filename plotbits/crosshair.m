function [p, hg] = crosshair(ha, x, y, xwing, ywing, varargin)
% [p, hg] = CROSSHAIR(ha, x, y, xwing, ywing, ['option', value...])
%
% Plot a crosshair. Useful for visualizing measures of center and
% spread.  Returns both a structure, p, and an hgtransform object, hg,
% for subsequent manipulation.
% 
% Input:
% ha                 Axes handle (def: gca)
% x,y                x,y value of center 
% x,ywing            x,y spread about center (def: [])
% ['option', value]  Option/value pairs for plot.m
%
% Output:
% p                  Line object structure with fields: 
%                     .c: handle to circle at center
%                     .x,y: handle(s) to x/y spread, if created
% hg                 hgtransform object of grouped handles
%
%
% Ex: (highlight data mean & standard deviation; shift crosshair up)
%    figure; ha = gca; data = randn(1e5, 1); 
%    his = histogram(ha, data, 'Normalization', 'Probability');
%    set(his, 'EdgeColor', '[.2 .2 .2]', 'FaceColor', '[.2 .2 .2]')
%    [p,hg] = CROSSHAIR(ha, mean(data), 0, std(data));
%    yshift = mean(ha.YLim);
%    matrix = makehgtform('translate', 0, yshift, 0);
%    hg.Matrix = matrix;
%    set([p.c p.x], 'Color', 'r', 'LineWidth', 2)
%
% The example shows the power of an hgtransform object; all line
% objects are grouped and thus can be shifted all at once instead of
% individually.
%    
% Note equality of grouped object's children and structure p:
% eq(hg.Children(end),p.c) = 1.
% 
% Also note that p.c.YData = 0 in the example even though it's plotted
% half way up YLim. This is due to transformation via hg.Matrix.
% 
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 02-Jan-2018, Version 2017b

% Defaults.
defval('ha',gca)
defval('x',0)
defval('y',0)
defval('xwing',[])
defval('ywing',[])

% Sanity check: verify correct type passed.
assert(all(isgraphics(ha, 'Axes')),...
       'Please pass axes handle as first argument.')

% I want crosshair to overlie all objects: nab ZLim.  
% Add realmin because zmax may be 0.
zmax = ha.ZLim(2) + 1;

% Make transform object
axes(ha);
hg = hgtransform;

% Plot measure of center as a circle.
p.c = plot(hg, x, y, 'ok', 'MarkerFaceColor', 'w', varargin{:});

% Plot X/Y spreads as wings off center, maybe.
if ~isempty(xwing)
    p.x = plot(hg, [x - xwing x + xwing], [y y], 'k', varargin{:});
    p.x.ZData(2) = zmax;

end

if ~isempty(ywing)
    p.y = plot(hg, [x x], [y - ywing y + ywing], 'k', varargin{:});
    p.y.ZData(2) = zmax;

end

% Bring center circle to top (haven't had much luck with uistack...).
p.c.ZData = zmax*2;
