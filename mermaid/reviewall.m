function reviewall(writecp, floatnum)
% REVIEWALL(writecp, floatnum)
%
% Review all unreviewed $MERMAID events using reviewevt.m, assuming
% same system configuration as JDS.
%
% Input:
% writecp   true to run writechangepointall.m after review
%           false to skip running writechangepointall.m (def)
% floatnum  Character array of MERMAID float number, to only review
%               those .evt files associated with it (e.g., '12')
%
% Output:
% N/A       Writes reviewed .evt files, updates .txt files,
%               writes .cp files with uncertainty estimation
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 05-Nov-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

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
sac = sort(strippath(sac));
for i = 1:length(sac)
    reviewevt(sac{i}, [], [], viewr);
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
fprintf('All done.\n')
