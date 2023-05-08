function dive3d
% WIP: Generate movie of 3-D dive trajectory from GeoCSV file.

clc
close all

load '~/Desktop/P0006_GeoCSV.mat';

lon = longitude360(G.Longitude);
lat = G.Latitude;
depth = -G.WaterPressure/100;

lon = interpo(lon);
lat = interpo(lat);
depth = interpo(depth);

ax = axes;
latimes

years_deployed = years(G.StartTime - G.StartTime(1));
cmap = jet;
colormap(ax, cmap)
[col, cbticks, cbticklabels] = x2color(years_deployed, [], [], cmap, false);

cb = colorbar;
ticks2keep = nearestidx([cbticklabels{:}], [0:0.5:4.5]);

cb.Ticks = cbticks(ticks2keep);
cb.TickLabels = num2cell([0:0.5:4.5]);
cb.Label.Interpreter = 'latex';
cb.Label.String = 'Years Deployed';
cb.TickDirection = 'out';

hold(ax, 'on')
ax.View = [-10 15];
av1 = ax.View(1);
xlabel('Longitude (degrees)')
ylabel('Latitude (degrees)')
zlabel('Depth (m)')

xlim(ax, [172 183]);
ylim(ax, [-17 -11]);
zlim(ax, [-2000 0]);

box on
grid on

fr = 10;
vid = VideoWriter('vidFile', 'MPEG-4');
vid.FrameRate = 10;
open(vid)

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
