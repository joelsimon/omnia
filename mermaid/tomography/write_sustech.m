function write_sustech
% WRITE_SUSTECH
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu | joeldsimon@gmail.com
% Last modified: 02-Nov-2023, Version 9.3.0.713579 (R2017b) on GLNXA64

merdir = getenv('MERMAID');
sacdir = fullfile(merdir, 'processed_sustech');
evtdir = fullfile(merdir, 'events_sustech');

f1 = fullfile(evtdir, 'reviewed', 'identified', 'txt', 'firstarrival.txt');
f2 = fullfile(evtdir, 'reviewed', 'identified', 'txt', 'firstarrivalpressure.txt');

evt2txt(sacdir, evtdir, false);

writefirstarrival([], true, f1, [], [], sacdir, evtdir);
writefirstarrivalpressure([], true, f2, [], [], sacdir, evtdir);