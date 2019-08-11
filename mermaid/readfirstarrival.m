function varargout = readfirstarrival(filename)
% [s, ph, tres, delay, twosd, SNR, maxc_y] = READFIRSTARRIVAL(filename)
%
% Reads and parses output text file of firstarrivals.m
% See there for I/0/
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 09-Aug-2019, Version 2017b

% Default.
defval('filename', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                            'identified', 'txt', 'firstarrivals.txt'))
% Data format.
fmt = ['%44s    ' , ...
       '%5s    '  , ...
       '%6.2f    ', ...
       '%6.2f    ', ...
       '%5.2f    ', ...
       '%9.1f    ' , ...
       '%d\n'];

% Read.
fid = fopen(filename, 'r');
lynes = textscan(fid, fmt);
fclose(fid);

% Parse.
s = lynes{1};
ph = lynes{2};
tres = lynes{3};
delay = lynes{4};
twosd = lynes{5};
SNR = lynes{6};
maxc_y = lynes{7};

% Collect.
outargs = {s, ph, tres, delay, twosd, SNR, maxc_y};
varargout = outargs(1:nargout);
