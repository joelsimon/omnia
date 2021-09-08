function reviewall(writecp, floatnum)
% REVIEWALL(writecp, floatnum)
%
% Review all unreviewed $MERMAID events using reviewevt.m, assuming
% same system configuration as JDS.
%
% Input:
% writecp   true to run writechangepointall.m after review
%           false to skip running writechangepointall.m (def: false)
% floatnum  Character array of MERMAID float number, to only review
%               those .evt files associated with it (e.g., '12')
%
% Output:
% N/A       Writes reviewed .evt files, updates .txt files,
%               writes .cp files with uncertainty estimation
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 08-Sep-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults.
defval('writecp', false)
defval('floatnum', [])

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
d = recursivedir(dir(fullfile(getenv('MERMAID'), 'events', 'reviewed', '**/*.evt')));
evt = strrep(strippath(d), 'evt', 'sac');

% Compile list of all SAC files and compare their differences.
sac = fullsac([], fullfile(getenv('MERMAID'), 'processed'));
[~, idx] = setdiff(strippath(sac), evt);
sac = sac(idx);

% Loop over in sequential (time) order.
fail = [];
[~, sort_idx] = sort(strippath(sac));
sac = sac(sort_idx);
for i = 1:length(sac)
    % Skip the French floats.
    if contains(sac{i}, '452.020-P-06') || contains(sac{i}, '452.020-P-07')
        continue

    end

    try
        reviewevt(sac{i}, [], [], viewr);

    catch
        fail = [fail; i];

    end
    clc

end
clc
fprintf('Manual review complete...\n')

fprintf('Updating event text files...\n')
evt2txt;
writelatlon;

fprintf('Updating first arrival text files...\n')
%writefirstarrival;
%writefirstarrivalpressure;

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
fid = fopen(fullfile(getenv('MERMAID'), 'events', 'reviewed', 'reviewall_fail.txt'), 'w');
fprintf(fid, '%s\n', failsac{:});
fclose(fid);
fprintf('\nAll done.\n')
