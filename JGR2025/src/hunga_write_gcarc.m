function hunga_write_gcarc
% HUNGA_WRITE_GCARC
%
% Writes $HUNGA/sac/meta/gcarc.txt, with rows of KSTNM and great-circle distance
% in degrees.  Does not include GEBCO elevations.  Useful for quick read, e.g.,
% in ordersac.m, to order stations by epicentral distance.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 15-Aug-2025, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

% Get all SAC files.
hundir = getenv('HUNGA');
merdir = fullfile(hundir, 'sac');
imsdir = fullfile(merdir, 'ims');
metadir = fullfile(merdir, 'meta');

mersac = globglob(merdir, '*.sac');
imssac = globglob(imsdir, '*sac.pa');

sac = [mersac ; imssac];

% Load prototype event for main eruption.
hundir = getenv('HUNGA');
evtdir = fullfile(hundir, 'evt');
evt = load(fullfile(evtdir, '11516993.evt'), '-mat');
EQ = evt.EQ;

fname = fullfile(metadir, 'gcarc.txt');
writeaccess('unlock', fname, false);
fmt = '%5s %8.4f\n';
fid = fopen(fname, 'w');

saclist = {};
for i = 1:length(sac)
    [x, h] = readsac(sac{i});
    if contains(h.KSTNM, saclist)
        continue

    end

    lon1 = EQ.PreferredLongitude;
    lat1 = EQ.PreferredLatitude;

    lon2 = h.STLO;
    lat2 = h.STLA;

    [~, gcarc] = grcdist([lon1 lat1],[lon2 lat2]);

    fprintf(fid, fmt, h.KSTNM, gcarc);
    saclist = [saclist h.KSTNM];

end
fclose(fid);
writeaccess('lock', fname)
