function [fzlat, fzlon, gclat, gclon, fr, gcidx] = ...
    fresnelgrid(lat1, lon1, lat2, lon2, v, f, res_m, plt)
% [fzlat, fzlon, gclat, gclon, fr, gcidx] = FRESNELGRID(lat1, lon1, lat2, lon2, v, f, res_m, plt)
%
% Compute 2-D (lat/lon only; map view, no depth) Fresnel-zone tracks (like
% great-circle tracks) for constant-velocity waves (e.g., surface or T waves) on
% equally spaced grid.
% 
% Like fresnelzone.m, but with geographically equally spaced sampling along each
% Fresnel radii, as opposed to equal number of samples regardless of radii
% length, as is done there.
%
% Input:
% lat1/lon1        Latitude and longitude of source [deg]
% lat2/lon2        Latitude and longitude of receiver [deg]
% v                Wave velocity [m/s]
% f                Wave frequency [Hz]
% res_m            Square-grid resolution [m]
% plt              true to plot output (def: false)
%
% Output:
% fzlat**          Latitude of Fresnel-zone tracks [deg]
% fzlon**          Longitude of Fresnel-zone tracks [deg]
% gclat            Latitude of great-circle tracks [deg]
% gclon            Longitude of great-circle tracks [deg]
% fr               Fresnel radius at every point along great circle [deg]
% gcidx            Column index of great-circle track (in middle all all tracks)
%                  e.g., gclat = fzlat(:, gcidx);
%                        gclon = fzlat(:, gclon)
%
% Ex: (20 s surface wave emanating from Hung-Tonga recorded at MH.N0005,
%      with grid spacing equal to 1/10 wavelength)
%    lat1=-20.546; lon1=-175.390; lat2=-11.809; lon2=-144.310;
%    v=3500; f=1/20; lambda=v/f; res_m=lambda/10;
%    FRESNELGRID(lat1, lon1, lat2, lon2, v, f, res_m, true)
%
% See also: fresnelzone.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 05-Mar-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default.
defval('plt', false)

% Compute great circle (epicentral distance) length.
gc_tot_dist_m = deg2km(distance(lat1, lon1, lat2, lon2)) * 1000;

% Determine number of Fresnel radii based on requested grid resolution.
num_fr = ceil(gc_tot_dist_m / res_m);

% Compute lat/lon of great circle path between source and receiver.
[gclat, gclon] = track2(lat1, lon1, lat2, lon2, [], [], num_fr);

% Compute maximum Fresnel radius, at middle of great-circle path.
fr_max_m = fresnelmax(v, f, gc_tot_dist_m);
fr_max_deg = km2deg(fr_max_m / 1000);

% Array specifying the total distance in meters from great-circle path along
% the Fresnel-radii (perpendicular)
npts_fr = ceil(fr_max_m / res_m);
fr_cum_dist_m = linspace(0, fr_max_m, npts_fr);

gc_cum_dist_m = deg2km(cumdist(gclat, gclon)) * 1000;
gc_cum_dist_m(end) = gc_tot_dist_m;
fr_m = fresnelradius(gc_cum_dist_m, gc_tot_dist_m, v, f);

% Compute azimuth (degrees) at every point along great circle path.  Each
% Fresnel radii will be oriented normal to the instantaneous azimuth at that
% point (picture a fish spine).
for i = 1:num_fr-1
    az(i) = azimuth(gclat(i), gclon(i), gclat(i+1), gclon(i+1));

end
az = az';

% For final azimuth (last point on great circle path), compute back azimuth and
% then convert that to an azimuth by taking the back azimuth (back azimuth of a
% back azimuth is an azimuth, right?)
%
% https://www.nwcg.gov/course/ffm/location/63-back-azimuth-and-backsighting
% "A back azimuth is calculated by adding 180 [deg] to the azimuth when the
%  azimuth is less than 180 [deg], or by subtracting 180 [deg] from the azimuth
%  if it is more than 180 [deg]."
baz = azimuth(gclat(num_fr), gclon(num_fr), gclat(num_fr-1), gclon(num_fr-1));
if baz < 180
    az(num_fr) = baz + 180;

