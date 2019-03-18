function fs = efes(h)
% fs = EFES(h)
%
% Returns the nominal sampling frequency of a SAC waveform in Hz,
% rounded to the nearest integer.
%
% Input:
% h           Header structure returned by readsac.m
%
% Output:
% fs          ROUNDED sampling frequency of the SAC waveform [Hz]
%
% Ex:
%    [~, h] = readsac('centcal.1.BHZ.SAC');
%    fs = EFES(h)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 01-Feb-2018, Version 2017b

% Find nominal sampling frequency .
fs = round(h.NPTS / (h.E - h.B));
