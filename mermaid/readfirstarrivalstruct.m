function FA = readfirstarrivalstruct(filename)
% FA = READFIRSTARRIVALSTRUCT(filename)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 16-Aug-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default.
defval('filename', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                            'identified', 'txt', 'firstarrival.txt'))

[s, ph, dat, tres, tptime, tadj, delay, twosd, maxc_y, SNR, ID, winflag, tapflag, zerflag, pt0] = ...
    readfirstarrival(filename);

FA.s = s;
FA.ph = ph;
FA.dat = dat;
FA.tres = tres;
FA.tptime = tptime;
FA.tadj = tadj;
FA.dely = delay;
FA.twosd = twosd;
FA.maxc_y = maxc_y;
FA.SNR = SNR;
FA.winflag = winflag;
FA.tapflag = tapflag;
FA.zerflag = zerflag;
FA.pt0 = pt0;
