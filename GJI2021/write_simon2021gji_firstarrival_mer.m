function write_simon2021gji_firstarrival_mer
% WRITE_SIMON2021GJI_FIRSTARRIVAL_MER
%
% This writes FOR MERMAID FLOATS:
%
% mer.firstarrival.all.txt
% mer.firstarrivalpressure.all.txt
%
% For ALL events recorded through by MERMAID 2019; i.e., not winnowed for p or P
% phase only.
%
% Developed as: simon2020_writefirstarrival.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 08-Mar-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

% Define paths.
merdir = getenv('MERMAID');
procdir = fullfile(merdir, 'processed');
evtdir = fullfile(merdir, 'events');
nearbydir = fullfile(evtdir, 'nearbystations');

% Ensure in GJI21 git branch.
startdir = pwd;
cd(procdir)
system('git checkout GJI21');
cd(evtdir)
system('git checkout GJI21');
cd(startdir)

% Paths to the relevant ID file and other necessary directories.
id_txtfile =  fullfile(evtdir, 'reviewed', 'identified', 'txt', 'identified.txt');
datadir = fullfile(getenv('GJI21_CODE'), 'data');

% Parameters for firstarrival textfile.
wlen = 30;
lohi = [1 5];
bathy = true;
wlen2 = [1.75];
fs = 20; % Decimation is a pass-through function when R = 1 (which it does at fs = 20).
popas = [4 1];
pt0 = 0; % Set arrival times w.r.t. to first sample of seismogram, not SAC reference time

% Nab all the DET SAC files recorded through 2019.
endtime = datetime('31-Dec-2019 23:59:59.999', 'TimeZone', 'UTC');
mer_sac = readidentified(id_txtfile, [], endtime, 'SAC', 'DET');

% Remove any preliminary-location SAC files (in early Mar. 2021 I was playing
% with this feature in automaid v3.4.0-7)
mer_sac(cellstrfind(mer_sac, 'prelim')) = [];

% Output filenames.
mer_det_txt1 = fullfile(datadir, 'mer.firstarr.all.txt');
mer_det_txt2 = fullfile(datadir, 'mer.firstarrpress.all.txt');

% Write them.
writefirstarrival(mer_sac, true, mer_det_txt1, wlen, lohi, procdir, ...
                  evtdir, [], bathy, wlen2, fs, popas, pt0);
writefirstarrivalpressure(mer_sac, true, mer_det_txt2, wlen, lohi, ...
                          procdir, evtdir, [], bathy, wlen2, fs, popas, pt0);
