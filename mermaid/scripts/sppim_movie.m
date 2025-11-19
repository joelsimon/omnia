function sppim_movie

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

f = figure
plotcont
box on
xlim([160 272])
ylim([-45 10])
hold on
latimes2

cmap = turbo;
colormap(cmap)
colorbar

sc = gobjects(size(mermaids));
for i = 1:length(mermaids)
    d = gps.(mermaids{i}).date;
    col = x2color(days(d - d(1)), 0, days(max_deploy_duration));
    np = length(d);
    sc(i) = scatter(nan(1, np), nan(1, np), 5, col, 'Filled', 'MarkerEdgeColor', 'None');

end

vwriter = VideoWriter(mfilename, 'MPEG-4');
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
    title(datestr(d));
    drawnow
    writeVideo(vwriter, getframe(f));

end
close(vwriter)
fprintf('Wrote %s\n', vname)
