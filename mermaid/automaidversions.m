function [max_dateB_diff, max_dateE_diff, max_lat_diff, max_lon_diff] = automaidversions(mustequate, old, new, fname)
% [max_dateB_diff, max_dateE_diff, max_lat_diff, max_lon_diff] = AUTOMAIDVERSIONS(mustequate, old, new, fname)
%
% Compares SAC files compiled with different automaid versions.
%
% Input:
% mustequate    true: data/location values must be exactly the same (def)
%               false: data/location values must be same within sensible range
% old           Directory containing old SAC files (def: $MERMAID/test_processed)
% new           Directory containing new SAC files (def: $MERMAID/processed)
% fname         Output file name (def: '~/automaidversions_diff[_full/_light].txt')
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 17-May-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc

defval('mustequate', true)
defval('old', fullfile(getenv('MERMAID'), 'test_processed'))
defval('new', fullfile(getenv('MERMAID'), 'processed'))
defval('fname', fullfile(getenv('HOME'), 'automaidversions_diff'))

sac_old = fullsac([], old);
sac_new = fullsac([], new);

[~, idx_old, idx_new] = intersect(strippath(sac_old), strippath(sac_new));
sac_old = sac_old(idx_old);
sac_new = sac_new(idx_new);

fprintf('Comparing %i SAC files common to:\n\t%s (old)\n\t%s (new)\n', length(idx_old), old, new)

if mustequate
    fname = [fname '_full.txt'];
    allowed_date_diff = 0;
    allowed_dist_diff = 0;

else
    fname = [fname '_light.txt'];
    allowed_date_diff = 0.009; % seconds
    allowed_dist_diff = 0.00009; % degrees

end
fid = fopen(fname, 'w');
fmt = '%s\n';

fprintf('Allowed (absolute) time difference:     %.6f sec\n', allowed_date_diff)
fprintf('Allowed (absolute) distance difference: %.6f deg (%.1f m)\n\n', allowed_dist_diff, deg2km(allowed_dist_diff)*1000)

% Define anonymous function to capture order-of-magnitude differences.
get_exp = @(xx) floor(log10(xx));

max_dateB_diff = 0;
max_dateE_diff = 0;
max_lat_diff = 0;
max_lon_diff = 0;

max_dateB_sac = '';
max_dateE_sac = '';
max_lat_sac = '';
max_lon_sac = '';

version_old = {};
version_new = {};

for i = 1:length(sac_old)
    % Read old data
    [data_old, header_old] = readsac(sac_old{i});
    seisdate_old = seistime(header_old);
    lat_old = header_old.STLA;
    lon_old = header_old.STLO;

    % Read new data
    [data_new, header_new] = readsac(sac_new{i});
    seisdate_new = seistime(header_new);
    lat_new = header_new.STLA;
    lon_new = header_new.STLO;

    if ~isequal(data_old, data_new)
        fprintf(fid, fmt, sprintf('%s    data', strippath(sac_old{i})));

    end

    % Start time
    actual_dateB_diff = seconds(seisdate_old.B - seisdate_new.B);
    if abs(actual_dateB_diff) > allowed_date_diff
        fprintf(fid, fmt, sprintf('%s    date.B     10^%+i sec', strippath(sac_old{i}), get_exp(actual_dateB_diff)));
        %fprintf(fid, fmt, sprintf('%s    date.B     %15.6f sec', strippath(sac_old{i}), actual_dateB_diff));

    end
    if abs(actual_dateB_diff) > abs(max_dateB_diff)
        max_dateB_diff = actual_dateB_diff;
        max_dateB_sac = sac_old{i};

    end

    % End time
    actual_dateE_diff = seconds(seisdate_old.E - seisdate_new.E);
    if abs(actual_dateE_diff) > allowed_date_diff
        fprintf(fid, fmt, sprintf('%s    date.E     10^%+i sec', strippath(sac_old{i}), get_exp(actual_dateE_diff)));
        %fprintf(fid, fmt, sprintf('%s    date.E     %15.6f sec', strippath(sac_old{i}), actual_dateE_diff));


    end
    if abs(actual_dateE_diff) > abs(max_dateE_diff)
        max_dateE_diff = actual_dateE_diff;
        max_dateE_sac = sac_old{i};

    end

    % Latitude
    actual_lat_diff = lat_old - lat_new;
    if abs(actual_lat_diff) > allowed_dist_diff
        fprintf(fid, fmt, sprintf('%s       lat     10^%+i deg', strippath(sac_old{i}), get_exp(actual_lat_diff)));
        %fprintf(fid, fmt, sprintf('%s       lat     %15.6f deg', strippath(sac_old{i}), actual_lat_diff));

    end
    if abs(actual_lat_diff) >  abs(max_lat_diff)
        max_lat_diff = actual_lat_diff;
        max_lat_sac = sac_old{i};

    end

    % Longitude
    actual_lon_diff = lon_old - lon_new;
    if abs(actual_lon_diff) > allowed_dist_diff
        fprintf(fid, fmt, sprintf('%s       lon     10^%+i deg', strippath(sac_old{i}), get_exp(actual_lon_diff)));
        %fprintf(fid, fmt, sprintf('%s       lon     %15.6f deg', strippath(sac_old{i}), actual_lon_diff));

    end
    if abs(actual_lon_diff) >  abs(max_lon_diff)
        max_lon_diff = actual_lon_diff;
        max_lon_sac = sac_old{i};

    end

    % Version numbers
    version_old = [version_old ; {header_old.KUSER0}];
    version_new = [version_new ; {header_new.KUSER0}];

end
version_old = unique(version_old);
version_new = unique(version_new);

fprintf('Wrote %s\n\n', fname)

fprintf('Comparing --\n(old): %s\n(new): %s\n', old, new)

fprintf('Max dateB: %+.6f s (%s)\n', max_dateB_diff, strippath(max_dateB_sac))
fprintf('Max dateE: %+.6f s (%s)\n', max_dateE_diff, strippath(max_dateE_sac))
fprintf('Max lat:   %+.6f deg or %+i m (%s)\n', max_lat_diff, round(deg2km(max_lat_diff)*1000), strippath(max_lat_sac))
fprintf('Max lon:   %+.6f deg or %+i m (%s)\n', max_lon_diff, round(deg2km(max_lon_diff)*1000), strippath(max_lon_sac))
fprintf('Old versions:\n')
fprintf(' %s\n', version_old{:})
fprintf('New versions:\n')
fprintf(' %s\n', version_new{:})
