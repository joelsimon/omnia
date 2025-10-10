function cp_evt(sac_dir1, evt_dir1, sac_dir2, evt_dir2)
% CP_EVT(sac_dir1, evt_dir1, sac_dir2, evt_dir2)
%
% Copy reviewed .evt files from dir1 (old) to dir2 (new), e.g.,:
%     (1) $MERMAID/processed/ to (2) $MERMAID/processed_everyone.
%
% * Only reviewed files in (1) to (2); raw files NOT copied
% * Does not update .evt files; only copies (update next)
% * Does not overwrite; only copies (1) to (2) if .evt file in (2) DNE
%
% Script assumes processed and events directories organized like JDS.
%
% Input:
% sac,evt_dir1    Paths to sac and events directories (COPY FROM)
% sac,evt_dir2    Paths to sac and events directories (COPY TO)
%
% Be aware: .sac and .evt file lengths may not match do to, e.g., skipping
% REQ, mag<3, non-Princeton floats etc.  However, I do think this will be a
% one-time script; work solely out of processed_everyone going forward.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 10-Oct-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

% Defaults.
defval('mer_dir', fullfile(getenv('MERMAID')))
defval('sac_dir1', fullfile(mer_dir, 'processed'))
defval('evt_dir1', fullfile(mer_dir, 'events'))
defval('sac_dir2', fullfile(mer_dir, 'processed_everyone'))
defval('evt_dir2', fullfile(mer_dir, 'events_everyone'))

logdir = fullfile(evt_dir2, 'cp_merge_update');
if ~exist(logdir, 'dir')
    mkdir(logdir);

end
logfile = fullfile(logdir, sprintf('%s_%s.txt', datestr(datetime('now'), 29), mfilename));

%% OLD DIR
% E.g., $MERMAID/[processed, events]/.
sac1 = globglob(sac_dir1, '**/*.sac');
evt1 = globglob(evt_dir1, 'reviewed', '**/*.evt');
fname_sac1 = strippath(sac1, true);
fname_evt1 = strippath(evt1, true);

%% NEW DIR
% E.g., $MERMAID/[processed_everyone, events_everyone]/.
sac2 = globglob(sac_dir2, '**/*.sac');
evt2 = globglob(evt_dir2, 'reviewed', '**/*.evt');
fname_sac2 = strippath(sac2, true);
fname_evt2 = strippath(evt2, true);

% These new .sac files have no associated .evt files. 
fname_missing_evt2 = setdiff(fname_sac2, fname_evt2);

% Some of those .evt files are found in the old .evt directory.
[~, need2copy_evt1_idx] = intersect(fname_evt1, fname_missing_evt2);
need2copy_evt1 = evt1(need2copy_evt1_idx);

% Loop over those old .evt files to be copied and write a log file of diffs.
data_differ = {};
data_ct = 0;
max_time = 0;
max_time_sac = '';
max_loc = 0;
max_loc_sac = '';

writeaccess('unlock', logfile, false)
fid = fopen(logfile, 'w');
for i = 1:length(need2copy_evt1)
    needs_indent = false;
    fprintf('%i of %i\n', i, length(need2copy_evt1))

    %% Copy old .evt
    this_evt = need2copy_evt1{i};
    this_evt_fname = strippath(this_evt, true);
    
    % Determine which reviewed subdir to send copy to.
    if contains(this_evt, 'unidentified')
        rev_status = 'unidentified';

    elseif contains(this_evt, 'purgatory')
        rev_status = 'purgatory';

    else
        rev_status = 'identified';

    end
    destination = fullfile(evt_dir2, 'reviewed', rev_status, 'evt');

    % Copy old reviewed .evt to new events/ directory.
    success = copyfile(this_evt, destination);
    if ~success
        error('bad copy')

    end

    %% Write logfile
    % Same .sac file basenames (with potentially different data), just different
    % leading paths, so okay to pick either for basename printing.
    [~, this_sac1] = cellstrfind(sac1, this_evt_fname); 
    this_sac1 = this_sac1{:};
    [~, this_sac2] = cellstrfind(sac2, this_evt_fname);
    this_sac2 = this_sac2{:};
    this_sac_fname = strippath(this_sac1, true);

    % Compare old and new sac timing and location.
    [data, time, loc, x, h, sd] = comparesac(this_sac1, this_sac2);

    % Data diffs
    if ~data
        fprintf(fid, '%s data differ\n', sac)
        data_ct = data_ct + 1;
        data_differ{data_ct} = this_sac_fname;

    end

    % Timing diffs
    tdiff = max(abs(time)); % seconds
    if tdiff > h(1).DELTA
        fprintf(fid, '%s time differs: %6.2f s\n', this_sac_fname, tdiff);
        needs_indent = true;
        
    end
    if tdiff > max_time
        max_time = tdiff;
        max_time_sac = this_sac_fname;

    end

    % Location diffs
    if loc ~= 0 % meters
        if ~needs_indent
            fprintf(fid, '%44s location differs: %4i m\n', this_sac_fname, round(loc));

        else
            fprintf(fid, '%44s location differs: %4i m\n', ' ', round(loc));

        end
    end
    if loc > max_loc
        max_loc = loc;
        max_loc_sac = this_sac_fname;

    end
end
fprintf(fid, '\nMax. time diff: %.6f s (%s)\n', max_time, max_time_sac);
fprintf(fid, 'Max. location diff: %.1f m (%s)\n', max_loc, max_loc_sac);

fclose(fid);
writeaccess('lock', logfile);
fprintf('Wrote: %s\n', logfile)
