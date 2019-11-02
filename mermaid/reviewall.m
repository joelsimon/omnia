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
% Contact: jdsimon@princeton.edu
% Last modified: 02-Nov-2019, Version 2017b on GLNXA64

% Defaults.
defval('writecp', false)
defval('floatnum', [])

% Swtich the .pdf viewer depending on the platform.
switch computer
  case 'MACI64'
    viewr = 3;

otherwise
  viewr = 2;

end

% Grab directory containing the raw .evt files.  Loop over each
% .raw.evt file below and check if there is a corresponding reviewed
% .evt file; if not, review it.
if isempty(floatnum)
    d = skipdotdir(dir(fullfile(getenv('MERMAID'), 'events', 'raw', 'evt')));

else
    % Review only those .evt files associated with a specific floatnum.
    if isnumeric(floatnum)
        floatnum = num2str(floatnum);

    end
    floats = sprintf('*.%s_*evt', floatnum);
    d = skipdotdir(dir(fullfile(getenv('MERMAID'), 'events', 'raw', 'evt', floats)));

end

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
        reviewevt(sac, [], [], viewr);

    end
    clc
    fprintf('Searching for unreviewed SAC files...\n')

end
clc
fprintf('Manual review complete...\n')

fprintf('Updating event text files...\n')
evt2txt;

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
