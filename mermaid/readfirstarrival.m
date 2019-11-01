function varargout = readfirstarrival(filename, fmt)
% [s, ph, tres, tptime, tadj, delay, twosd, maxc_y, SNR, ID, incomplete] = ...
%     READFIRSTARRIVAL(filename, fmt)
%
% Reads and parses textfile output by writefirstarrival.m.
% See there for I/0.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 29-Oct-2019, Version 2017b on GLNXA64

% Default.
defval('filename', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                            'identified', 'txt', 'firstarrival.txt'))
% Data format.
defval('fmt', ['%44s    ' , ...
               '%5s    ' ,  ...
               '%6.2f   ' , ...
               '%8.2f    ', ...
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
tptime = lynes{4};
tadj = lynes{5};
delay = lynes{6};
twosd = lynes{7};
maxc_y = double(lynes{8});
SNR = lynes{9};
ID = lynes{10};
incomplete = lynes{11};

% Collect.
outargs = {s, ph, tres, tptime, tadj, delay, twosd, maxc_y, SNR, ID, incomplete};
varargout = outargs(1:nargout);
