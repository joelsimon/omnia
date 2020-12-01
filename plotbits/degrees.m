function C = degrees(x)
% C = DEGREES(x)
%
% Converts an input DOUBLE array to a cell array of strings with
% LaTeX degree symbols attached, useful for annotating maps.
%
% Input:
% x        Double (not cell) array
%
% Output:
% C        Cell array with LaTeX degree symbols
%
% Ex: (latitude from 5 S to 5 N; longitude from 175 E 175 W)
%    plot(0:10); xlabel('Longitude'); ylabel('Latitude'); ax = gca;
%    lat = [-5:5]
%    lon = [175 176 177 178 179 180 -179 -178 -177 -176 -175]
%    set(ax, 'YTickLabels', DEGREES(lat))
%    set(ax, 'XTickLabels', DEGREES(lon))
%    latimes
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 01-Dec-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

C = compose('%d', x);
C = cellfun(@(xx) [xx '$^{\circ}$'], C, 'UniformOutput', false);
