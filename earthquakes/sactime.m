function [seisdate, seiststr, seisertime, refdate, evtdate] = sactime(sac)
% [seisdate, seiststr, seisertime, refdate, evtdate] = SACTIME(sac)
%
% Wrapper for `seistime` that take sac filename instead of SAC header as
% input.  See there for I/O.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 17-Jan-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

h = sachdr(sac);
[seisdate, seiststr, seisertime, refdate, evtdate] = seistime(h);
