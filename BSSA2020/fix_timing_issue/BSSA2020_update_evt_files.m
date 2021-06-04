function BSSA2020_update_evt_files
% BSSA2020_UPDATE_EVT_FILES

geoazur_path = fullfile(getenv('MERMAID'), 'geoazur');
rematch_path = fullfile(geoazur_path, 'rematch');
evt_path = fullfile(rematch_path, 'reviewed', 'identified', 'evt');
evt_dir = skipdotdir(dir(fullfile(evt_path, '*.evt')));

evt_file_updated = [];
for i = 1:length(evt_dir)
    i
    evt_file = fullfile(evt_dir(i).folder, evt_dir(i).name);
    temp_EQ = load(evt_file, '-mat');
    EQ = temp_EQ.EQ;
    clearvars('temp_EQ')


    sac_file = fullsac(strrep(evt_dir(i).name, '.evt', '.sac'), geoazur_path);
    if length(sac_file) < 1
        error('No SAC file found')

    elseif iscell(sac_file)
        error('More than 1 SAC file found')

    end

    [isupdated, new_EQ, old_EQ] = updatetauptimes(sac_file, evt_file);
    if isupdated
        % Verify the update is the reason we expect.
        [~, h] = readsac(sac_file);
        good_timing = seistime(h);
        bad_timing = BSSA2020_seistime_NZMSEC_error(h);

        % If the timings are equal and the EQ structure was still updated it must have
        % been for some "other reason," e.g., apparently there was a bug in an
        % earlier version of `reid` and/or `reidpressure` that attached multiple
        % pressure estimates to a single phase, e.g., m12.20150306T082259.sac.
        if isequal(good_timing, bad_timing)
            sac_file = [sac_file '_other']

        end
        evt_file_updated = [evt_file_updated ; {sac_file}];

    end
end

% Write text file in rematch path.
filename = fullfile(rematch_path, 'evt_file_updated.txt');
writeaccess('unlock', filename, false)
fid = fopen(filename, 'w+');
fprintf(fid, '%s\n', evt_file_updated{:});
writeaccess('lock', filename, false)
