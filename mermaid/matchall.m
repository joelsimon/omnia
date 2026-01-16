function matchall(writecp, procdir, evtdir, evtdir2)
% MATCHALL(writecp, procdir, evtdir, evtdir2)
%
% !! Must be run in versioin R2022b or earlier !!
%
% Matches all unmatched $MERMAID SAC files to the IRIS database using
% cpsac2evt.m and its defaults, assuming same system configuration as JDS.
%
% Input:
% writecp    true to write changepoint (.cp) files (def: false)
% procdir    Path to processed directory (def: $MERMAID/processed/)
% evtdir     Path to events directory to check for existing and save new
%                if .evt is not already matched (def: $MERMAID/events/)
% evtdir2*   (optional) Path to events secondary directory to check if
%                .evt is already matched.
%
% A list of any files which are unsuccessfully matched using
% cpsac2evt.m are saved as 'matchall_fail.txt' $MERMAID/events (or
% empty if all successfully matched).
%
% % *Ex:
%    writecp = false;
%    procdir = '~/mermaid/processed_everyone';
%    evtdir = '~/mermaid/events_everyone';
%    evtdir2 = '~/mermaid/events/';
%    MATCHALL(writecp, procdir, evtdir, evtdir2)
%
% Author: Joel D. Simon <jdsimon@bathymetrix.com>
% Last modified: 16-Jan-2026, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

clc

% irisFetch stopped working after version 22b
if ~verLessThan('matlab', '9.14')
    error('Must run in R2022b or earlier')

end

skip_french = false;
skip_0100 = false;
princeton_only = false;

% Defauls.
defval('writecp', false)
defval('procdir', fullfile(getenv('MERMAID'), 'processed'))
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('evtdir2', [])

% Find only those SAC files which have not been preliminary matched.
all_sac = fullsac([], procdir);
if isempty(all_sac)
    error('No SAC files found %s\n', procdir)

end
if isempty(all_sac)
    error('No .sac files recursively found in %s\n', procdir)

end

% It is insufficient to only compare .sac list with list of .raw.evt because in
% many cases I did not copy .raw.evt from collaborators (e.g., when taking in
% Yong's and Yuko's data I only copied over their reviewed .evt files).
% Therefore, just glob all .evt files in the dir and keep the unique list.
all_evt = globglob(evtdir, '**/*.evt');
if ~isempty(all_evt)
    all_evt = unique(strippath(strrep(all_evt, '.raw', '')));
    matched_sac = strrep(all_evt, '.evt', '.sac'); % Not necessarily reviewed!
    [~, idx] = setdiff(strippath(all_sac), strippath(matched_sac));
    s = all_sac(idx);

else
    % No .evt files found in evtdir (e.g., running fresh or in new diro)
    s = all_sac;

end

% Loop over the unmatched SAC files.
fail = [];
fprintf('Searching for unmatched SAC files...\n')
for i = 1:length(s)
    [x, h] = readsac(s{i});
    if princeton_only
        if ~princeton_kstnm(h.KSTNM)
            continue

        end
    end

    if skip_french
        if contains(s{i}, '452.020-P-06') || contains(s{i}, '452.020-P-07')
            continue

        end
    end

    if skip_0100 && contains(s{i}, '467.174-T-0100')
            continue

    end

    fprintf('\nMatching .sac %i of %i\n', i, length(s))

    % Get wavelet scale
    scale_idx = strfind(s{i}, 'WLT');
    if ~isempty(scale_idx)
        n = str2double(s{i}(scale_idx + 3));

    else
        % It's a raw 40-Hz signal; decompose to 6 wavelet scales in keeping with
        % 3 scales -> 5 Hz; 4 scales -> 10 Hz; 5 scales -> 20 Hz etc.
        n = 6;

    end

    %% Temp patch to skip really long REQ files (need to update (i)wtspy.m
    %% routines to handle longer time series / shortcut those functions?).
    if length(x) > 10000
        % Check if I have manually added a reviewed-only .evt file.
        if ~isreviewed(s{i})
                fprintf('Skipping...%s\n', strippath(s{i}))
                fail = [fail i];

        end
        continue

    end

    % Write raw event (.raw.evt) files.
    try
        cpsac2evt(s{i}, false, 'time', n, [], [], [], [], [], evtdir);

    catch ME
        fail = [fail i];

    end
    close all

end

% Write changepoint (.cp) files.
if writecp
    fprintf('Writing changepoint files...\n')
    writechangepointall;

end

% Make note of the SAC files that failed to be properly processed by cpsac2evt.m.
if ~isempty(fail)
    failsac = s(fail);
    failsac = cellfun(@(xx) strippath(xx), failsac, 'UniformOutput', ...
                      false);
    warning(['These SAC files were not matched:\n' ...
             repmat('%s\n', 1, length(failsac))], failsac{:})

else
    failsac = {};

end
fid = fopen(fullfile(evtdir, 'raw', 'matchall_fail.txt'), 'w');
fprintf(fid, '%s\n', failsac{:});
fclose(fid);
fprintf('\nAll done.\n')
