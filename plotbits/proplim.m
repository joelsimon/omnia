function xy = proplim(ax, prop)
% xy = PROPLIM(ax,prop)
%
% Returns x/ylim value at requested proportion of x/ylim.
%
% Input:
% ax      Axis handle (def: gca)
% prop    1x2 array of requested proportion into [x y] axes
%
% Output:
% xy     [x y] at requested proportions
%
% Ex:
%     plot(-10:10, -10:10); xlim([-10 10]); ylim([-10 10]); ax = gca;
%     hold(ax, 'on'); plot([0 0], ylim, 'k--'); plot(xlim, [0 0], 'k--')
%     ul = PROPLIM(ax, [0.1 0.9]); text(ul(1), ul(2), 'UL', 'FontSize', 20)
%     ur = PROPLIM(ax, [0.9 0.9]); text(ur(1), ur(2), 'UR', 'FontSize', 20)
%     lr = PROPLIM(ax, [0.9 0.1]); text(lr(1), lr(2), 'LR', 'FontSize', 20)
%     ll = PROPLIM(ax, [0.1 0.1]); text(ll(1), ll(2), 'LL', 'FontSize', 20)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 17-Jul-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

defval('ax', 'gca')

if any(prop < 0) || any(prop > 1)
    error('`prop` must be within [0:1], inclusive')

end

x = getval(ax, 'x', prop(1));
y = getval(ax, 'y', prop(2));

xy = [x y];

function val = getval(ax, xory, prop)

switch lower(xory)
  case 'x'
    lim = xlim;

  case 'y'
    lim = ylim;

end

p1 = lim(1);
r1 = range(lim);
val = p1 + (prop * r1);
