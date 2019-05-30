function reviewall(writecp)
% REVIEWALL(writecp)
%
% Review all unreviewed $MERMAID events using reviewevt.m, assuming
% same system configuration as JDS.
% 
% Input:
% writecp   true to run writechangepointall.m after review (def)
%           false to skip running writechangepointall.m
%
% Output:
% N/A       Writes reviewed .evt files, updates .txt files, 
%               writes .cp files with uncertainty estimation
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 17-May-2019, Version 2017b

clc
defval('writecp', true)

fprintf('Searching for unreviewed SAC files...\n')

% Load the list (a cell) of all processed SAC filenames saved by
% matchall.m.  This list allows you to match events remotely with just
% the $MERMAID/events directory and without requiring you physically
% have the data.
load(fullfile(getenv('MERMAID'), 'events', 'sacfiles.mat'))
for i = 1:length(s)
    previously = getevt(s{i});
    if isstruct(previously) || isempty(previously)
        % Output of getevt either a structure or isempty; in either case the
        % SAC file has been previously reviewed (otherwise, getevt
        % returns NaN).
        continue

    else
        clc
        reviewevt(s{i});

    end
    clc
    fprintf('Searching for unreviewed SAC files...\n')

end
clc
fprintf('Manual review complete...\n')
fprintf('Updating event text files...\n')
evt2txt;

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
