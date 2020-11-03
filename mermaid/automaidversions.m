function [max_lat_diff, max_lon_diff] = automaidversions(mustequate, old, new, fname)
% [max_lat_diff, max_lon_diff] = AUTOMAIDVERSIONS(mustequate, old, new, fname)
%
% Compares SAC files compiled with different automaid versions.
%
% Input:
% mustequate    true: data/location values must be exactly the same
%               false: data/location values must be same within sensible range
% old           Directory containing old SAC files (def: $MERMAID/processed)
% new           Directory containing new SAC files (def: $MERMAID/test_processed)
% fname         Output file name (def: '~/automaidversions_diff_[full/light].txt')
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 03-Nov-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('old', fullfile(getenv('MERMAID'), 'processed'))
defval('new', fullfile(getenv('MERMAID'), 'test_processed'))
defval('fname', fullfile(getenv('HOME'), 'automaidversions_diff'))

sac_old = fullsac([], old);
sac_new = fullsac([], new);

[~, idx_old, idx_new] = intersect(strippath(sac_old), strippath(sac_new));
sac_old = sac_old(idx_old);
sac_new = sac_new(idx_new);

if mustequate
    fname = [fname '_full.txt'];
    allowed_date_diff = 0;
    allowed_dist_diff = 0;

else
    fname = [fname '_light.txt'];
    allowed_date_diff = 0.009 % seconds
    allowed_dist_diff = 0.00009 % degrees

end
fid = fopen(fname, 'w');
fmt = '%s\n';

max_lat_diff = 0;
max_lon_diff = 0;
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
    if abs(actual_lat_diff) >  abs(max_lat_diff)
        max_lat_diff = actual_lat_diff;
        max_lat_sac = sac_new{i};

    end

    actual_lon_diff = lon_old - lon_new;
    if abs(actual_lon_diff) > allowed_dist_diff
        fprintf(fid, fmt, sprintf('%s       lon     %15.6f deg', strippath(sac_old{i}), actual_lon_diff));

    end
    if abs(actual_lon_diff) >  abs(max_lon_diff)
        max_lon_diff = actual_lon_diff;
        max_lon_sac = sac_new{i};

    end

end
fprintf('Wrote %s\n', fname)

max_lat_diff
max_lat_sac

max_lon_diff
max_lon_sac
