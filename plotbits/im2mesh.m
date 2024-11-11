function [X, Y, XX, YY] = im2mesh(im);
% [X, Y, XX, YY] = IM2MESH(im)
%
% Convert x,y data embedded in image to X,Y mesh.
%
% Input:
% im       Image handle
%
% Output:
% X        X vector (sufficient for, e.g., contour)
% Y        Y vector (sufficient for, e.g., contour)
% XX       X mesh
% YY       Y mesh
%
% Ex: (draw rough contours around coins)
%    im = image(imread('coins.png')); colorbar;
%    [X, Y] = IM2MESH(im); hold on
%    [~, cn] = contour(X, Y, im.CData, [100 100]);
%    set(cn, 'EdgeColor', 'red', 'LineWidth', 2);
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 11-Nov-2024, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

X = linspace(im.XData(1), im.XData(end), size(im.CData, 2));
Y = linspace(im.YData(1), im.YData(end), size(im.CData, 1));
[XX, YY] = meshgrid(X, Y);
