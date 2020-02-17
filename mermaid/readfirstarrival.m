function varargout = readfirstarrival(filename, fmt)
% [s, ph, tres, tptime, tadj, delay, twosd, maxc_y, SNR, ID, winflag, tapflag, zerflag] = ...
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
               '%u    ', ...
               '%3s    ', ...
               '%u\n']);
               
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
winflag = double(lynes{11});
tapflag = str2double(lynes{12});
zerflag = double(lynes{13});

% Collect.
outargs = {s, ph, tres, tptime, tadj, delay, twosd, maxc_y, SNR, ID, ...
           winflag, tapflag, zerflag};
varargout = outargs(1:nargout);
