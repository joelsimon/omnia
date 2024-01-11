function [dax, sd] = sacaxis(h)
% [dax, sd] = SACAXIS(h)
%
% Return datetime axis given SAC header.
%
% Input:
% h       SAC header
%
% Output:
% dax     Datetime X-axis
% sd      Structure of start (".B") and end (".E") datetimes of seismogram
%
% Ex:
%    [x, h] = readsac('20180629T170731.06_5B3F1904.MER.DET.WLT5.sac');
%    dax = SACAXIS(h);
%    plot(dax, x)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 10-Jan-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

sd = seistime(h);
dax = datexaxis(h.NPTS, h.DELTA, sd.B);
