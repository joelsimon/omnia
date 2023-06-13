function reviewall(writecp, floatnum, procdir, evtdir)
% REVIEWALL(writecp, floatnum, procdir, evtdir)
%
% Review all unreviewed $MERMAID events using reviewevt.m, assuming
% same system configuration as JDS.
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
% Last modified: 12-Jun-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults.
defval('writecp', false)
defval('floatnum', [])
defval('procdir', fullfile(getenv('MERMAID'), 'processed'))
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))

skip_french = true;

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
    evt = strrep(strippath(d), 'evt', 'sac');

else
    evt = [];

end

% Compile list of all SAC files and compare their differences.
sac = fullsac([], procdir);
if isempty(sac)
    error('No .sac files recursively found in %s\n', procdir)

end
[~, idx] = setdiff(strippath(sac), evt);
sac = sac(idx);

% Skip French floats, maybe.
if skip_french
    rm_idx = find(contains(sac, {'452.020-P-06' '452.020-P-07'}));
    sac(rm_idx) = [];

end

% Loop over in sequential (time) order.
fail = [];
[~, sort_idx] = sort(strippath(sac));
sac = sac(sort_idx);
num_sac = length(sac);
num_rev = num_sac;
for i = 1:num_sac
    fprintf('Remaining SAC to be reviewed: %3i\n', num_rev)
    try
        reviewevt(sac{i}, false, evtdir, viewr);

    catch
        fail = [fail; i];

    end
    num_rev = num_rev - 1;
    clc

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
fid = fopen(fullfile(revevt_dir, 'reviewed', 'reviewall_fail.txt'), 'w');
fprintf(fid, '%s\n', failsac{:});
fclose(fid);
fprintf('\nAll done.\n')
