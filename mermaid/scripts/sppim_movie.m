function sppim_movie
% Author: Joel D. Simon <jdsimon@bathymetrix.com>
% Last modified: 19-Nov-2025, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

clc
close all

procdir = fullfile(getenv('MERMAID'), 'processed_everyone');

gps = readgps(procdir, false);
mermaids = fieldnames(gps);

empties = {};
dates = [];
max_deploy_duration = 0;
for i = 1:length(mermaids)
    g = gps.(mermaids{i});
    g.date = dateshift(g.date, 'start', 'day');

    if isempty(g.date)
        empties = [empties ; mermaids{i}];
        continue

    end

    bad_dates = g.date < datetime('2018-06-10', 'TimeZone', 'UTC') | g.date > datetime('now', 'TimeZone', 'UTC');
    g = structfun(@(xx) xx(~bad_dates), g, 'UniformOutput', false);

    deploy_duration = g.date(end) - g.date(1);
    if deploy_duration > max_deploy_duration
        max_deploy_duration = deploy_duration;

    end

    dates = [dates; g.date];
    gps.(mermaids{i}) = g;

end
dates = unique(dates);
gps = rmfield(gps, empties);
mermaids = fieldnames(gps);

F = plotgebcopacific;
ax = gca;
hold(ax, 'on')

box on
xlim([160 270])
ylim([-40 10])
xlabel('Longitude')
ylabel('Latitude')
set(ax, 'XTickLabels', degrees2(ax.XTick))
set(ax, 'YTickLabels', degrees2(ax.YTick))
F.cb.TickLength = 0.02;
F.cb.TickDirection = 'out';

longticks([], 2)
latimes2


%% Pull in Crameri's colormaps so that I can use crameri.m
cmap = 'acton';
cpath = fullfile(getenv('PROGRAMS'), 'crameri');
addpath(cpath);
cmap = crameri(cmap);
% %% Pull in Crameri's colormaps so that I can use crameri.m

% Generate secondary invisible axis just to hold the drift-time colorbar.
cbax = axes;
colormap(cbax, cmap);
cb = colorbar(cbax, 'SouthOutside');
cb.Position(1) = ax.Position(1);
cb.Position(2) = 0.16;
cb.Position(3) = ax.Position(3);
cbax.Visible = 'off';

max_deploy_days = days(max_deploy_duration);
max_deploy_years = max_deploy_days/365;
last_tick_lab = floor(max_deploy_years);
last_tick_loc = last_tick_lab / max_deploy_years;
tick_loc = linspace(0, last_tick_loc, last_tick_lab + 1);
tick_lab = 0:last_tick_lab;
cb.Ticks = tick_loc;
cb.TickLabels = tick_lab;
cb.Label.String = 'Years Deployed [Per Float]';
cb.TickDirection = 'out';
cb.TickLength = 0.01;

axes(ax)
sc = gobjects(size(mermaids));
for i = 1:length(mermaids)
    d = gps.(mermaids{i}).date;
    col = x2color(days(d - d(1)), 0, max_deploy_days, cmap);
    np = length(d);
    sc(i) = scatter(nan(1, np), nan(1, np), 5, col, 'Filled', 'MarkerEdgeColor', 'None');

end

vname = mfilename;
vwriter = VideoWriter(vname, 'MPEG-4');
open(vwriter);

for j = 1:length(dates)
    d = dates(j);

    for i = 1:length(mermaids)
        g = gps.(mermaids{i});
        idx = g.date == d;
        if any(idx)
            sc(i).XData(j) = mean(longitude360(g.lon(idx)));
            sc(i).YData(j) = mean(g.lat(idx));

        end
    end
    title(datestr(d, 'mmmm YYYY'), 'FontWeight', 'Normal');
    drawnow
    writeVideo(vwriter, getframe(gcf));

end
close(vwriter)
fprintf('Wrote %s\n', vname)
