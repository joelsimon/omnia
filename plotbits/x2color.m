function [col, cbticks, cbticklabels, cmap, idx] = x2color(x, xmin, xmax, cmap, within)
% [col, cbticks, cbticklabels, cmap, idx] = X2COLOR(x, xmin, xmax, cmap, within)
%
% Linearly map data vector to an RGB colormap.
%
% A colormap is an M x 3 matrix where cmap(1, :) maps to the lowest
% value in x, and cmap(end, :) maps to the highest value in x.  This
% function distributes (as best as possible) all values linearly
% between those minimum- and maximum-intensity RGB triplets.
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
% cbticks       length(col)+1 tick mark locations
% cbticklabels  length(col)+1 tick mark labels
%
% cmap         Colormap used
% idx          Index (row) of colormap: col = cmap(idx, :)
%
% Ex1: (recreate scatter.m automatic color-scaling)
%    x = randn(25, 1);
%    sc = scatter(x, x, 30, x, 'Filled'); % automatic coloring
%    cmap = colormap(sc.Parent); box on; hold on
%    col = X2COLOR(x, [], [], cmap);
%    sc = scatter(x, x, 90, col);         % defined coloring
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
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 11-Mar-2020, Version 2017b on MACI64

% Defaults.
defval('xmin', min(x))
defval('xmax', max(x))
defval('cmap', jet(64))
defval('within', false)

% Set all values below/above the intensity cutoffs to the min/max
% requested saturation level.
x(x <= xmin) = xmin;
x(x >= xmax) = xmax;

% Number of discrete RGB triplets in colormap.
ncols = size(cmap, 1);

% Normalize the data between 1 (lowest intensity) and
% ncols (highest intensity).
idx = round(norm2ab(x, 1, ncols));

% Select those RGB triples that correspond to the linearly-mapped
% data.
col = cmap(idx, :);

% Return the mapping for colorbar.m (whose ticks natively go from [0:1])
% between ticks and ticklabels given the data.
cbticks = linspace(0, 1, length(cmap)+1);
if within
    cbticks = cbticks(1:end-1) + diff(cbticks)/2;

end
cbticklabels = num2cell(norm2ab(cbticks, xmin, xmax));
