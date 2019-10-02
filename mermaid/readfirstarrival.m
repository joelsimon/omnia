function varargout = readfirstarrival(filename, fmt)
% [s, ph, tres, delay, twosd, maxc_y, SNR, ID, incomplete] = ...
%     READFIRSTARRIVAL(filename, fmt)
%
% Reads and parses output text file of firstarrivals.m
% See there for I/0/
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 02-Oct-2019, Version 2017b on GLNXA64

% Default.
defval('filename', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                            'identified', 'txt', 'firstarrivals.txt'))
% Data format.
defval('fmt', ['%44s    ' , ...
               '%5s    ' ,  ...
               '%6.2f   ' , ...
               '%6.2f   ' , ...
               '%5.2f   ' , ...
               '%19.12f    ' , ...
               '%18.12f    '  , ...
               '%8s    ' , ...
               '%u\n'])

% Read.
fid = fopen(filename, 'r');
lynes = textscan(fid, fmt);
fclose(fid);

% Parse.
s = strtrim(lynes{1});
ph = lynes{2};
tres = lynes{3};
delay = lynes{4};
twosd = lynes{5};
maxc_y = double(lynes{6});
SNR = lynes{7};
ID = lynes{8};
incomplete = lynes{9};

% Collect.
outargs = {s, ph, tres, delay, twosd, maxc_y, SNR, ID, incomplete};
varargout = outargs(1:nargout);
