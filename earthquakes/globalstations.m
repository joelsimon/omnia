function [s, f1, f2, f3] = globalstations(redo, plt, nearbybox)
% [s, f1, f2, f3] = GLOBALSTATIONS(redo, plt, nearbybox)
%
% GLOBALSTATIONS queries http://service.iris.edu/fdsnws/station/1/,
% via irisFetch.Stations, the complete (for all time) global list of
% seismic stations.
%
% Input:
% redo      logical true to resent query and save new file (def: false)
% plt       logical true to plot (def: true)
% nearbybox logical true to plot bounding box used for "nearby" stations search in paper20??
%               (def: true)
%
% Output:
% s         Struct of stations returned by irisFetch.Stations
% f1        Labeled map of stations with outlines of coasts
% f2        f1, with most recently-reported MERMAID locations also plotted
% f3        Unlabeled map of stations
%
% If redo is false GLOBALSTATIONS will look for "globalstations.mat"
% in the same folder where globalstations.m lives.
%
% Ex: GLOBALSTATIONS(false, true)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 02-Mar-2020, Version 2017b on GLNXA64

% Defaults.
defval('redo', false)
defval('plt', true)
defval('nearbybox', 'true')
f1 = [];
f2 = [];
f3 = [];

% The savefile lives in the same folder of this mfilename.
mfile = which(mfilename);
savefile = strrep(mfile, [mfilename '.m'], [mfilename '.mat']);

if ~redo
    fprintf('\nLoading (large) %s...\n\n', strippath(savefile))
    load(savefile, 's')

else
    % Search from 01-Jan-0000 to the present time.
    startDate = '0000-01-01 00:00:00.000';
    endDate = irisdate2str(datetime('now'));

    % Parameter list available at:
    % http://service.iris.edu/fdsnws/station/1/

    % Fetch and save the data.
    s = irisFetch.Stations('station','*','*','*','*', 'starttime', ...
                           startDate, 'endtime', endDate, 'minlat', ...
                           - 90, 'maxlat', 90, 'minlon', -180, ...
                           'maxlon', 180, 'includerestricted', true);
    save(savefile)

end

if plt
    lon = [s.Longitude];
    lat = [s.Latitude];

    % Figure 1 uses FJS plotcont.m, where longitude goes from 0:360
    % degrees, ergo must add 360 degrees to any negative longitudes.
    lon(find(lon<0)) = lon(find(lon<0)) + 360;

    %% Figure 1 does include the background map.
    f1.f = figure;
    f1.ha = gca;

    f1.pl = plot(f1.ha, lon, lat, 'v', 'MarkerFaceColor', 'blue', ...
                 'MarkerEdgeColor', 'blue', 'MarkerSize', 1);

    hold(f1.ha, 'on')
    plotcont([0 90], [360 -90], 0)

    f1.ha.XLim = [0 360];
    f1.ha.YLim = [-90 90];

    f1.ha.XTick = [0:60:360];
    f1.ha.YTick = [-90:30:90];

    set(f1.ha, 'XTickLabels', {'0$^{\circ}$' '60$^{\circ}$E' ...
                        '120$^{\circ}$E' '180$^{\circ}$' '120$^{\circ}$W' ...
                        '60$^{\circ}$W' '0$^{\circ}$'})
    set(f1.ha, 'YTickLabels', {'90$^{\circ}$S' '60$^{\circ}$S' ...
                        '30$^{\circ}$S' '0$^{\circ}$' '30$^{\circ}$N' ...
                        '60$^{\circ}$N' '90$^{\circ}$N'})

    xlabel(f1.ha, 'Longitude');
    ylabel(f1.ha, 'Latitude');

    latimes
    longticks(f1.ha, 2)
    grid(f1.ha, 'on')
    axesfs(f1.f, 7, 9)

    savepdf('globalstations_f1')

    %% Figure 2 does include the background map, and the most recently
    %% reported MERMAID locations.
    f2.f = figure;

    % Copy the figure just made.
    f2.ha = copyobj(f1.ha, f2.f)

    % Fetch the most recent MERMAID locations.
    str = webread('http://geoweb.princeton.edu/people/simons/SOM/all.txt');

    % Split the text at newline characters and ditch the final (empty) string cell.
    str = splitlines(str);
    str = str(1:end-1);
    str = sort(str);

    % Assuming this file is sorted
    P008_idx = cellstrfind(str, 'P008')'
    P025_idx = cellstrfind(str, 'P025')'

    Princeton_idx = P008_idx:P025_idx;
    all_idx = 1:length(str);

    other_idx = setdiff(all_idx, Princeton_idx);

    mlat = cellfun(@(xx) str2double(xx(31:40)), str);
    mlon = cellfun(@(xx) str2double(xx(43:53)), str);

    % Again, map longitudes to plotcont.m convention.
    mlon(find(mlon<0)) = mlon(find(mlon<0)) + 360;


    hold(f2.ha, 'on')
    if nearbybox
        f2.pl_left = plot(f2.ha, [176 176], [4 -33], 'k', 'LineWidth', 1);
        f2.pl_right = plot(f2.ha, [251 251], [4 -33], 'k', 'LineWidth', 1);
        f2.pl_top = plot(f2.ha, [176 251], [4 4], 'k', 'LineWidth', 1);
        f2.pl_bottom = plot(f2.ha, [176 251], [-33 -33], 'k', 'LineWidth', 1);
        botz([f2.pl_left f2.pl_right f2.pl_top f2.pl_bottom]);

    end

    f2.pl_other = plot(f2.ha, mlon(other_idx), mlat(other_idx), ...
                       'v', 'MarkerFaceColor', [0.6 0.6 0.6], 'MarkerEdgeColor', ...
                       'k', 'MarkerSize', 5);
    f2.pl_Princeton = plot(f2.ha, mlon(Princeton_idx), mlat(Princeton_idx), ...
                           'v', 'MarkerFaceColor', [1 0.5 0]', 'MarkerEdgeColor', ...
                           'k', 'MarkerSize', 6);

    topz([f2.pl_other f2.pl_Princeton])

    hold(f2.ha, 'off')
    axesfs(f2.f, 7, 9)
    savepdf('globalstations_f2')

    %% Figure 3 does NOT include the background map.
    f3.f = figure;

    % Copy the first figure.
    f3.ha = copyobj(f1.ha, f3.f)

    % Delete the underlying map.
    delete(f3.ha.Children(1))

    f3.ha.XTickLabel = {};
    f3.ha.YTickLabel = {};

    delete(f3.ha.XLabel)
    delete(f3.ha.YLabel)

    grid(f3.ha, 'off')
    %    axesfs(f1.f, 7, 9)
    savepdf('globalstations_f3')

end
