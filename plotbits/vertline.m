function vl = vertline(pos,axs,col,varargin) 
% vl = VERTLINE(pos,axs,col,['option',value...])
%
% Plot vertical line(s), possible across multiple axes.
% Returns a cell organized as vl{position}(axes).
% 
% Inputs:
% pos                Vector of xticks where line(s) are to be plotted
% axs                Vector of axes where you want the lines (def: gca)
% col                Color (def: 'r')
% ['option',value]   Option/value list for plot.m
% 
% Output:
% vl                 Cell array of line object(s)
%
% Ex: (plot same horizontal and vertical lines on two axes)
%    ha1 = subplot(2,1,1); ha2 = subplot(2,1,2);
%    vl = VERTLINE([0:.25:1],[ha1 ha2],'m','LineWidth',3);
%    hl = horzline([0:.25:1],[ha1 ha2],'r','LineWidth',3,'LineStyle',':');
%
% See also horzline.m.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 06-Feb-2018, Version 2017b

% Defaults
defval('axs',gca)
defval('col','r')

% Ensure options passed in correct order.
if ~isnumeric(pos)
    error('Pass position on X-Axis as first argument.')
end
if ~all(isgraphics(axs,'axes'))
    error('Pass axes handle as second argument.')
end

% Check options list has ['option', value] pair (if supplied).
if length(varargin)
    assert((mod(length(varargin),2) == 0), ...
           'Every ''option'' must have an associated value.')
end

% Plot every vertical bar, on every axis supplied.
for i = 1:length(axs)

    % Record current 'hold' state so that it's returned in same
    % state after function. Turn on if necessary.
    ax = axs(i);
    hstate = ishold(ax);
    if ~hstate 
        hold(ax,'on')
    end

    % Actually plot it.
    for j = 1:length(pos)
        vl{j}(i) = plot(ax,[pos(j) pos(j)],get(ax,'ylim'),col,varargin{:});
        
        % Bring it to top.
        topz(vl{j}(i));

        % Add a listener to all lines in that axes.
        limListener(vl{j}(i),'Y');

    end
    
    % Turn hold 'off' it function entered that way.
    if ~hstate
        hold(ax,'off')
    end
end
