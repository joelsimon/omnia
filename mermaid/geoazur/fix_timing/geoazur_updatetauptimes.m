function geoazur_updatetauptimes
% GEOAZUR_UPDATETAUPTIMES
%
% Single-use script to update timing of reviewed GeoAzur EQ structures, after it
% was discovered they were written using the incorrect seistime.m (pre-v1.0.0),
% which improperly formatted the header NZMSEC.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 21-Sep-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Load data.
defval('sac_diro', getenv('MERAZUR'));
defval('rematch_diro', fullfile(getenv('MERAZUR'), 'rematch'));
defval('evt_diro', fullfile(rematch_diro, 'reviewed', 'identified', 'evt'))

s = mermaid_sacf('id', sac_diro);

fname_time = fullfile(evt_diro, 'updated_timing');
fid_time = fopen(fname_time, 'w+');

fname_press = fullfile(evt_diro, 'updated_pressure');
fid_press = fopen(fname_press, 'w+');

for i = 1:length(s)
    i
    sac_file = s{i};
    sac_str = sprintf('%s (i = %3i)\n', strippath(sac_file), i);

    evt_name = strrep(strippath(sac_file), '.sac', '.evt');
    evt_file = fullfile(evt_diro, evt_name);

    [isupdated, new_EQ, old_EQ] = updatetauptimes(sac_file, evt_file);

    [~, h] = readsac(sac_file);

    if isupdated
        if h.NZMSEC > 0 && h.NZMSEC < 100
            fprintf(fid_time, sac_str)

        elseif isequal(rmfield(new_EQ.TaupTimes, 'pressure'), rmfield(old_EQ.TaupTimes, 'pressure'))
            fprintf(fid_press, sac_str)

        else
            error(fprintf('%s updated for unkown reason', sac_str))

        end
    else
        if h.NZMSEC > 0 && h.NZMSEC < 100
            error(fprintf('%s should not have updated', sac_str))

        end
    end
end

writeaccess('lock', fname_time)
writeaccess('lock', fname_press)

fprintf('Wrote %s\n', fname_time)
fprintf('Wrote %s\n', fname_press)
