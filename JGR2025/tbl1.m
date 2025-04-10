function tbl1
% TBL1
%
% Table 1: Station locations
%
% Developed as: hunga_write_station_table
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 13-Mar-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

clc

s = hunga_fullsac;
s = rmbadsac(s);
s = rmgapsac(s);
s = ordersac_geo(s, 'gcarc');

evtdir = fullfile(getenv('HUNGA'), 'evt');
evt = fullfile(evtdir, '11516993.evt');
evt = load(evt, '-mat');
EQ = evt.EQ;

sigcat = catsac;

fname = fullfile(getenv('HUNGA'), 'code', 'static', [mfilename '.txt']);
writeaccess('unlock', fname, false)
fmt_std = '%2s & %5s & %7.3f & %8.3f & %4i & %5s & %4i & %3i & %1s\\\\\n';
fmt_h03 = '%2s & %5s & %7.1f & %8.1f & %4i & %5s & %4i & %3i & %1s\\\\\n';

fid = fopen(fname, 'w+');

for i = 1:length(s)
    [~, h] = readsac(s{i});
    [dist_km, dist_deg] = grcdist([EQ.PreferredLongitude EQ.PreferredLatitude], [h.STLO h.STLA]);
    dist_km = round(dist_km);
    az = round(azimuth(EQ.PreferredLatitude, EQ.PreferredLongitude, h.STLA, h.STLO));
    gebco_m = -round(gebco(h.STLO, h.STLA, '2014'));
    depthstr_m = sprintf('%i', gebco_m);

    % Add asterisk to IMS GEBCO depths because IMS says those are way wrong
    % in some cases.
    if isimssac(s{i});
        depthstr_m = [depthstr_m '$^*$'];

    end

    switch sigcat.(h.KSTNM)
      case 'A'
        sig = '{\color{blue}A}';

      case 'B'
        sig = '{\color{black}B}';

      case 'C'
        sig = '{\color{gray}C}';

      otherwise
        error('Unknown signal category')

    end

    % Mask H03 locations.
    if contains(h.KSTNM, 'H03')
        h.STLA = round(h.STLA, 1);
        h.STLO = round(h.STLO, 1);
        h.STDP = round(800, -2);
        fmt = fmt_h03;

    else
        fmt = fmt_std;

    end
    fprintf(fid, fmt, h.KNETWK, h.KSTNM, h.STLA, h.STLO, h.STDP, depthstr_m, dist_km, az, sig);

end
fclose(fid);
fprintf('Wrote: %s\n', fname);

fprintf('Including %i stations in table\n', length(s))
