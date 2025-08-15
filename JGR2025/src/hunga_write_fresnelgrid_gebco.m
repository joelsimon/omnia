function hunga_write_fresnelgrid_gebco(freq)
% HUNGA_WRITE_FRESNEL_ZONE_GEBCO(freq)
%
% Writes hunga_fresnelgrid_gebco_<freq>Hz_<kstnm>.mat containing GEBCO
% elevations along Fresnel-zone tracks from HTHH to each station.
%
% Input:
% freq       T wave frequency [Hz]
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 21-Oct-2024, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

defval('freq', [2.5:2.5:10])

%% RECURSIVE.
%% ___________________________________________________________________________ %%
if length(freq) > 1
    for i = 1:length(freq)
        hunga_write_fresnelgrid_gebco(freq(i));

    end
    return

end
%% RECURSIVE.
%% ___________________________________________________________________________ %%

% Output dirs.
hundir = getenv('HUNGA');
savepath = fullfile(hundir, 'code', 'static');

% T wave velocity, in m/s.
vel = 1500;

GC = hunga_read_great_circle;
stations = fieldnames(GC);

% Compute resolution of Fresnel grid previous solution (below; by using 90% of
% GEBCO resolution at station with max latitude) resulted in ~693 m
% resolution. Let's just shrink that to 600 m (2.5 Hz T wave) for cleanliness
% and easier y=mx+b sound pressure level solutions. Don't use vel/freq here
% because I don't want to sample higher-frequency T-waves with higher-resolution
% grids (GEBCO will just smear values; at 600 m we're already below
% min. resolution of 926 m; see below).
v_kms = vel/1000;
f_Hz = 2.5;
lambda_km = v_kms / f_Hz;
deg = km2deg(lambda_km);

%% Used to do this way -- results in 926 m GEBCO grid resolution (90% is 693);
%% i.e., min. resolution of GEBCO model for our data set at H03S2 (~34 S).
% % Compute resolution of Fresnel grid.
% % Highest latitude station is H03S2
% max_lat_val = 0;
% for i = 1:length(stations)
%     st = stations{i};
%     stla = GC.(st).stla;
%     if abs(stla) > abs(max_lat_val)
%         max_lat_st = st;
%         max_lat_val = stla;

%     end
% end

% % At every latitude band GEBCO divides each degree of longitude in 120 equal
% % chunks.  Determine the distance in km spanned by each GEBCO sampling interval
% % in the GEBCO grid at the maximum latitude of all stations to determine the
% % minimum sampling interval of the underlying model considering all stations.
% min_gebco_res_km = londeg2km(max_lat_val, 1/120);
% min_gebco_res_deg = km2deg(min_gebco_res_km);

% % Set the `fresnelgrid` resolution to 90% of the minimum GEBCO grid resolution
% % (I think this is sufficient to get most (all?) samples, though I could see
% % maybe the maximum (absolute) latitude being in some mid path (with a large
% % Fresnel zone), but I think that added complexity is not worth the increased
% % sampling).  Also, this value is alrady ~700 m, on the order of T wavelengths,
% % so I don't think we really care about finer features....
% deg = 0.9 * min_gebco_res_deg;
%% Used to do this way -- results in 926 m GEBCO grid resolution (90% is 693);
%% i.e., min. resolution of GEBCO model for our data set at H03S2 (~34 S).

for i = 1:length(stations)
    kstnm = stations{i};
    gc = GC.(kstnm);

    % Fresnel-zone latitudes and longitudes, columns are tracks
    [lat, lon, gcidx, gcdist, fr, deg] = ...
        fresnelgrid(gc.evla, gc.evlo, gc.stla, gc.stlo, vel, freq, deg);

    % Fresnel-zone GEBCO elevations, rows are radii and columns are "tracks"
    z = gebco(lon, lat, '2014');

    % Order output struct.
    fg.kstnm = kstnm;
    fg.lat = lat;
    fg.lon = lon;
    fg.depth_m = z;
    fg.radius_m = 1e3*deg2km(fr);
    fg.gcdist_m = 1e3*deg2km(gcdist);
    fg.gcidx = gcidx;
    fg.freq = freq;

    % Write it.
    savefile = fullfile(savepath, sprintf('%s_%.1fHz_%s.mat', mfilename, freq, kstnm));
    save(savefile, 'fg')
    fprintf('Wrote: %s\n', savefile)

end
