function BSSA2020_update_evt_files
% BSSA2020_update_evt_files
%
% !! DOES NOT UPDATE raw/*.evt !!
%
% Single-use script to update timing of reviewed GeoAzur EQ structures, after it
% was discovered they were written using the incorrect seistime.m (pre-v1.0.0),
% which improperly formatted the header NZMSEC.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 23-Aug-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Load data.
defval('sac_diro', getenv('MERAZUR'));
defval('rematch_diro', fullfile(getenv('MERAZUR'), 'rematch'));
defval('evt_diro', fullfile(rematch_diro, 'reviewed', 'identified', 'evt'))

s = mermaid_sacf('id', sac_diro);

fname_time = fullfile(evt_diro, 'updated_timing');
fid_time = fopen(fname_time, 'w');

fname_press = fullfile(evt_diro, 'updated_pressure');
fid_press = fopen(fname_press, 'w');

for i = 1:length(s)
    i
    sac_file = s{i};
    sac_str = sprintf('%s (i = %3i)\n', strippath(sac_file), i);

    evt_name = strrep(strippath(sac_file), '.sac', '.evt');
    evt_file = fullfile(evt_diro, evt_name);

    [isupdated, new_EQ, old_EQ] = updatetauptimes(sac_file, evt_file);

    [~, h] = readsac(sac_file);

    if isupdated
        if h.NZMSEC < 100 && h.NZMSEC ~= 0
            % Should update for NZMSEC <= 99 (length 2 number improperly formatted for
            % length 3 str), except for h.NZMSEC = 0, whose formatting is irrelevant
            fprintf(fid_time, sac_str)

        elseif isequal(rmfield(new_EQ.TaupTimes, 'pressure'), rmfield(old_EQ.TaupTimes, 'pressure'))
            fprintf(fid_press, sac_str)

            % % E.g., m12.20150306T082259.sac
            % %
            % % For some reason it appears that the the "Pn/g" and "Sn/g" phases were
            % % printing the full [1 x 2] output of `reid` (P and S) as opposed to
            % % just one or the other. I went back and reran with $OMNIA at their time of
            % % creation and cannot replicate error. I don't know the cause...must
            % % have popped up during some `updateevt`-esque run on the GeoAzur
            % % data.  I verified this to be the case with these lines.  Also,
            % % reflections (PP and PKIKP) were previously printing with
            % % pressures and now they are returned empty, creating another diff.
            % %
            % % Bug: these are all [1 x 2]
            % disp('double')
            % old_EQ.TaupTimes(find(contains({old_EQ.TaupTimes.phaseName}, {'Pn', 'Sn', 'Pg', 'Sg'}))).pressure
            % % These are all [1 x 1]
            % disp('single')
            % old_EQ.TaupTimes(find(~contains({old_EQ.TaupTimes.phaseName}, {'Pn', 'Sn', 'Pg', 'Sg'}))).pressure
            % keyboard
            % clc

        else
            error(fprintf('%s updated for unknown reason\n', sac_str))

        end
    else
        if h.NZMSEC < 100 && h.NZMSEC ~= 0
            error(fprintf('%s should have updated\n', sac_str))

        end
    end
end

writeaccess('lock', fname_time)
writeaccess('lock', fname_press)

fprintf('Wrote %s\n', fname_time)
fprintf('Wrote %s\n', fname_press)
