function hunga_write_great_circle_gebco
% HUNGA_WRITE_GREAT_CIRCLE_GEBCO
%
% Writes structure `gc` in $HUNGA/code/static/hunga_great_circle_gebco.mat
% containing GEBCO elevations along a geat-cricle track at 600 m resolution
% (same as `write_fresnel_grid_gebco.m').
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 25-Nov-2024, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

clc
close all

%% Note from `write_fresnel_grid_gebco` %%
% Compute resolution of Fresnel grid previous solution (below; by using 90% of
% GEBCO resolution at station with max latitude) resulted in ~693 m
% resolution. Let's just shrink that to 600 m (2.5 Hz T wave) for cleanliness
% and easier y=mx+b sound pressure level solutions. Don't use vel/freq here
% because I don't want to sample higher-frequency T-waves with higher-resolution
% grids (GEBCO will just smear values; at 600 m we're already below
% min. resolution of 926 m; see below).
res = 600; % m

% Default to load already compiled .mat
hundir = getenv('HUNGA');
savefile = fullfile(hundir, 'code', 'static', mfilename);

%% MAIN
evtfdir = fullfile(hundir, 'evt');
evtf = fullfile(evtfdir, '11516993.evt');
evtf = load(evtf, '-mat');
EQ = evtf.EQ;
evt.lat = EQ.PreferredLatitude;
evt.lon = EQ.PreferredLongitude;
evt.date = irisstr2date(EQ.PreferredTime);

% Compile then concatentae lists of MERMAID and IMS .sac files
merdir = fullfile(hundir, 'sac');
mersac = globglob(merdir, '*.sac');

imsdir = fullfile(merdir, 'ims');
imssac = globglob(imsdir, '*sac.pa');

sac = [mersac ; imssac];

% Loop over every .sac file.
for i = 1:length(sac)
    [~, h] = readsac(sac{i});

    % Compute great-circle distance and use it compute number of points.
    [tot_distkm, tot_distdeg] = grcdist([evt.lon evt.lat], [h.STLO h.STLA]);
    gc_npts = ceil(tot_distkm*1e3 / res);

    % Compute great-circle track.
    % Don't use reference ellisoid because travel times are 1-D.
    [gcla, gclo] = track2(evt.lat, evt.lon, h.STLA, h.STLO, [], [], gc_npts);

    % Compute cumulative (summing at every point) distance traveled from event
    % (0 deg/km is source).
    cum_distkm = linspace(0, tot_distkm, gc_npts)';
    cum_distdeg = linspace(0, tot_distdeg, gc_npts)';

    % Fetch GEBCO elevation along great-circle track
    gelev = gebco(gclo, gcla, '2014');

    % Organize output into struct.
    gc.(h.KSTNM).evla = evt.lat;
    gc.(h.KSTNM).evlo = evt.lon;
    gc.(h.KSTNM).stla = h.STLA;
    gc.(h.KSTNM).stlo = h.STLO;
    gc.(h.KSTNM).stdp = h.STDP;
    gc.(h.KSTNM).gcla = gcla;
    gc.(h.KSTNM).gclo = gclo;
    gc.(h.KSTNM).tot_distkm = tot_distkm;
    gc.(h.KSTNM).cum_distkm = cum_distkm;
    gc.(h.KSTNM).tot_distdeg = tot_distdeg;
    gc.(h.KSTNM).cum_distdeg = cum_distdeg;
    gc.(h.KSTNM).gebco_elev = gelev;

end

% Sort based on epicentral distance.
field = [];
kstnm = fieldnames(gc);
for i = 1:length(kstnm)
    dist(i) = gc.(kstnm{i}).tot_distdeg;
    field = [field kstnm(i)];

end
[~, sidx] = sort(dist);
sortedfield = field(sidx);
gc = reorderstructure(gc, sortedfield{:});

staticdir = fileparts(savefile);
if ~exist(staticdir, 'dir')
    mkdir(staticdir);

end
save(savefile, 'gc');
fprintf('Wrote %s\n', savefile)

% QDP sanity check.
figure;
ax = gca;
plotcont
hold(ax, 'on')
kstnm = fieldnames(gc);
for i = 1:length(kstnm)
    plot(ax, longitude360(gc.(kstnm{i}).gclo), gc.(kstnm{i}).gcla)

end
hold(ax, 'off')
