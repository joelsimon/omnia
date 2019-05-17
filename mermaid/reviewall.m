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

s = fullsac;
fprintf('Searching for unreviewed SAC files...\n')
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
    fprintf('Writing .cp files with error estimates...\n')
    writechangepointall

end
fprintf('All done.\n')
