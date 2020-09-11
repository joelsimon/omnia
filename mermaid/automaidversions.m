 function automaidversions(mustequate)
% AUTOMAIDVERSIONS(musteqate)
%
% Compares SAC files compiled with different automaid versions.
%
% Author: Dr. Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 11-Sep-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

sac_old = fullsac([], fullfile(getenv('MERMAID'), 'processed'));
sac_new = fullsac([], fullfile(getenv('MERMAID'), 'test_processed'));

[~, idx_old, idx_new] = intersect(strippath(sac_old), strippath(sac_new));
sac_old = sac_old(idx_old);
sac_new = sac_new(idx_new);

if mustequate
    fid = fopen('~/old_new_diff_full.txt', 'w');
    allowed_date_diff = 0;
    allowed_dist_diff = 0;

else
    fid = fopen('~/old_new_diff_light.txt', 'w');
    allowed_date_diff = 1e-3; % milliseconds
    allowed_dist_diff = 1e-5; % ~1 m

end
fmt = '%s\n';

for i = 1:length(sac_old)
    [data_old, header_old] = readsac(sac_old{i});
    seisdate_old = seistime(header_old);
    lat_old = header_old.STLA;
    lon_old = header_old.STLO;

    [data_new, header_new] = readsac(sac_new{i});
    seisdate_new = seistime(header_new);
    lat_new = header_new.STLA;
    lon_new = header_new.STLO;

    if ~isequal(data_old, data_new)
        fprintf(fid, fmt, sprintf('%s    data', strippath(sac_old{i})));

    end

    actual_dateB_diff = seconds(seisdate_old.B - seisdate_new.B);
    if abs(actual_dateB_diff) > allowed_date_diff
        fprintf(fid, fmt, sprintf('%s    date.B     %15.6f sec', strippath(sac_old{i}), actual_dateB_diff));

    end

    actual_dateE_diff = seconds(seisdate_old.E - seisdate_new.E);
    if abs(actual_dateE_diff) > allowed_date_diff
        fprintf(fid, fmt, sprintf('%s    date.E     %15.6f sec', strippath(sac_old{i}), actual_dateE_diff));

    end

    actual_lat_diff = lat_old - lat_new;
    if abs(actual_lat_diff) > allowed_dist_diff
        fprintf(fid, fmt, sprintf('%s       lat     %15.6f deg', strippath(sac_old{i}), actual_lat_diff));

    end

    actual_lon_diff = lon_old - lon_new;
    if abs(actual_lon_diff) > allowed_dist_diff
        fprintf(fid, fmt, sprintf('%s       lon     %15.6f deg', strippath(sac_old{i}), actual_lon_diff));

    end
end
