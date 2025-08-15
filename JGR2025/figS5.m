function figS5(kstnm1, kstnm2)
% FIGS5(kstnm1, kstnm2)
%
% Plot near-source bathymetry for GCP to two stations.
%
% Develped as: plot_two_station_source_bathy for Reviewer #1
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 15-Aug-2025, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

clc
close all

defval('kstnm1', 'P0045')
defval('kstnm2', 'H11S1')

ax = gca;

freq = 2.5; % Hz
c = 1480; % m/s
tz_m = -1350; % test elevation, meters
tz_km = tz_m/1e3;

fg1 = hunga_read_fresnelgrid_gebco(kstnm1, freq);
fg2 = hunga_read_fresnelgrid_gebco(kstnm2, freq);

bathy1_km = fg1.depth_m(:, fg1.gcidx) /1e3;
dist1_km = fg1.gcdist_m / 1e3;
bathy2_km = fg2.depth_m(:, fg2.gcidx) /1e3;
dist2_km = fg2.gcdist_m / 1e3;

hold(ax, 'on')
p1 = plot(ax, dist1_km, bathy1_km, '-', 'Color', [0.761, 0.698, 0.502], 'LineWidth', 2);
p2 = plot(ax, dist2_km, bathy2_km, '-', 'Color', [0.545, 0.271, 0.075], 'LineWidth', 2);
pltz = plot(ax, ax.XLim, [tz_km tz_km], 'k');
pltz = plot(ax, ax.XLim, [0 0], 'b--');

ax.XLim = [0 200];
ax.YLim = [-6 0.5];
xlabel('Epicentral Distance [km]')
ylabel('Elevation [km]')

% Adjust vertical exaggeration, holding width constant.
%vertexag(ax, ve, 'height');
%ve_tx = text(ax, 50, -5.5, sprintf('%ix Vertical Exaggeration', ve));
uistack(pltz, 'bottom');
hold(ax, 'off')

box on
longticks([], 2)
latimes2
shrink([], 1, 2)

legend([p1 p2], kstnm1, kstnm2, 'Location', 'SouthWest')

[tt_adj1, p_dist1_m] =  hunga_travtimeadj(kstnm1, c, tz_m);
[tt_adj2, p_dist2_m] =  hunga_travtimeadj(kstnm2, c, tz_m);

tot_dist1_km = dist1_km(end);
tot_dist2_km = dist2_km(end);

p_dist1_km = p_dist1_m / 1e3;
p_dist2_km = p_dist2_m / 1e3;

t_dist1_km = tot_dist1_km - p_dist1_km;
t_dist2_km = tot_dist2_km - p_dist2_km;

p_time1 = p_dist1_km / 5.8;
p_time2 = p_dist2_km / 5.8;

t_time1 = t_dist1_km / 1.48;
t_time2 = t_dist2_km / 1.48;


tdiff1 = (tot_dist1_km / 1.48) - (p_time1 + t_time1);
tdiff2 = (tot_dist2_km / 1.48) - (p_time2 + t_time2);

fprintf('Total distance to %s: %.1f km\n', kstnm1, tot_dist1_km);
fprintf('Total distance to %s: %.1f km\n\n', kstnm2, tot_dist2_km);

fprintf('%s:\n', kstnm1)
fprintf('Travel time for T wave (%.1f km): %.1f s\n', ...
        tot_dist1_km, tot_dist1_km / 1.48);
fprintf('Travel time for P wave (%.1f km) then T wave (%.1f km): %.1f\n', ...
        p_dist1_km, t_dist1_km, p_time1 + t_time1);
fprintf('Time difference between one- and two-leg: %.1f\n\n', tdiff1);

fprintf('%s:\n', kstnm2)
fprintf('Travel time for T wave (%.1f km): %.1f s\n', ...
        tot_dist2_km, tot_dist2_km / 1.48);
fprintf('Travel time for P wave (%.1f km) then T wave (%.1f km): %.1f\n', ...
        p_dist2_km, t_dist2_km, p_time2 + t_time2);
fprintf('Time difference between one- and two-leg: %.1f\n\n', tdiff2);

fprintf('Time shift of %s relative to %s if both two-leg: %.1f\n', kstnm2, ...
        kstnm1, tdiff2 - tdiff1);

% This is confirmed by travtimeadj.
fprintf('(confirmation) hunga_travtimeadj difference: %.1f s\n', tt_adj2 - tt_adj1)