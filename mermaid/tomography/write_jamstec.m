function write_jamstec
% WRITE_JAMSTEC
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu | joeldsimon@gmail.com
% Last modified: 04-Dec-2023, Version 9.3.0.713579 (R2017b) on GLNXA64

merdir = getenv('MERMAID');
sacdir = fullfile(merdir, 'processed_jamstec');
evtdir = fullfile(merdir, 'events_jamstec');
txtdir = fullfile(merdir, 'events_jamstec', 'reviewed', 'identified', 'txt');

f1 = fullfile(txtdir, 'firstarrival.txt');
f2 = fullfile(txtdir, 'firstarrivalpressure.txt');
f3 = fullfile(evtdir, 'reviewer.txt');

evt2txt(sacdir, evtdir, false);
writefirstarrival([], true, f1, [], [], sacdir, evtdir);
writefirstarrivalpressure([], true, f2, [], [], sacdir, evtdir);
write_tomocat1(true, sacdir, evtdir, txtdir, f3);

