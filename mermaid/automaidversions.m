function automaidversions(mustequate)
% AUTOMAIDVERSIONS(musteqate)
%
% Compares SAC files compiled with different automaid versions.
%
% Author: Dr. Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 09-Sep-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

sac_old = fullsac([], fullfile(getenv('MERMAID'), 'processed'));
sac_new = fullsac([], fullfile(getenv('MERMAID'), 'test_processed'));

[~, idx] = ismember(strippath(sac_old), strippath(sac_new));
sac_old = sac_old(find(idx));

if mustequate
    fid = fopen('~/old_new_diff_full.txt', 'w');
    date_diff = 0;
    dist_diff = 0;

else
    fid = fopen('~/old_new_diff_light.txt', 'w');
    date_diff = 1e-3; % milliseconds
    dist_diff = 1e-5; % ~1 m

end

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
        sprintf('%s data', strippath(sac_old{i}))
        fprintf(fid, '%s data\n', strippath(sac_old{i}))

    end

    if abs(seconds(seisdate_old.B - seisdate_new.B)) > date_diff
        sprintf('%s date B', strippath(sac_old{i}))
        %keyboard
        fprintf(fid, '%s date.B\n ', strippath(sac_old{i}))

    end

    if abs(seconds(seisdate_old.E - seisdate_new.E)) > date_diff
        sprintf('%s date E', strippath(sac_old{i}))
        %keyboard
        fprintf(fid, '%s date.E\n', strippath(sac_old{i}))

    end

    if abs(lat_old - lat_new) > dist_diff
        sprintf('%s lat', strippath(sac_old{i}))
        %keyboard
        fprintf(fid, '%s lat\n', strippath(sac_old{i}))

    end

    if abs(lon_old - lon_new) > dist_diff
        sprintf('%s lon', strippath(sac_old{i}))
        %keyboard
        fprintf(fid, '%s lon\n', strippath(sac_old{i}))

    end
end
