function [fzlat, fzlon, gclat, gclon, fr, gcidx] = ...
    fresnelzone(lat1, lon1, lat2, lon2, v, f, num_fr, npts_fr, plt)
% [fzlat, fzlon, gclat, gclon, fr, gcidx] = ...
%     FRESNELZONE(lat1, lon1, lat2, lon2, v, f, num_fr, npts_fr, plt)
%
% Compute 2-D (lat/lon only; map view, no depth) Fresnel-zone tracks (like
% great-circle tracks) for constant-velocity waves (e.g., surface or T waves).
%
% Input:
% lat1/lon1        Latitude and longitude of source [deg]
% lat2/lon2        Latitude and longitude of receiver [deg]
% v                Wave velocity [m/s]
% f                Wave frequency [Hz]
% num_fr           Number of Fresnel radii to compute along great-circle
%                      path (def: 100)
% npts_fr*         Number of points along each Fresnel radii, each of which
%                      are perpendicular to great-circle path (def: `num_fr`)
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
% *Total number of Fresnel tracks returned is 2*npts_fr+1, where half are
%  relatively "negative" south/west and half are relatively "positive"
%  north/east of great-circle track in the middle.
%
% **Columns define Fresnel-zone tracks, adjacent to great-circle track.
%   Rows define Fresnel zone radii, normal to great-circle track.
%
% Ex: 20 s surface wave emanating from Hung-Tonga recorded at MH.N0005
%    lat1=-20.546; lon1=-175.390; lat2=-11.809; lon2=-144.310;
%    v=3500; f=1/20; num_fr=100; npts_fr=5; plt=true;
%    FRESNELZONE(lat1, lon1, lat2, lon2, v, f, num_fr, npts_fr, plt);
%
% See also: fresnelradius
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 04-Mar-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults.
defval('num_fr', 100);
defval('npts_fr', num_fr);
defval('plt', false)

% Compute lat/lon of great circle path between source and receiver.
[gclat, gclon] = track2(lat1, lon1, lat2, lon2, [], [], num_fr);

% Compute azimuth (degrees) at every point along great circle path.
% Fresnel radius goes to zero at endpoints so azimuth is irrelevant.
% (0 is just nicer than NaN, there)
az(1) = 0;
for i = 2:length(gclat)-1
    az(i) = azimuth(gclat(i), gclon(i), gclat(i+1), gclon(i+1));

end
az(length(gclat)) = 0;
az = az';

% Compute total and cumulative distance along great circle path.
[tot_distkm, tot_distdeg] = grcdist([lon1 lat1], [lon2 lat2]);
tot_distm = tot_distkm * 1000;
cum_distm = linspace(0, tot_distm, num_fr);
cum_distdeg = linspace(0, tot_distdeg, num_fr);

% Compute Fresnel radius at every point along great circle path.
fr_m = fresnelradius(cum_distm, tot_distm, v, f);
fr = km2deg(fr_m/1000);

% Compute Fresnel radius tracks that run normal to great-circle track.  Positive
% radii track north(east) of east-west(north-south) great circles.  Negative
% radii track south(west) of north-south(east_west) great circles.  Add one
% point to each to accommodate latter chop of great-circle track itself (the
% input here is number of Fresnel radii, so we do want to add one to equal
% number requested, which differs from how it is done with `fresnelgrid`).
npts_fr = npts_fr + 1;
[fzlat_neg, fzlon_neg] = track1(gclat, gclon, az-90, fr, [], [], npts_fr);
[fzlat_pos, fzlon_pos] = track1(gclat, gclon, az+90, fr, [], [], npts_fr);

% The first point along each pos/neg Fresnel radius is on great circle itself;
% cut it.  E.g., the positive track starts on great circle and tracks north/east
% the specific Fresnel radius.
fzlat_neg(1, :) = [];
fzlat_pos(1, :) = [];
fzlon_neg(1, :) = [];
fzlon_pos(1, :) = [];

% At this point the columns define the Fresnel radius tracks (normal to great
% circle) and the rows define the Fresnel-zone tracks (adjacent to great
% circle). Transpose and concatenate pos/neg radius tracks so that columns of
% the output define Fresnel-zone tracks.  Slot great-circle latitudes and
% longitudes (multiply repeated and cut above) in middle of positive and
% negative tracks.
fzlat = [fliplr(fzlat_neg') gclat fzlat_pos'];
fzlon = [fliplr(fzlon_neg') gclon fzlon_pos'];

% Return index (middle of tracks) of column representing great-circle track.
gcidx = size(fzlat_neg',2) + 1;

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
