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
% Last modified: 28-Mar-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Find nominal sampling frequency.
defval('rd', true)

% Pull SAC-derived sampling interval ("DELTA) exists; otherwise compute
if isfield(h, 'NPTS')
    if any([h.NPTS h.E h.B] == -12345)
        fs = 1 / h.DELTA;

    else
        fs = h.NPTS / (h.E - h.B);

    end
elseif isfield(h, 'npts')
    % Yuck (but this this faster than, e.g., a `structfun` rename...)
    if any([h.npts h.e h.b] == -12345)
        fs = 1 / h.delta;

    else
        fs = h.npts / (h.e - h.b);

    end
    warning(sprintf(['Why are you using nonstandard (lowercase) SAC header fields?\n' ...
                     'http://www.adc1.iris.edu/files/sac-manual/manual/file_format.html']))

else
    error('input does not appear to be SAC header')

end

% Round it, maybe
if rd
    fs = round(fs);

end