function [x, h] = decimatesac(x, h, fs, shift)
% [x, h] = DECIMATESAC(x, h, fs, shift)
%
% Decimate SAC time series to requested frequency.  Rounds frequencies to
% nearest integer, which introduces some slop into the timing of the output.
%
% Rounding and decimation causes a resampling that can alter total length (time
% duration) of the signal. By default the output time series is set to begin at
% (but perhaps not end at) the same time as the input time series, but by
% request the output may be time shifted so that instead the original and output
% end times (but perhaps not their start times) match.
%
% Input:
% x       SAC time series
% h       SAC header
% fs      Requested new (lower) sampling frequency [Hz]
% shift   false: do not time shift output times series;
%                start times of original and output match, but end times may not (def)
%         true: time shift output time series;
%                end times of original and output match, but start times may not
% Output:
% x       Decimated SAC time series
% h       SAC header with relevant timing/statistic fields updated
%
%
% Ex1: Output time series not shifted; start times match
%    sac = '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac';
%    [x1, h1] = readsac(sac);
%    fs1 = efes(h1)  % Originally sampled at 20 Hz
%    fs2 = 5 % Decimate to 5 Hz
%    xax1 = xaxis(h1.NPTS, h1.DELTA, h1.B);
%    [x2, h2] = DECIMATESAC(x1, h1, fs2, false); % Decimate to 5 Hz; do not shift
%    xax2 = xaxis(h2.NPTS, h2.DELTA, h2.B);
%    plot(xax1, x1); hold on
%    plot(xax2, x2);
%    legend('Original', 'Decimated (unshifted)')
%
% Ex1: Output time series shifted; end times match
%    sac = '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac';
%    [x1, h1] = readsac(sac);
%    fs1 = efes(h1)  % Originally sampled at 20 Hz
%    fs2 = 5 % Decimate to 5 Hz
%    xax1 = xaxis(h1.NPTS, h1.DELTA, h1.B);
%    [x2, h2] = DECIMATESAC(x1, h1, fs2, true); % Decimate to 5 Hz; shift
%    xax2 = xaxis(h2.NPTS, h2.DELTA, h2.B);
%    plot(xax1, x1); hold on
%    plot(xax2, x2);
%    legend('Original', 'Decimated (shifted)')
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 26-Jun-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default
defval('shift', false)

% Sanity.
fs_new = fs;
if ~isint(fs_new)
    error('Requested output decimated sampling frequency must be integer')

end

% Determine decimation ratio; input frequency must be greater than requested frequency.
fs_old = efes(h, true);
if fs_old < fs_new
    error('Input signal sampled at %i Hz, lower than requested decimation frequency of %i Hz; perhaps interpolate?', fs_old, fs_new);

elseif fs_old == fs_new;
    fprintf('Input signal already sampled at requested sampling frequency; decimation not required')
    return

else
    R = fs_old / fs_new;
    if ~isint(R)
        error('Requested decimation ratio equals %.1f; must in integer', R)

    end
end

% Log some timing stats to compute timing effect of rounding/decimating.
xax_old = xaxis(h.NPTS, h.DELTA, h.B);

% Decimate time series
x = decimate(x, R);
fprintf('Decimated %i times\n', R)

% Adjust time-dependent headers.
h.DELTA = h.DELTA*R;
h.NPTS = length(x);

% Compute new timing axis.
xax_new = xaxis(h.NPTS, h.DELTA, h.B);

% Update purported ending of seismogram.
h.E = xax_new(end);

% Update time-series statistics (min/max);
h.DEPMIN = min(x);
h.DEPMAX = max(x);

% Printout timing error due to rounding/decimation.  NB, SAC can only handle
% millisecond timing precision, so smaller diffs > 1e-4 are irrelevant.
tdiff = xax_new(end) - xax_old(end);
if abs(tdiff) > 1e-4
    fprintf('Rounding and decimation resulted in output time series ending %.6f s later than original\n', tdiff)

end

if shift
    fprintf('Shifted output time series backward in time %.6f so that end time (as opposed to start) matches original\n', tdiff)
    h.B = h.B - tdiff;
    h.E = h.E - tdiff;

end
