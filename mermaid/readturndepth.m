function [sac, phasename, turndepth, turnlat, turnlon] = readturndepth(savefile)
% [sac, phasename, turndepth, turnlat, turnlon] = READTURNDEPTH(savefile)
%
% Reads and parses the textfile of turning depths and locations
% written with writeturndepth.m
%
% Input:
% savefile     Filename of textfile written with writeturndepth.m
%
% Output:
% sac          SAC filename
% phasename    Phase name of first-arriving phase of first associated event
% turndepth    Turning depth (km)
% turnlat      Latitude at turning depth (decimal degrees)
% turnlon      Longitude at turning depth (decimal degrees)
%
% See also: writeturndepth.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 19-Nov-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default.
defval('savefile', fullfile(merpath, 'events', 'reviewed', 'identified', 'txt', 'turndepth.txt'))

% Textfile format.
fmt = ['%44s    ', ...
       '%5s    ', ...
       '%7.2f    ', ...
       '%7.3f    ', ...
       '%8.3f\n'];

% Read.
fid = fopen(savefile, 'r');
lynes = textscan(fid, fmt);
fclose(fid);

% Parse the data.
sac = lynes{1};
phasename = lynes{2};
turndepth = lynes{3};
turnlat = lynes{4};
turnlon = lynes{5};
