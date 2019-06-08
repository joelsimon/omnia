function newticks = numticks(ax, xory, num)
% newticks = numticks(ax,xory,num)
%
% Specify the number of ax.XTick or ax.YTick.
%
% NUMTICKS automatically adjusts the x or y ticks of an input axes to
% be an (roughly; the values are rounded) equally-spaced array of
% length 'num' between the current X or Y limits.  I.e., set final
% axes limits first and then adjust the number of ticklabels with
% NUMTICKS.
%
% Input:
% ax          Axes handle
% xory        Axes limit to adjust, 'x' or 'y'   
% num         Number of ticklabels on adjusted limit
%
% Output:
% newticks    Array of new x or y ticks
%
% Ex:
%    plot(randn(1,100))
%    NUMTICKS(gca, 'x', 4)
%    NUMTICKS(gca, 'y', 5)
%    NUMTICKS(gca, 'x', 10)
%    NUMTICKS(gca, 'y', 25)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 28-May-2019, Version 2017b

% Sanity checks for first two input arguments. linspace.m handles
% the last input argument with an 'isscalar' check.
xory = upper(xory);
assert(strcmp(xory, 'X') || strcmp(xory, 'Y'), ['Input either ''X'' ' ...
                    'or ''Y'' for second argument.'])

% Nab current axes limits, generate new array based on limits, set
% ticks to new array.
chglim = [xory 'Lim'];
newticks = linspace(ax.(chglim)(1), ax.(chglim)(2), num);
chgticks = [xory 'Tick'];
ax.(chgticks) = newticks;
