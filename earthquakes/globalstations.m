function [s, f1, f2] = globalstations(redo, plt)
% [s, f1, f2] = GLOBALSTATIONS(redo, plt)
%
% GLOBALSTATIONS queries http://service.iris.edu/fdsnws/station/1/,
% via irisFetch.Stations, the complete (for all time) global list of
% seismic stations.
% 
% Input:
% redo   logical true to resent query and save new file (def: false)
% plt    logical true to plot (def: true)
%
% Output:
% s     Struct of stations returned by irisFetch.Stations
% f1    Labeled map of stations with outlines of coasts
% f2    Unlabeled map of stations
%
% If redo is false GLOBALSTATIONS will look for "globalstations.mat"
% in the same folder where globalstations.m lives.
%
% Ex: GLOBALSTATIONS(false, true)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 25-Feb-2019, Version 2017b

% Defaults.
defval('redo', false)
defval('plt', true)

% The savefile lives in the same folder of this mfilename. 
mfile = which(mfilename);
savefile = strrep(mfile, [mfilename '.m'], [mfilename '.mat']);

if ~redo
    fprintf('\nLoading (large) %s...\n\n', strippath(savefile))
    load(savefile)

else
    % Search from 01-Jan-0000 to current date.
    startDate = datetime('01-Jan-0000');
    endDate = datetime(date);

    % Parameter list available at:
    % http://service.iris.edu/fdsnws/station/1/

    % Fetch and save the data.
    s = irisFetch.Stations('station','*','*','*','*', 'starttime', ...
                           startDate, 'endtime', endDate, 'minlat', - ...
                           90, 'maxlat', 90, 'minlon', -180, 'maxlon', 180);
    save(savefile)

end

if plt
    lon = [s.Longitude];
    lat = [s.Latitude];

    % Figure 2 uses FJS plotcont.m, where longitude goes from 0:360
    % degrees, ergo must add 360 degrees to any negative longitudes.
    lon(find(lon<0)) = lon(find(lon<0)) + 360;
    
    %% Figure 1 does include the background map.


    % longticks(f1.ha, 2)    

    f1.f = figure;
    f1.ha = gca;

    f1.pl = plot(f1.ha, lon, lat, '^', 'MarkerFaceColor', 'blue', ...
                 'MarkerEdgeColor', 'blue', 'MarkerSize', 1);

    hold(f1.ha, 'on')
    plotcont([0 90], [360 -90], 0)

    f1.ha.XLim = [0 360];
    f1.ha.YLim = [-90 90];

    f1.ha.XTick = [0:60:360];
    f1.ha.YTick = [-90:30:90];
    
    xlabel(f1.ha, 'longitude (${}^{\circ}$)')
    ylabel(f1.ha, 'latitude (${}^{\circ}$)')
    
    latimes
    longticks(f1.ha, 2)    
    grid(f1.ha, 'on')
    axesfs(f1.f, 7, 9)


    %% Figure 1 does not include the background map.
    f2.f = figure;
    
    % Copy the figure just made and delete the lines I don't want.
    f2.ha = copyobj(f1.ha, f2.f)

    % Delete the underlying map.
    delete(f2.ha.Children(1))
    
    f2.ha.XTickLabel = {};
    f2.ha.YTickLabel = {};

    delete(f2.ha.XLabel)
    delete(f2.ha.YLabel)

    grid(f2.ha, 'off')

end