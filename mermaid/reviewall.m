% Script to review all unreviewed $MERMAID events using reviewevt.m,
% assuming same system configuration as JDS.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 10-May-2019, Version 2017b

clear
close all

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
fprintf('All done.\n')
