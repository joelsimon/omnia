function [fzlat, fzlon, gcidx, gcdist, fr, deg] = ...
            fresnelgrid(lat1, lon1, lat2, lon2, vel, freq, deg, plt)
% [fzlat, fzlon, gcidx, gcdist, fr, deg] = ...
%     FRESNELGRID(lat1, lon1, lat2, lon2, vel, freq, deg, plt)
%
% Compute 2-D (map view; no depth) Fresnel zone for constant-velocity waves
% (e.g., surface or T waves) on an equal-area grid.
%
% Output fzlat/lon matrices arranged with rows of Fresnel radii and columns of
% Fresnel "tracks," of which the latter run (sub)parallel to great-circle path,
% itself at center: gclat=fzlat(:,<middle_index); gclon=fzlon(:,<middle_index>).
%
% Note the construction of the final lat/lon output matrices: the middle column
% is the great-circle path (line of sight in a free-space path loss sense). All
% columns to the left are Fresnel radii projected at -90-degree azimuths from
% the instantaneous azimuth of the great-circle path at that point.  Negative
% azimuth does NOT mean lower lat/lon; it means rotating 90 degrees counter
% clockwise, so a great-circle path heading directly east (HTHH to H03S1) will
% actually have relatively larger latitudes in the left side of the output
% matrix, since -90 rotation (counterclockwise) from east is heading north.
% Further, column 1 is the edge (furthest from great-circle path) in the
% counter-clockwise azimuthal sense.  Conversely, the right-half columns in the
% output matrix at +90 azimuth (clockwise) from from great-circle path, so an
% easting path (HTHH to H03S1) actually has lower latitudes in the +90 sense.
%
% Input:
% lat1/lon1        Latitude and longitude of source [deg]
% lat2/lon2        Latitude and longitude of receiver [deg]
% vel              Wave velocity [m/s]
% freq             Wave frequency [Hz]
% deg*             Grid resolution (lengths of sides of lat/lon square) [deg]*
% plt              true to plot output (def: false)
%
% Output:
% fzlat            Latitudes of Fresnel zone [deg]
% fzlon            Longitudes of Fresnel zone [deg]
% gcidx            Column index of great-circle path (middle of output matrix)
%                  e.g., gclat = fzlat(:, gcidx);
%                        gclon = fzlat(:, gclon)
% gcdist           Cumulative distance along great-circle path [deg]
% fr               Fresnel radii length at every point along great circle [deg]
% deg*             Actual grid resolution [deg]*
%
% *Actual grid resolution is dictated by discretization of great circle path and
%  will be less than requested.
%
% Ex: (Fresnel zone for 20 s surface wave from Sydney to Portland using 0.25 deg grid)
%    lat1=-33; lon1=151; lat2=45; lon2=-122; vel=3500; freq=1/20; deg=0.25; plt=true;
%    FRESNELGRID(lat1,lon1,lat2,lon2,vel,freq,deg,plt);
%
% See also: fresnelzone.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 20-Mar-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% NB: There are various ways to speedup this up (e.g., `cumdist` outside loop and
% computing all `fresnelradius` in one go; merging azimuth computation into main
% loop; computing max radius at every point, filling "rectangle" with lat/lon
% and then latter set to NaN those outside radius [allows you to make one run of
% `track1` for all points]), etc.  I did all that and didn't find the speedup
% worth the loss of readability.

% Default.
defval('plt', false)

% Compute great-circle length (epicentral distance).
gc_tot_dist_deg = distance(lat1, lon1, lat2, lon2, 'degrees');
gc_tot_dist_m = deg2km(gc_tot_dist_deg) * 1e3;

% Determine number of points along great-circle path to compute Fresnel radii
% based on requested resolution in degrees. Add one for end point (resolution is
% an interval).
req_deg = deg;
num_fr = ceil(gc_tot_dist_deg / req_deg) + 1;

% Compute lat/lon of great circle path between source and receiver.
[gclat, gclon] = track2(lat1, lon1, lat2, lon2, [], [], num_fr);

