function reviewall(writecp)
% REVIEWALL(writecp)
%
% Review all unreviewed $MERMAID events using reviewevt.m, assuming
% same system configuration as JDS.
% 
% Input:
% writecp   true to run writechangepointall.m after review
%           false to skip running writechangepointall.m (def)
%
% Output:
% N/A       Writes reviewed .evt files, updates .txt files, 
%               writes .cp files with uncertainty estimation
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 01-Jun-2019, Version 2017b

% Default.
defval('writecp', false)

% Grab directory containing the raw .evt files.  We will loop over
% each .raw.evt file below and check if there is a corresponding
% reviewed .evt file; if not, we review.
d = skipdotdir(dir(fullfile(getenv('MERMAID'), 'events', 'raw', 'evt')));

clc
fprintf('Searching for unreviewed SAC files...\n')
for i = 1:length(d)
    sac = strrep(d(i).name, '.raw.evt', '.sac');
    previously = getevt(sac);
    if isstruct(previously) || isempty(previously)
        % Output of getevt either a structure or isempty; in either case the
        % SAC file has been previously reviewed (otherwise, getevt
        % returns NaN).
        continue

    else
        clc
        reviewevt(sac, [], [], 2);

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
