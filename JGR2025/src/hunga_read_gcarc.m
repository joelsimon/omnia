function [kstnm, gcarc] = hunga_read_gcarc
% [kstnm, gcarc] = HUNGA_READ_GCARC
%
% Reads $HUNGA/sac/meta/gcarc.txt and returns cells of station names and their
% epicentral distances.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 15-Aug-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

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
