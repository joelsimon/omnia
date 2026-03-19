function fs = efes(h, rd)
% fs = EFES(h, rd)
%
% Returns the <nominal> sampling frequency of a SAC waveform in Hz.
%
% Input:
% h           Header structure returned by readsac.m
% rd          true to round `fs` to nearest integer (def: true)
%
% Output:
% fs          ROUNDED sampling frequency of the SAC waveform [Hz]
%
% Ex:
%    [~, h] = readsac('centcal.1.BHZ.SAC');
%    fs1 = EFES(h)
%    fs2 = EFES(h, false)
%
% Author: Joel D. Simon <jdsimon@bathymetrix.com>
% Last modified: 19-Mar-2026, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

% Find nominal sampling frequency.
defval('rd', true)

% Pull SAC-derived sampling interval ("DELTA) exists; otherwise compute
if isfield(h, 'NPTS')
    if isfield(h, 'DELTA')
        fs = 1 / h.DELTA;

    else
        fs = (h.NPTS - 1) / (h.E - h.B);

    end
elseif isfield(h, 'npts')
    % Yuck (but this this faster than, e.g., a `structfun` rename...)
    if isfield(h, 'delta')
        fs = 1 / h.delta;

    else
        fs = (h.npts - 1) / (h.e - h.b);

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