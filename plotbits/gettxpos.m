function pos = gettxpos(tx)
% pos = GETTXPOS(tx)
%
% Return `text` object position in matrix.
%
% Useful to get (and save, for later loading) of, e.g., labels in a figure that
% have been manually adjusted.
%
% Input:
% tx      Array of text objects
%
% Output:
% pos     Mx3 array of positions of text objects
%
%
% Ex:
%    plot(1:10)
%    tx(1) = text(ax, randi(10,1), randi(10,1), 'hello')
%    tx(2) = text(ax, randi(10,1), randi(10,1), 'world')
%    pos = GETTXPOS(tx)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 25-Jul-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

lx = length(tx);
pos = zeros(lx, 3);
for i = 1:lx
    pos(i, :) = tx(i).Position;

end
