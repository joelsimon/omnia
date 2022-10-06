function [fzlat, fzlon] = fresnelzone(lat1, lon1, lat2, lon2, v, f, npts_gc, npts_fr)
% [fzlat, fzlon] = FRESNELZONE(lat1, lon1, lat2, lon2, v, f, npts_gc, npts_fr)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 05-Oct-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('npts_gc', 100);
defval('npts_fr', 5);

% Compute lat/lon of great circle path between source and reciever.
[gclat, gclon] = track2(lat1, lon1, lat2, lon2, [], [], npts_gc);

% Compute azimuth (degrees) of great circle path from source to reciever.
% Fresnel zone vanishes at source/receiver so azimuth may be neglected.
az(1) = NaN;
for i = 2:length(gclat)-1
    az(i) = azimuth(gclat(i), gclon(i), gclat(i+1), gclon(i+1));

end
az(length(gclat)) = NaN;
az = az';

% Compute total and cumulative distance along great circle path.
[tot_distkm, tot_distdeg] = grcdist([lon1 lat1], [lon2 lat2]);
tot_distm = tot_distkm * 1000;
cum_distm = linspace(0, tot_distm, npts_gc);
cum_distdeg = linspace(0, tot_distdeg, npts_gc);

% Compute fresnel radius (meters) at every point along great circle path.
fr_m = fresnelradius(cum_distm, tot_distm, v, f);
fr_deg = km2deg(fr_m/1000);

% Compute Fresnel zone as radii normal (+/-90 azimuth) to great circle path.
[fzlat_neg, fzlon_neg] = track1(gclat, gclon, az-90, fr_deg, [], [], npts_fr);
[fzlat_pos, fzlon_pos] = track1(gclat, gclon, az+90, fr_deg, [], [], npts_fr);

fzlat = [fzlat_neg fzlat_pos];
fzlon = [fzlon_neg fzlon_pos];

%% ___________________________________________________________________________ %%

close all
figure
plotcont
box on
hold on
plot(longitude360(gclon), gclat)
for i = 1:size(fzlon, 2)
    plot(longitude360(fzlon(:, i)), fzlat(:, i), 'r')

end
