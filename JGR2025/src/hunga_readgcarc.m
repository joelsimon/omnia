function [kstnm, gcarc] = hunga_readgcarc()
% [kstnm, gcarc] = HUNGA_READGCARC
%
% Reads $HUNGA/sac/meta/gcarc.txt and returns cells of station names and their
% epicentral distances.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 07-Jun-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

hundir = getenv('HUNGA');
sacdir = fullfile(hundir, 'sac');
metadir = fullfile(sacdir, 'meta');
fname = fullfile(metadir, 'gcarc.txt');

fmt = '%5s %8.4f\n';
fid = fopen(fname, 'r');
C = textscan(fid, fmt);
fclose(fid);

kstnm = C{1};
gcarc = C{2};
