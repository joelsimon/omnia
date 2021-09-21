function [ilat, ilon, warn] = interpmerloc(mer_struct, ilocdate, plt)
% [ilat, ilon, warn] = INTERPMERLOC(mer_struct, ilocdate, plt)
%
% Interpolate MERMAID position at requested time.
%
% Inputs:
% mer_struct    Individual-float substruct from readgps
%                   (i.e., gps = readgps; mer_struct = gps.P0008)
% ilocdate      Datetime of requested location interpolation
% plt           true to generate an ugly plot to verify interpolation
%                   seems reasonable (def: false)
%
% Outputs:
% ilat/lon      Interpolated latitude/longitude at requested `ilocdate`
% warn          true if warning thrown (`ilocdate` out of range;
%                   `ilocdate` possibly during surfacing/diving)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 20-Sep-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default input.
defval('plt', false)

% Default outputs.
ilat = [];
ilon = [];
warn = false;
prev_next = [];

% Sanity checks
if ~issorted(mer_struct.locdate)
    error('mer_struct.locdate is not sorted')

end
if ~isbetween(ilocdate, mer_struct.locdate(1), mer_struct.locdate(end))
    warning('requested interpolation date outside measurement dates')
    warn = true;
    return

end

% Remove redundant dates so that interp1.m does not get flustered.
% Don't use rmstructindex.m because we want to return `prev_next` output
% indexed the same as the original input.
[~, uniq_idx] = unique(mer_struct.locdate);
uniq_locdate = mer_struct.locdate(uniq_idx);
uniq_lat = mer_struct.lat(uniq_idx);
uniq_lon = mer_struct.lon(uniq_idx);

% Super simple linear interpolation.
ilat = interp1(uniq_locdate, uniq_lat, ilocdate);
ilon = interp1(uniq_locdate, uniq_lon, ilocdate);

% Warn if previous/next GPS within 5 hours (implying MERMAID at the surface
% or diving/ascending).
prev_idx = max(find(mer_struct.locdate < ilocdate));
next_idx = prev_idx + 1;
if seconds(ilocdate - mer_struct.locdate(prev_idx)) < 15 * 3600 || ...
        seconds(mer_struct.locdate(next_idx) - ilocdate) < 5*3600
    warning('May have been at the surface or diving/ascending at %s', fdsndate2str(ilocdate))
    warn = true;

end

if plt
    % Figure out the cumulative drift days.
    locdate = mer_struct.locdate;
    lat = mer_struct.lat;
    lon = mer_struct.lon;
    cum_days = [0 ; cumsum(days(diff(locdate)))];

    % Remove GPS fixes taken by P0023 while out of water (on the ship).
    % !! NB, don't use option to remove in readgps.m (readgps([], true)
    % !! because that sets NaTs and NaNs which screws up cum funcs;
    % !! use this ad hoc removal.
    if strcmp(mer_struct.source{1}(1:2), '23')
        bad_dates = iso8601str2date({'2019-08-17T03:18:29Z' '2019-08-17T03:22:02Z'});
        [~, rm_idx] = intersect(mer_struct.locdate, bad_dates);
        locdate(rm_idx) = [];
        lat(rm_idx) = [];
        lon(rm_idx) = [];
        cum_days(rm_idx) = [];

    end

    figure
    ax = gca;

    % Figure out color map based on drift duration for scatter plot.
    cmap = jet(length(cum_days));
    colormap(ax, cmap)
    col = x2color(cum_days, [], [], cmap, false);

    % Figure out the color of the interpolated date.
    icum_days = days(ilocdate - locdate(1));
    icol = x2color(icum_days, cum_days(1), cum_days(end), cmap, false);

    % Scatter the measurement data.
    plot(ax, lon, lat, 'k');
    hold(ax, 'on')
    sc = scatter(ax, lon, lat, 75, col, 'Filled', 'MarkerEdgeColor', 'k');

    hold on
    plot(ax, ilon, ilat, 'o', 'Color', icol, 'MarkerFaceColor', icol, ...
         'MarkerSize', 20, 'MarkerEdgeColor', 'k')


    plot(ax, mer_struct.lon(prev_idx), mer_struct.lat(prev_idx), 'kx', 'MarkerSize', 12);
    text(ax, mer_struct.lon(prev_idx), mer_struct.lat(prev_idx), ...
         datestr(mer_struct.locdate(prev_idx)), 'FontSize', 18);

    plot(ax, mer_struct.lon(next_idx), mer_struct.lat(next_idx), 'kx', 'MarkerSize', 12);
    text(ax, mer_struct.lon(next_idx), mer_struct.lat(next_idx), ...
         datestr(mer_struct.locdate(next_idx)), 'FontSize', 18);


    plot(ax, ilon, ilat, 'rx', 'MarkerSize', 12);
    text(ax, ilon, ilat, datestr(ilocdate), 'FontSize', 18)

    latimes
end
