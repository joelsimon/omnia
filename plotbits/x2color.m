function [col, cmap, cbticks, cbticklabels, idx] = x2color(x, xmin, xmax, cmap)
% [col, cmap, cbticks, cbticklabels, idx] = X2COLOR(x, xmin, xmax, cmap)
%
% Linearly maps data vector to RGB colormap.
%
% A colormap is a 3 x n matrix where cmap(1, :) maps to the lowest
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
% cmqp      Colormap (def: jet(64))
%
% Output:
% col          RGB value of x
% cmap         Colormap
% cbticks      Every possible discrete colorbar tick spanning
%                  entire colormap (linspace(0,1,length(cmap)+1)
% cbticklabels Every possible discrete colorbar tick label which
%                  maps x to cbticks
%
% idx          Index (row) of coloramp: col = cmap(idx, :)
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
%    [col, cmap, cbticks, cbticklabels] = X2COLOR(x, -1, 3.7, jet(100));
%    hold(axes, 'on')
%    for i = 1:length(x)
%        plot(i, x(i), 'o', 'MarkerFaceColor', col(i, :), 'MarkerEdgeColor', col(i, :));
%    end
%    colormap(gca, cmap); axis tight; box on
%    cb = colorbar;
%    cb.Ticks = cbticks(1:20:end);
%    cb.TickLabels = cbticklabels(1:20:end);
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 30-Oct-2019, Version 2017b on MACI64

% Defaults.
defval('xmin', min(x))
defval('xmax', max(x))
defval('cmap', jet(64));

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
cbticklabels = norm2ab(cbticks, xmin, xmax);
