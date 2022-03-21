function fs = efes(h, rd)
% fs = EFES(h, rd)
%
% Returns the nominal sampling frequency of a SAC waveform in Hz,
% rounded to the nearest integer.
%
% Input:
% h           Header structure returned by readsac.m
% rd          true to round `fs` to nearest integer (Def: true)
%
% Output:
% fs          ROUNDED sampling frequency of the SAC waveform [Hz]
%
% Ex:
%    [~, h] = readsac('centcal.1.BHZ.SAC');
%    fs1 = EFES(h)
%    fs2 = EFES(h, false)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 21-Mar-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Find nominal sampling frequency.
defval('rd', true)
if any([h.NPTS h.E h.B] == -12345)
    fs = 1 / h.DELTA;

else
    fs = h.NPTS / (h.E - h.B);

end
if rd
    fs = round(fs);

end