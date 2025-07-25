function dive3d(geocsv)
% DIVE3D(geocsv)
%
% WIP: Generate movie of 3-D dive trajectory from GeoCSV file.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 25-Jul-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

clc
close all

G = readGeoCSV(geocsv);

lon = longitude360(G.Longitude);
lat = G.Latitude;
depth = -G.WaterPressure/100;
lon_lim = [floor(min(lon))-1 ceil(max(lon))+1];
lat_lim = [floor(min(lat))-1 ceil(max(lat))+1];

lon = interpo(lon);
lat = interpo(lat);
depth = interpo(depth);

ax = axes;
latimes

years_deployed = years(G.StartTime - G.StartTime(1));
years_lim = [0:floor(max(years_deployed))];

cmap = turbo;
colormap(ax, cmap)
[col, cbticks, cbticklabels] = x2color(years_deployed, [], [], cmap, false);

cb = colorbar;
ticks2keep = nearestidx([cbticklabels{:}], years_lim);

cb.Ticks = cbticks(ticks2keep);
cb.TickLabels = num2cell(years_lim);
cb.Label.Interpreter = 'latex';
cb.Label.String = 'Years Deployed';
cb.TickDirection = 'out';

hold(ax, 'on')
ax.View = [-10 15];
av1 = ax.View(1);
xlabel('Longitude (degrees)')
ylabel('Latitude (degrees)')
zlabel('Depth (m)')

xlim(ax, lon_lim);
ylim(ax, lat_lim);
zlim(ax, [-2000 0]);

box on
grid on

fr = 10;
fname = sprintf('%s_%s', mfilename('fullpath'), G.Station{1});
vid = VideoWriter(fname, 'MPEG-4');
vid.FrameRate = 10;
open(vid)
fprintf('Wrote: %s\n', fname)

int = 100;
for i=1+int:int:length(lon)
    idx = i - int;
    plot3(ax, lon(idx:i), lat(idx:i), depth(idx:i), 'Color', col(i,:), ...
          'LineWidth', 3);
    plot(ax, lon(idx:i), lat(idx:i), 'Color', 'black', ...
          'LineWidth', 1)
    pause(0.1)
    frame = getframe(gcf);
    writeVideo(vid, frame);

end

paws = 0.05;
for i = ax.View(1):1:0
    ax.View(1) = i;
    pause(paws)
    frame = getframe(gcf);
    writeVideo(vid, frame);

end

% pause for 2 seconds at 90 degrees (map view)
for i = [ax.View(2):89 repmat(90, [1 2/paws]) 89:-1:5]
    ax.View(2) = i;
    pause(paws)
    frame = getframe(gcf);
    writeVideo(vid, frame);

end

for i = ax.View(1):360+av1
    ax.View(1) = i;
    pause(paws)
    frame = getframe(gcf);
    writeVideo(vid, frame);

end
close(vid)

%% ___________________________________________________________________________ %%

function x = interpo(x)
nidx = isnan(x);
N = 1:length(x);
x(nidx) = interp1(N(~nidx), x(~nidx), N(nidx));
