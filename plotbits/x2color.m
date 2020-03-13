function [col, cbticks, cbticklabels, cmap, idx] = x2color(x, xmin, xmax, cmap, within)
% [col, cbticks, cbticklabels, cmap, idx] = X2COLOR(x, xmin, xmax, cmap, within)
%
% X2COLOR linearly distributes the values of a data vector, 'x',
% between minimum- and maximum-intensity RGB triplets.
%
% Data values at which the colors are minimum and maximum intensity
% may be specified with 'xmin' and 'xmax'.  By default, these are
% min(x) and max(x), i.e., the colormap output by X2COLOR saturates at
% the values of the data vector.
%
% If 'xmin' is GREATER than the minimum value in the data vector
% (i.e., the data extends below the minimum saturation color), all
% values at or below 'xmin' will be mapped to the minimum-intensity
% color, col(1,:). (Same with 'xmax' and the maximum-intensity color).
%
% If 'xmin' is LESS THAN the minimum value in the data vector (i.e.,
% the data do not reach the minimum saturation color), then the
% minimum intensity value of the colorbar is not reached at col(1,:).
% (Same with 'xmax' and the maximum-intensity color). See Ex4.
%
% Input:
% x         1D data array
% xmin      Inclusive x value of lower limit of cmap
%               (def: min(x))
% xmax      Inclusive x value of upper limit of cmap
%               (def: max(x))
% cmap      Colormap (def: jet(64))
% within    true: cbticks/labels fall within discrete color intervals,
%                 length(cbticks/labels) = length(cmap) (see Ex3)
%           false: cbticks/labels fall at the edges of discrete colors,
%                 length(cbticks/labels) = length(cmap)+1 (def)
%
% Output:
% col           RGB value of x
% cbticks       Colorbar tick mark locations
% cbticklabels  Colorbar tick mark labels
% cmap          Colormap used
% idx           Index (row) of colormap: col = cmap(idx, :)
%
% NB, in all examples below the "data" value ('x') is actually plotted
% on the y-axis; the x-axis label is meaningless and just shows the
% order that the data are plotted.  See, e.g., Ex2. where the minimum
% saturation level (blue) occurs at y = 1 and the maximum saturation
% level (red) occurs at y = 3.7; the x-axis values at those locations
% are just the indices in 'x' where those values occur.
%
% Ex1: (recreate scatter.m automatic color-scaling)
%    x = randn(25, 1);
%    sc = scatter(x, x, 30, x, 'Filled'); % MATLAB automatic colors
%    cmap = colormap(sc.Parent); box on; hold on
%    col = X2COLOR(x, [], [], cmap);
%    sc = scatter(x, x, 90, col);         % X2COLOR colors
%
% Ex2: (set min. and max. color saturation levels to -1 and 3.7)
%    x = linspace(-5, 5, 101);
%    [col, cbticks, cbticklabels, cmap] = X2COLOR(x, -1, 3.7, jet(100));
%    hold(axes, 'on')
%    for i = 1:length(x)
%        plot(i, x(i), 'o', 'MarkerFaceColor', col(i, :), 'MarkerEdgeColor', col(i, :));
%    end
%    colormap(gca, cmap); axis tight; box on
%    cb = colorbar;
%    cb.Ticks = cbticks(1:20:end);
%    cb.TickLabels = cbticklabels(1:20:end);
%
% Ex3: (place tick labels inside or between discrete colors)
%    x = 1:4;
%    [col, cbticks1, cbticklabels1, cmap] = X2COLOR(x, [], [], hsv(length(x)), false);
%    scatter(x, x, [], col, 'Filled')
%    colormap(gca, cmap); axis tight; box on
%    cb1 = colorbar;
%    cb1.Ticks = cbticks1;
%    cb1.TickLabels = cbticklabels1;
%    [~, cbticks2, cbticklabels2] = X2COLOR(x, [], [], hsv(length(x)), true);
%    cb2 = colorbar('SouthOutside');
%    cb2.Ticks = cbticks2;
%    cb2.TickLabels = cbticklabels2;
%
% Ex4: (set min. and max. color saturation levels to -10 and 10,
%       but data only span -5 to 5)
%    x = linspace(-5, 5, 101);
%    [col, cbticks, cbticklabels, cmap] = X2COLOR(x, -10, 10, jet(100));
%    hold(axes, 'on')
%    for i = 1:length(x)
%        plot(i, x(i), 'o', 'MarkerFaceColor', col(i, :), 'MarkerEdgeColor', col(i, :));
%    end
%    colormap(gca, cmap); axis tight; ylim([-10 10]); box on
%    cb = colorbar;
%    cb.Ticks = cbticks(1:25:end);
%    cb.TickLabels = cbticklabels(1:25:end);
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 13-Mar-2020, Version 2017b on MACI64

% Defaults.
defval('xmin', min(x))
defval('xmax', max(x))
defval('cmap', jet(64))
defval('within', false)

% Set all values of the data below/above the intensity cutoffs to the
% min/max requested saturation level.
x(x <= xmin) = xmin;
x(x >= xmax) = xmax;

% Number of discrete RGB triplets in colormap.
ncols = size(cmap, 1);

% Generate a linear map from the minimum to the maximum requested
% saturation values because a colormap is just a linear map of the data
% where cmap(1,:) is the lowest-intensity color and cmap(end,:) is the
% highest-intensity color.
lin_map = linspace(xmin, xmax, ncols);

% Find the indices in lin_map which are nearest the real data
% values. Those indices represent the colors of the data because the
% indices of lin_map equal the rows of cmap.
%
% The data value at lin_map(1) maps to the color value at cmap(1, :).
% The data value at lin_map(end) maps to the color value at cmap(end, :).
idx = nearestidx(lin_map, x);
col = cmap(idx, :);

% Return the mapping for colorbar.m (whose ticks natively go from [0:1])
% between ticks and ticklabels given the data.
cbticks = linspace(0, 1, length(cmap)+1);
if within
    cbticks = cbticks(1:end-1) + diff(cbticks)/2;

end
cbticklabels = num2cell(norm2ab(cbticks, xmin, xmax));
