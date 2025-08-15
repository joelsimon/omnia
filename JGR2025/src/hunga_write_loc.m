function hunga_write_loc()
% HUNGA_WRIT_ELOC
%
% Write textfile of station name, latitude, longitude, and depth.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 25-Jan-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc

hundir = getenv('HUNGA');
sacdir = fullfile(hundir, 'sac');
imsdir = fullfile(sacdir, 'ims');
evtdir = fullfile(hundir, 'evt');

evt = fullfile(evtdir, '11516993.evt');
evt = load(evt, '-mat');
EQ = evt.EQ;

mersac = globglob(sacdir, '*.sac');
imssac = globglob(imsdir, '*.sac');

[~, idx] = sort(cellfun(@(xx) xx(end-1:end), getmerser(mersac), 'UniformOutput', false));
mersac = mersac(idx);
sac = [mersac ; imssac];

fname = fullfile(sacdir, 'meta', 'loc.txt');
writeaccess('unlock', fname, false);
fid = fopen(fname, 'w');
fmt = '%5s    %10.6f    %11.6f    %6i\n';

fprintf(fid, 'KNSTM          STLA           STLO      STDP\n');
fprintf(fid, fmt, 'HTHH', EQ.PreferredLatitude, EQ.PreferredLongitude, EQ.PreferredDepth);
[~, idx] = sort(cellfun(@(xx) xx(end-1:end), getmerser(mersac), 'UniformOutput', false));

for i = 1:length(sac);
    h = sachdr(sac{i});
    fprintf(fid, fmt, h.KSTNM, h.STLA, h.STLO, h.STDP);

end
fclose(fid);
writeaccess('lock', fname)
fprintf('Wrote %s\n', fname)
