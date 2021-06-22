function simon2021gji_smallest_event
% SIMON2021GJI_SMALLEST_EVENT
%
% Prints smallest/largest events in catalog.
%
% Developed as: smallest_event.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 27-Mar-2020, Version 2017b on MACI64

% Define paths.
merdir = getenv('MERMAID');
procdir = fullfile(merdir, 'processed');
evtdir = fullfile(merdir, 'events');

% Ensure in GJI21 git branch -- complimentary paper w/ same data set.
startdir = pwd;
cd(procdir)
system('git checkout GJI21');
cd(evtdir)
system('git checkout GJI21');
cd(startdir)

enddate = datetime('31-Dec-2019 23:59:59.999', 'TimeZone', 'UTC');
returntype = 'DET';
savepath = fullfile(getenv('GJI21_CODE'), 'data');
idfilepath = fullfile(evtdir, 'events', 'reviewed', 'identified', 'txt');

[sac, eqtime, eqlat, eqlon, eqregion, eqdepth, eqdist, eqmag, eqphase1, eqid, sacdate, eqdate] = ...
    readidentified([], [], enddate, 'SAC', 'DET');

% Smallest (there is only one).
if length(find(eqmag == min(eqmag))) > 1
    error('More than on MERMAID recorded the min magnitude')

end
[~, idx] = min(eqmag);
EQ = getevt(sac{idx});

fprintf('smallest:\n')
EQ(1).FlinnEngdahlRegionName
EQ(1).PreferredMagnitudeType
EQ(1).PreferredMagnitudeValue
EQ(1).PreferredDepth
EQ(1).TaupTimes(1).distance

% Largest

% Just take first one.
[~, idx] = max(eqmag);
EQ = getevt(sac{idx});

fprintf('largest:\n')
EQ(1).FlinnEngdahlRegionName
EQ(1).PreferredMagnitudeType
EQ(1).PreferredMagnitudeValue
EQ(1).PreferredDepth
% EQ(1).TaupTimes(1).distance distance meaningless -- mtuliple recording MERMAIDs.


% Most shallow.
fprintf('shallowest:\n')
[~, idx] = min(eqdepth);
EQ = getevt(sac{idx});
EQ(1).PreferredDepth
EQ(1).FlinnEngdahlRegionName

% Deepest
fprintf('deepest:\n')
[~, idx] = max(eqdepth);
EQ = getevt(sac{idx});
EQ(1).PreferredDepth
EQ(1).FlinnEngdahlRegionName
