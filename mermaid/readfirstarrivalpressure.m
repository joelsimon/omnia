function varargout = readfirstarrivalpressure(filename, fmt)
% [s, ph, RMS, P, magval, magtype, depth, dist, merlat, merlon, evtlat, ...
%     evtlon, ID, incomplete] = READFIRSTARRIVALPRESSURE(filename, fmt)
%
% Reads and parses textfile output by writefirstarrivalpressure.m.
% See there for I/0.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 31-Oct-2019, Version 2017b on GLNXA64

% Default.
defval('filename', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                            'identified', 'txt', 'firstarrivalpressure.txt'))
% Data format.
defval('fmt', ['%44s    ' , ...
               '%5s    ' ,  ...
               '%18.12f    ' , ...
               '%6.2f   ' ,  ...
               '%4.1f    ',  ...
               '%5s    ',    ...
               '%6.2f    ',  ...
               '%7.3f    ' , ...
               '%7.3f    ' , ...
               '%8.3f    ' , ...
               '%7.3f    ' , ...
               '%8.3f    ' , ...
               '%8s   ',     ...
               '%u\n'])

% Read.
fid = fopen(filename, 'r');
lynes = textscan(fid, fmt);
fclose(fid);

% Parse.
s = strtrim(lynes{1});
ph = lynes{2};
RMS = lynes{3};
P = lynes{4};
magval = lynes{5};
magtype = lynes{6};
depth = lynes{7};
dist = lynes{8};
merlat = lynes{9};
merlon = lynes{10};
evtlat = lynes{11};
evtlon = lynes{12};
ID = lynes{13};
incomplete = lynes{14};

% Collect.
outargs = {s, ph, RMS, P, magval, magtype, depth, dist, merlat, ...
           merlon, evtlat, evtlon, ID, incomplete};
varargout = outargs(1:nargout);