% Determine actual degree resolution (at most equal to, likely less than
% requested).
act_deg = distance(gclat(1), gclon(1), gclat(2), gclon(2), 'degrees');

% Note request vs. reality.
lambda_km = (vel / freq) / 1e3;
fprintf('Requested grid spacing: %.5f degrees (%.3f km sides; %.2f sq. km)\n', ...
        req_deg, deg2km(req_deg), deg2km(req_deg)^2);
fprintf('   Actual grid spacing: %.5f degrees (%.3f km sides; %.2f sq. km)\n', ...
        act_deg, deg2km(act_deg), deg2km(act_deg)^2);
fprintf('            Wavelength: %.3f km (%.1f wavelengths per grid interval)\n', ...
        lambda_km, deg2km(act_deg)/lambda_km)

% Compute azimuth (degrees) at every point along great circle path.  Each
% Fresnel radii will be oriented normal to the instantaneous azimuth at that
% point (picture a fish spine).
for i = 1:num_fr-1
    az(i) = azimuth(gclat(i), gclon(i), gclat(i+1), gclon(i+1), 'degrees');

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

% Determine number of points along longest Fresnel radii (at midpoint of
% great-circle) to determine size of output matrix.
fr_max_m = fresnelmax(vel, freq, gc_tot_dist_m);
fr_max_km = fr_max_m / 1e3;
fr_max_deg = km2deg(fr_max_km);
max_arclen_act_deg = [0:act_deg:fr_max_deg];
npts_max_fr = length(max_arclen_act_deg);

% Initiate matrices to hold positive, negative Fresnel radii in latitude and
% longitude (think of a fish spine as viewed above).
frlat_neg = NaN(npts_max_fr, num_fr);
frlon_neg = NaN(npts_max_fr, num_fr);
frlat_pos = NaN(npts_max_fr, num_fr);
frlon_pos = NaN(npts_max_fr, num_fr);

% Loop over every point along great-circle where Fresnel radii must be
% computed.
for i = 1:num_fr
    % Determine Fresnel radii length in degrees at this point.
    gc_dist_deg(i) = distance(lat1, lon1, gclat(i), gclon(i));
    gc_dist_m = deg2km(gc_dist_deg(i)) * 1e3;

    % Skip calculation at end points (far end can have distance rounding errors that
    % throw errors in `fresnelradius`).
    if i > 1 && i < num_fr
        fr_m = fresnelradius(gc_dist_m, gc_tot_dist_m, vel, freq);

    else
        fr_m = 0;

    end

    % Convert Fresnel radii from m to km, deg.
    fr_km = fr_m / 1e3;
    fr_deg(i) = km2deg(fr_km);

    % Discretize Fresnel radii arc length into equal chunks of delta degrees
    % and use final value (distance in degrees) to specify full length of arc
    % (equal to or less than actual Fresnel length), and array length to
    % specify how many points along that arch to be computed.
    arclen_act_deg = [0:act_deg:fr_deg(i)];

    % Project Fresnel radii at azimuth -/+90 degrees (normal) to great-circle path
    % at arc lengths defined by max discretized radii, splitting into
    % equal-degree-length chunks just found.  NB: negative azimuth does NOT mean
    % lower lat/lon; it means rotating 90 degrees counter clockwise, so a
    % great-circle path heading directly east (HTHH to H03S1) will actually have
    % relatively larger latitudes in the left side of the output matrix, since
    % -90 rotation (counterclockwise) from east is heading north.
    [lat_neg, lon_neg] = ...
        track1(gclat(i), gclon(i), az(i)-90, arclen_act_deg(end), [], 'degrees', length(arclen_act_deg));

    [lat_pos, lon_pos] = ...
        track1(gclat(i), gclon(i), az(i)+90, arclen_act_deg(end), [], 'degrees', length(arclen_act_deg));

    % Only the maximum radii (midpoint of path) can ever have all indices of output
    % matrices filled (although it think depending on discretization, even that
    % array might have a NaN at the end), so fill NaNs from end of Fresnel
    % radii arc length to full length of column.  All lat/lon and pos/neg
    % have same length; pick one to determine number of NaNs.
    nan_fill = NaN(size(frlat_neg,1)-length(lat_neg), 1);
    frlat_neg(:,i) = [lat_neg ;  nan_fill];
    frlon_neg(:,i) = [lon_neg ;  nan_fill];

    frlat_pos(:,i) = [lat_pos ;  nan_fill];
    frlon_pos(:,i) = [lon_pos ;  nan_fill];

