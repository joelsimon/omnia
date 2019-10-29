function varargout = readfirstarrival(filename, fmt)
% [s, ph, tres, tptime, delay, twosd, maxc_y, SNR, ID, incomplete] = ...
%     READFIRSTARRIVAL(filename, fmt)
%
% Reads and parses textfile output by writefirstarrivals.m.
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
delay = lynes{5};
twosd = lynes{6};
maxc_y = double(lynes{7});
SNR = lynes{8};
ID = lynes{9};
incomplete = lynes{10};

% Collect.
outargs = {s, ph, tres, tptime, delay, twosd, maxc_y, SNR, ID, incomplete};
varargout = outargs(1:nargout);
