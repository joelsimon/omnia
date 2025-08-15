function hunga_write_great_circle
% HUNGA_WRITE_GREAT_CIRCLE
%
% Writes `gc` structure of great-circle lat/lons to
% "hunga_write_great_circle_gebco.mat."
%
% Coarsely sampled: 1 point every 15 km; use `fresnelgrid` for finer resolution.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 14-Mar-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

%% RECURSIVE

clc
close all

% Set coarse discretization to 15 km sample spacing; use `fresnelgrid` for finer
% resolution.
res = 15e3;

% Default to load already compiled .mat
hundir = getenv('HUNGA');
savefile = fullfile(hundir, 'code', 'static', sprintf('%s.mat'), mfilename);

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
sac = rmbadsac(sac);

% Loop over every .sac file.
for i = 1:length(sac)
    [~, h] = readsac(sac{i});

    % Compute great-circle distance and use it compute number of points.
    [tot_distkm, tot_distdeg] = grcdist([evt.lon evt.lat], [h.STLO h.STLA]);
    gc_npts = ceil(tot_distkm*1000 / res);

    % Compute great-circle track.
    [gcla, gclo] = track2(evt.lat, evt.lon, h.STLA, h.STLO, [], [], gc_npts);

    % Compute cumulative (summing at every point) distance traveled from event (0
    % deg/km is source).
    cum_distkm = linspace(0, tot_distkm, gc_npts)';
    cum_distdeg = linspace(0, tot_distdeg, gc_npts)';

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
