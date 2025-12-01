function scatter_test()
% SCATTER_TEST
%
% Script to relearn for the millionth time how to preallocate a (nan) scatter
% plot and then dynamically change ("turn on") individual points.
%
% Author: Joel D. Simon <jdsimon@bathymetrix.com>
% Last modified: 01-Dec-2025, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

clc
close all

x = 1:100;
y1 = x.^2;
y2 = -y1;

s = linspace(50, 500, length(x));
c = x2color(y1);

figure
box on
hold on
xlim(minmax(x))
ylim(minmax([y1 y2]))

% First generate the scatters with the correct size (N x 1) and color (N x 3)
% data, but with x/y data at NaN. You can later dynamically place those points
% on the plot later.
np = size(x);
sc(1) = scatter(nan(np), nan(np), s, c, 'Filled');
sc(2) = scatter(nan(np), nan(np), s, c, 'Filled');

% Next individually move those already colored points from (nan,nan) to their
% desired (x,y) positions.
for i = 1:numel(x)
    sc(1).XData(i) = x(i);
    sc(1).YData(i) = y1(i);

    sc(2).XData(i) = x(i);
    sc(2).YData(i) = y2(i);

    pause(0.05)

end

% Alternatively, you can also update size and color data later, but you must
% remember to use Nx3 for the color data.
sc(1).YData(50) = 0;
sc(1).SizeData(50) = 1000;

% !!! Important: must declare LHS with CData(N, :) and RHS with (N x 3) !!!
sc(1).CData(50, :) = [1 0 1];
keyboard
