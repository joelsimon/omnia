function varargout = readfirstarrival(filename)
% [s, ph, dat, tres, tptime, tadj, delay, twosd, maxc_y, SNR, ID, winflag, tapflag, zerflag, pt0] = ...
%     READFIRSTARRIVAL(filename)
%
% Reads and parses textfile output by writefirstarrival.m.
% See there for I/0.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 16-Aug-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default.
defval('filename', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                            'identified', 'txt', 'firstarrival.txt'))
% Textfile format.
fmt = ['%45s    ' , ...
       '%11s    ' ,  ...
       '%7.2f   ' , ...
       '%6.2f   ' , ...
       '%8.2f    ', ...
       '%6.2f   ' , ...
       '%6.2f   ' , ...
       '%5.2f   ' , ...
       '%19.12f    ' , ...
       '%18.12f    '  , ...
       '%8s    ' , ...
       '%1u    ', ...
       '%3s    ', ...
       '%3s    ', ...
       '%6.3f\n'];

% Read.
fid = fopen(filename, 'r');
lynes = textscan(fid, fmt);
fclose(fid);

% Parse.
s = strtrim(lynes{1});
ph = lynes{2};
dat = lynes{3};
tres = lynes{4};
tptime = lynes{5};
tadj = lynes{6};
delay = lynes{7};
twosd = lynes{8};
maxc_y = double(lynes{9});
SNR = lynes{10};
ID = lynes{11};
winflag = double(lynes{12});
tapflag = str2double(lynes{13});
zerflag = str2double(lynes{14});
pt0 = lynes{15};

% Collect.
outargs = {s, ph, dat, tres, tptime, tadj, delay, twosd, maxc_y, ...
           SNR, ID, winflag, tapflag, zerflag, pt0};
varargout = outargs(1:nargout);
