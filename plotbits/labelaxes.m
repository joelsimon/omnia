function [lax,th] = labelaxes(has,corner,alfabet,varargin)
% [lax,th] = LABELAXES(has,corner,alfabet,['option',value...])
%
% Labels each axes (in order supplied) at the corner or point
% specified by position string, as returned in axpos.m.  I.e., 'ul'
% for upper left; 'bottommid' for bottom middle.  Will require
% adjustment after placement. This just slaps over the axes.
%
% Inputs:
% has                List of handles, in order to be labeled (def: gca)
% corner             String noting corner to place label (def: 'ul')
% alfabet            true: labels are 'a','b','c', false: 1,2,3... (def: true)
% ['option',value]   Option/value list for text.m
%
% Outputs: 
% lax                Axes handles 
% th                 Text handles
%
% Ex: (create labels in corner, move, make uppercase)
%    figure; shg; ha1 = subplot(3,1,1); ha2 = subplot(3,1,2);
%    ha3 = subplot(3,1,3); has = [ha1 ha2 ha3];
%    [lax,th] = LABELAXES(has,'ul',true,'FontName','Times', ...
%                        'FontSize',25,'color','m'); pause(1)
%    for i = 1:length(has)
%        lax(i).Position(1:2) = [lax(i).Position(1)*.4 lax(i).Position(2)*1.05];
%        th(i).String = upper(th(i).String); pause(1)
%    end
%
% See also: axpos.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 14-Aug-2017, Version 2017b

% Defaults.
defval('has',gca)
defval('corner','ul')
defval('alfabet',true)

% Throw warning if number of plots greater than length of the alphabet.
numax = length(has);
if alfabet
    assert(numax<26,'More than 26 plots and alphabet requested...')
    alphabet = 'abcdefghijklmnopqrstuvwxyz';

end

% For every input axes: make new invisible axes at bottom corner,
% label with string, move to position.
for i = 1:numax
    % Make current axes active.
    axes(has(i));

    % Get position elements of current axes.
    pos = axpos(has(i));

    % Create axes at requested position, set invisible.
    lax(i) = axes('position',[pos.(corner) 0 0 ]);
    lax(i).Visible = 'off';

    % Label.
    if alfabet
        label = sprintf('(%s)',alphabet(i));

    else
        label = sprintf('(%i)',i);

    end

    % Text box in new axes, set text at (0,0).
    th(i) = text(0,0,label,varargin{:});

end

