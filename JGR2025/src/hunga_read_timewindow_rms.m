function [sac, val] = hunga_read_timewindow_rms(fname)
% [sac, val] = HUNGA_READ_TIMEWINDOW_RMS(fname)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 26-Oct-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

hundir = getenv('HUNGA');
staticdir = fullfile(hundir, 'code', 'static');
fmt = '%5s  |  %9.6f\n';
fname = fullfile(staticdir, fname);
fid = fopen(fname, 'r');
C = textscan(fid, fmt);
fclose(fid);
sac = C{1};
val = C{2};