else
    az(num_fr) = baz - 180;

end

% Generate lat/lon grid given requested grid resolution. At each point along
% great circle path a positive and negative spoke of maximum Fresnel-radii is
% projected normal to great circle path.  E.g., if great-circle path is roughly
% E-W this grid forms a rectangle with length equal to great-circle path and N-S
% height double the maximum Fresnel radii. This is the "raw" grid with all
% lat/lon present, before setting to NaN those indices which are outside
% (further from great-circle path) Fresnel radii.
[fzlat_neg, fzlon_neg] = track1(gclat, gclon, az-90, repmat(fr_max_deg, size(gclat)), [], [], npts_fr);
[fzlat_pos, fzlon_pos] = track1(gclat, gclon, az+90, repmat(fr_max_deg, size(gclat)), [], [], npts_fr);

% Loop over all Fresnel radii (e.g., moving from E (left) to W (right) in
% example) along great-circle path and set to NaN all points in raw lat/lon grid
% which are further away from great-circle path than specified Fresnel radii
% length at that point in the path.  Skip setting to NaN the middle radii (one
% or two indices), which may otherwise have their final lat/lon set to NaN due
% to rounding errors (we know the middle of the great-circle path must have the
% max Fresnel radius).  This loops over the whole path, and NaNs out positive
% and negative radii. I could be more clever and go to middle of path (maximum
% radius) and mirror indices.
mid_idx = mididx(1:num_fr);
for i = 1:num_fr
    % Out of the Fresnel zone
    if any(i==mid_idx)
        continue

    end

    out_idx = find(fr_cum_dist_m > fr_m(i), 1);

    fzlat_neg(out_idx:end, i) = NaN;
    fzlon_neg(out_idx:end, i) = NaN;

    fzlat_pos(out_idx:end, i) = NaN;
    fzlon_pos(out_idx:end, i) = NaN;


end

% The first point along each pos/neg Fresnel radius is on great circle itself;
% cut it.  E.g., the positive track starts on great circle and tracks north/east
% the specific Fresnel radius.
fzlat_neg(1, :) = [];
fzlon_neg(1, :) = [];
fzlat_pos(1, :) = [];
fzlon_pos(1, :) = [];

% At this point the columns define the Fresnel radius tracks (normal to great
% circle) and the rows define the Fresnel-zone tracks (adjacent to great
% circle). Flip left-right the negative lat/lon so that shape of matrix mirrors
% shape of Fresnel zone (with NaNs). Transpose and concatenate pos/neg radius
% tracks so that columns of the output define Fresnel-zone tracks.  Slot
% great-circle latitudes and longitudes (multiply repeated and cut above) in
% middle of positive and negative tracks.
fzlat = [fliplr(fzlat_neg') gclat fzlat_pos'];
fzlon = [fliplr(fzlon_neg') gclon fzlon_pos'];

% Return index (middle of tracks) of column representing great-circle track.
gcidx = size(fzlat_neg', 2) + 1;

%% ___________________________________________________________________________ %%

if plt
    % Toggle big on or off to swap basemap
    big = false;

    figure
    if big
        plotgebcopacific

    else
        plotcont
        box on

    end
    xlim([120 300])
    ylim([-60 80])

    hold on

    % Plot Fresnel-zone tracks; COLUMNS of output.
    for i = 1:size(fzlon, 2);
        fz_track =  plot(longitude360(fzlon(:, i)), fzlat(:, i), 'b');

    end

    % Plot (again, redundantly for color) great-circle track, which should fall in middle.
    gc_track = plot(longitude360(fzlon(:, gcidx)), fzlat(:, gcidx), 'r');

    % Plot Fresnel radii; ROWS of output
    for i = 1:size(fzlon, 1);
        fz_radius = plot(longitude360(fzlon(i, :)), fzlat(i, :), 'k-o');

    end

    legend([gc_track fz_track fz_radius], 'Great-Circle Track', ...
           'Fresnel Tracks', 'Fresnel Radii');
    hold off
    axesfs([], 10, 10)
    latimes2

end
