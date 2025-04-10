function fig9ab
% FIG9AB
%
% Panel A and B of Figure 9: Bathymetric cross section and map for H11S3.
%
% Part of three panel: bathymetric PROFile; BATHymetric map; occlusion-count
% SCHEMatic.
%
% See fig9c.m (developed as hunga_schematic2.m) to finish.
%
% Developed as: hunga_profbathschem.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 26-Mar-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

clc
close all

kstnm = 'H11S3';

cmap = 'turbo';
lw = 2;
cn_lw = 1.5;

alt_cmap = true;

% Test elevation
tz_m = -1350
tz_km = -1350/1e3;

% Vertical exaggeration.
ve = 125;

%ax = krijetem(subnum(3,1));
ax = krijetem(subnum(2,1));
box(ax, 'on')
f = gcf;
fig2print(f, 'fportrait');
f.InnerPosition(3) = f.InnerPosition(4); % for `vertexag`
longticks(ax, 3)
shrink(ax, 0.9, 3);

%% ___________________________________________________________________________ %%
%% ax(1): Bathymetric Profile (cross-sectional view)
axes(ax(1))
fg = hunga_read_fresnelgrid_gebco(kstnm, 2.5);

% Along each Fresnel-radii compute the min/max elevation to bracket GEBCO
% great-circle elevation track.  Take min/max along rows of Fresnel-zone
% elevation matrix (each lat/lon point).
min_bathy_km = min(fg.depth_m, [], 2) / 1e3;
gc_bathy_km = fg.depth_m(:, fg.gcidx) /1e3;
max_bathy_km = max(fg.depth_m, [], 2) / 1e3;
dist_km = fg.gcdist_m / 1e3;

hold('on')
pp = patch([dist_km ; flip(dist_km)], [min_bathy_km ; flip(max_bathy_km)], [0.6 0.6 0.6]);
pp.EdgeColor = 'none';
pp.LineWidth = 0.25;
plot(dist_km, gc_bathy_km, '-', 'Color', 'r', 'LineWidth', 1);
pltz = plot(ax(1).XLim, [tz_km tz_km], 'k');

hold('off')

ax(1).XLim = [0 dist_km(end)];
ax(1).YLim = [-6 0.5];
ylabel('Elevation [km]')
ax(1).XTickLabel = [];

% Adjust vertical exaggeration, holding width constant.
vertexag(ax(1), ve, 'height');
kstnm_tx1 = text(ax(1), 50, -4, sprintf('%s', kstnm));
cross_tx = text(ax(1), 50, -4.75, 'Cross-Sectional View');
ve_tx = text(ax(1), 50, -5.5, sprintf('%ix Vertical Exaggeration', ve));

uistack(pltz, 'bottom');

%% ___________________________________________________________________________ %%
%% ax(2): Bathymetric Colormap (bird's-eye view)
axes(ax(2));

% Get x/y mesh for bathy image.
im_xl = dist_km;
im_yl = linspace(-max(fg.radius_m)/1e3, max(fg.radius_m)/1e3, size(fg.depth_m,2));

% Chop off first/last handful of pixels at source/receiver of bathymetric image
% so that image doesn't override edge of axes and make line seem thinner; don't
% have to worry about y axis because can just expand limits beyond max Fresnel
% zone (don't want to extend x limits, though).
im_xl(1:10) = [];
im_xl(end-10:end) = [];
bathy = fg.depth_m';
bathy(:, 1:10) = [];
bathy(:, end-10:end) = [];

hold(ax(2), 'on')
im = imagesc(ax(2), im_xl, im_yl, bathy/1e3, 'AlphaData', ~isnan(bathy));

cax = [-6 0];
caxis(cax);
colormap(cmap)
cb = colorbar;

cb.Location = 'SouthOutside';
cb.Label.String = 'GEBCO Elevation [km]';
cb.Label.Interpreter = 'tex';
cb.Label.FontName = 'times'
cb.Label.FontSize = 11;
cb.Limits = [cax(1) 0];
cb.Ticks = [-6:-2 tz_km -1:0]
cb.TickDirection = 'out';

% Get mesh from image, to overlay contour
[cn_x, cn_y] = im2mesh(im);
[~, cn] = contour(ax(2), cn_x, cn_y, bathy, [tz_m tz_m]);
cn.EdgeColor = 'black';
cn.LineWidth = cn_lw;

%ax(2).YDir = 'normal';
ax(2).YLim = [floor(ax(2).YLim(1)) ceil(ax(2).YLim(2))];
yticklabels(abs(ax(2).YTick))
ylabel(ax(2), 'Distance From GCP [km]')
xlabel(ax(2), 'Distance From Source [km]')

% Annotation/hightlight like schematic
plot(ax(2).XLim, [0 0], 'r', 'LineWidth', lw);

kstnm_tx2 = text(ax(2), 50, -18, sprintf('%s', kstnm));
map_tx = text(50, -24, 'Map View');


plfr061 = plot(ax(2), dist_km, +0.6*fg.radius_m/1e3, 'Color', 'm', 'LineWidth', lw);
plfr062 = plot(ax(2), dist_km, -0.6*fg.radius_m/1e3, 'Color', 'm', 'LineWidth', lw);

plfr1 = plot(dist_km, +fg.radius_m/1e3, 'b', 'LineWidth', lw);
plfr2 = plot(dist_km, -fg.radius_m/1e3, 'b', 'LineWidth', lw);

%% Final cosmetics.
%% ___________________________________________________________________________ %%

ax(2).XLim = ax(1).XLim;

ax(2).Position(3:4) = ax(1).Position(3:4);
ax(2).Position(2) = 0.53;
cb.Position(2) = .45;

ax(1).YLabel.Position(1) = -225;
ax(2).YLabel.Position(1) = ax(1).YLabel.Position(1);

latimes2
axesfs(f, 12, 12)

lbA = text(ax(1), 60, -0.1, 'A', 'FontName', 'Helvetica', 'FontWeight',  'Bold', 'FontSize', 12);
lbB = text(ax(2), 60, 23, 'B', 'FontName', 'Helvetica', 'FontWeight',  'Bold', 'FontSize', 12);

savepdf(mfilename)