end

% The first point along each pos/neg Fresnel radius is on great circle itself;
% cut it.  E.g., the positive track starts on great circle and tracks north/east
% the specific Fresnel radius.
frlat_neg(1, :) = [];
frlon_neg(1, :) = [];
frlat_pos(1, :) = [];
frlon_pos(1, :) = [];

% At this point the columns define the Fresnel radii (normal to great
% circle/line-of-sight in free-space path loss sense) and the rows define the
% Fresnel-zone "tracks" ((sub)parallel to great circle). Flip left-right the
% negative-azimuth lat/lon so that shape of matrix mirrors shape of Fresnel zone
% (with NaNs). Transpose and concatenate pos/neg radius tracks so that columns
% of the output define Fresnel-zone tracks.  Slot great-circle latitudes and
% longitudes (multiply repeated and cut above) in middle of positive and
% negative tracks.
fzlat = [fliplr(frlat_neg') gclat frlat_pos'];
fzlon = [fliplr(frlon_neg') gclon frlon_pos'];

% Now the rows are Fresnel radii and the columns are Fresnel "tracks" that run
% (sub)parallel to great circle.  This is a check to verify equal area (we know
% Fresnel radii perpendicular to great-circle have constant delta deg spacing;
% this verifies spacing between neighboring Fresnel radii are similarly spaced
% spacing set to delta deg).
ct = 0;
mind = [];
maxd = [];
for i = 1:size(fzlat,1);
    lat = fzlat(i,:);
    lon = fzlon(i,:);

    lat = lat(find(isfinite(lat)));
    lon = lon(find(isfinite(lon)));

    diff_deg = diff(cumdist(lat',lon'));
    if ~isempty(diff_deg)
        ct = ct+1;
        mind(ct) = min(diff_deg);
        maxd(ct) = max(diff_deg);

    end
end
difer(min(mind)-act_deg, 10, 1, NaN)
difer(max(maxd)-act_deg, 10, 1, NaN)

% Return index (middle of tracks) of column representing great-circle track.
gcidx = size(frlat_neg', 2) + 1;

% Collect outputs.
deg = act_deg;
fr = fr_deg';
gcdist = gc_dist_deg';

%% ___________________________________________________________________________ %%

if plt
    % Toggle big on or off to swap basemap for Pacific.
    big = false;

    figure
    if big
        plotgebcopacific

    else
        plotcont
        axesfs([], 10, 10)
        longticks([], 2)
        xlim([0 360])
        ylim([-90 90])
        box on

    end
    hold on

    % Plot Fresnel radii; COLUMNS of output.
    for i = 1:size(fzlon, 2);
        fr_track =  plot(longitude360(fzlon(:, i)), fzlat(:, i), 'b-');

    end

    % Plot (again, redundantly for color) great-circle track, which should fall in
    % middle.
    gc_track = plot(longitude360(fzlon(:, gcidx)), fzlat(:, gcidx), 'r');

    % Plot Fresnel "tracks" (sub)parallel to great-circle; ROWS of output
    for i = 1:size(fzlon, 1);
        fr_radius = plot(longitude360(fzlon(i, :)), fzlat(i, :), 'ko-');

    end

    legend([gc_track fr_track fr_radius], 'Great-Circle Track', ...
           'Fresnel Tracks', 'Fresnel Radii');
    hold off
    latimes2
    shg

end
