function FAP = readfirstarrivalpressurestruct(filename)
% FAP = READFIRSTARRIVALPRESSURESTRUCT(filename)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 10-Dec-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default.
defval('filename', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                            'identified', 'txt', 'firstarrivalpressure.txt'))

[s, ph, RMS, P, magval, magtype, depth, dist, merlat, merlon, evtlat, evtlon, ...
 ID, winflag, tapflag, zerflag] = readfirstarrivalpressure(filename);

FAP.s = s;
FAP.ph = ph;
FAP.RMS = RMS;
FAP.P = P;
FAP.magval = magval;
FAP.magtype = magtype;
FAP.depth = depth;
FAP.dist = dist;
FAP.merlat = merlat;
FAP.merlon = merlon;
FAP.evtlat = evtlat;
FAP.evtlon = evtlon;
FAP.ID = ID;
FAP.winflag = winflag;
FAP.tapflag = tapflag;
FAP.zerflag = zerflag; 
