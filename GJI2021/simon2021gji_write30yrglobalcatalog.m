function simon2021gji_write30yrglobalcatalog
% SIMON2021GJI_WRITE30YRGLOBALCATALOG
%
% Scriptish to write global catalog of all M4-9 (separated by magnitude units)
% events from 1985 to 2015.
%
% This is used compute `historical_num_ev` in tbl1_6.m
%
% 17-Oct-2019: verified there are no 2-decimal places EQs I'm missing
% (e.g., M6.99), by querying the catalog for minmag 6 over same time
% period and see that the sum (4096) is equal to the sum of all lines
% in M6 --> M9 textfiles.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 12-Oct-2019, Version 2017b on GLNXA64

clc
close all

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

txtdir = fullfile(getenv('GJI21_CODE'), 'data', '1985_2015');
[~, foo] = mkdir(txtdir);

minmag = 4;
maxmag = 9;

stime = '1985-01-01T00:00:00.000';
etime = '2015-01-01T00:00:00.000';

writeglobalcatalog(minmag, maxmag, stime, etime, txtdir);
