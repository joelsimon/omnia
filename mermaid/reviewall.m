function reviewall(writecp, floatnum, procdir, evtdir)
% REVIEWALL(writecp, floatnum, procdir, evtdir)
%
% Review all unreviewed $MERMAID events using reviewevt.m, assuming
% same system configuration as JDS.
%
% Use, e.g., `eqdet(EQ, 2)` to see phase/times in EQ(2).
%
% Input:
% writecp   true to run writechangepointall.m after review
%           false to skip running writechangepointall.m (def: false)
% floatnum  Character array of MERMAID float number, to only review
%               those .evt files associated with it (e.g., '12')
% procdir   Path to processed directory (def: $MERMAID/processed/)
% evtdir    Path to events directory (def: $MERMAID/events/)
%
% Output:
% N/A       Writes reviewed .evt files, updates .txt files,
%               writes .cp files with uncertainty estimation
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 09-Oct-2025, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

% Defaults.
defval('writecp', false)
defval('floatnum', [])
defval('procdir', fullfile(getenv('MERMAID'), 'processed'))
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))

skip_french = true;
skip_0100 = true;
skip_mag3 = true;

% Switch the .pdf viewer depending on the platform.
switch computer
  case 'MACI64'
    viewr = 3;

otherwise
  viewr = 2;

end


clc
fprintf('Searching for unreviewed SAC files...\n')

% Compile list of reviewed SAC files by inspecting the list of reviewed .evt files.
revevt_dir = fullfile(evtdir, 'reviewed');
d = recursivedir(dir(fullfile(revevt_dir, '**/*.evt')));
if ~isempty(d)
    revsac = strrep(strippath(d), 'evt', 'sac');

else
    revsac = [];

end

%% >>
%% Option 1 (better): compare list of reviewed and unreviewed events.
unrevevt_dir = fullfile(evtdir, 'raw', 'evt');
unrevevt = fullfiledir(skipdotdir(dir(unrevevt_dir)));
if ~isempty(unrevevt)
    unrevsac = strrep(strippath(unrevevt), 'raw.evt', 'sac');

else
    unrevsac = [];

end
sac = setdiff(unrevsac, revsac);

%% Option 2 (original/worse): compare lists unreviewed events and all
%% processed SAC files (will fail if, e.g.,  you didn't make a raw.evt file for a
%% non-Princeton float)
% % Compile list of all SAC files and compare their differences.
% sac = fullsac([], procdir);
% if isempty(sac)
%     error('No .sac files recursively found in %s\n', procdir)

% end
% [~, idx] = setdiff(strippath(sac), evt);
% sac = sac(idx);
%% <<

% Skip French floats, maybe.
if skip_french
    rm_idx = cellstrfind(sac, {'.06_' '.07_'});
    sac(rm_idx) = [];

end

if skip_0100
    rm_idx = find(contains(sac, '467.174-T-0100'));
    sac(rm_idx) = [];

end

% Loop backwards in time (most recent first).
fail = [];
[~, sort_idx] = sort(strippath(sac));
sac = sac(sort_idx);
num_sac = length(sac);
num_rev = num_sac;
for i = num_sac:-1:1
    fprintf('Remaining SAC to be reviewed: %3i\n', num_rev)
    num_rev = num_rev - 1;

    % Skip review of REQ
    if contains(strippath(sac{i}), 'REQ')
        warning(sprintf('Skipping review (REQ): %s\n', strippath(sac{i})))
        continue

    end

    if skip_mag3 && EQ_mag3(sac{i}, evtdir)
        warning('Skipping %s (< mag. 3, or empty)\n', strippath(sac{i}))
        continue

    end
    try
        reviewevt(sac{i}, false, evtdir, viewr);

    catch
        fprintf('Skipping...%s\n', strippath(sac{i}))
            fail = [fail; i];

    end
end
clc
fprintf('Manual review complete...\n')

fprintf('Updating event text files...\n')
evt2txt;
writelatlon;

fprintf('Updating first arrival text files...\n')
writefirstarrival;
writefirstarrivalpressure;

if writecp
    try
        fprintf('Writing .cp files with error estimates...\n')
        writechangepointall

    catch
        % This warning will trip if you do not have the actual waveform data
        % saved locally (e.g., Joel on his Mac).
        warning('Unable to write .cp files...see note in code.')

    end
end

if ~isempty(fail)
    failsac = strippath(sac(fail));
    failsac = cellfun(@(xx) strippath(xx), failsac, 'UniformOutput', ...
                      false);
    warning(['These SAC files were not reviewed:\n' ...
             repmat('%s\n', 1, length(failsac))], failsac{:})

else
    failsac = {};

end
fid = fopen(fullfile(revevt_dir, 'reviewall_fail.txt'), 'w');
fprintf(fid, '%s\n', failsac{:});
fclose(fid);
fprintf('\nAll done.\n')

%% ___________________________________________________________________________ %%

function mag3 = EQ_mag3(sac, evtdir)
% Returns mag3=true if EQ(1) less than mag. 3 and greater than 10 deg.

mag3 = false;
[~, EQ] = getevt(sac, evtdir);
if isempty(EQ)
    mag3 = true;
    return

end

mag = EQ(1).PreferredMagnitude.Value;
dist = EQ(1).TaupTimes(1).distance;
if mag < 3 && dist > 10
    mag3 = true;

end
