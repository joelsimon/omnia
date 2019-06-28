function [freq, cfreq, afreq, acfreq] = scale2freq(fs, n, hzors)
% [freq, cfreq, afreq, acfreq] = SCALE2FREQ(fs, n, hzors)
% 
% SCALE2FREQ (roughly) converts wavelet scales to frequencies (in Hz)
% or periods (in s) using the rule of thumb that the first scale
% 'sees' in the frequency range of ~[fs/4 : fs/s2] (limited by
% Nyquist-Shannon), and every subsequent scale halves the center
% frequency of the previous scale.
%
% Ordered from scales 1:n, where 1 is the finest resolution (highest
% frequency highpass) and n is the coarsest resolution (lowest
% frequency lowpass).
%
% Literal one-liner: freq{i} = [fs/2^(i+1) fs/2^i]
%
% Input:
% fs                Sampling frequency (Hz)
% n                 Number of scales of wavelet decomposition 
%                       ('n' from wt.m)
% hzors             Output format
%                   'Hz': Hertz (default)
%                   's': seconds
% 
% Output:
% freq              Frequency (or period) bands in Hz (or s) 
%                       approximately sensed by DETAILS at each scale 
% cfreq             Rough center frequency (or period) of DETAILS at each scale
% afreq             Frequency (or period) bands in Hz (or s) 
%                       approximately sensed by APPROXIMATION at coarsest scale
% acfreq            Rough enter frequency (or period) of APPROXIMATION at coarsest scale
%
% Ex: (sampling rate 20 Hz, 5 wavelet scales)
%    [freq, cfreq, afreq, acfreq] = SCALE2FREQ(20, 5, 'Hz')
%    [peri, cperi, aperi, acperi] = SCALE2FREQ(20, 5, 's')
%    % Using a, d from wt.m:
%    % Finest details (d{1}) see 5-10 Hz
%    % Coarsest details (d{end}) see 0.3125-0.6250 Hz
%    % Approximation (a) sees 0-0.3125 Hz
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 24-Jun-2019, Version 2017b

% Default.
defval('hzors', 'Hz')

% This is fine as a loop because pow2 operations are super quick.
freq = cell(1, n);
for i = 1:n
    freq{i} = [fs/2^(i+1) fs/2^i];

end

% Compute the central frequency from the bounds.
cfreq = cellfun(@(zz) mean(zz), freq);
cfreq = cfreq';

% The approximation (scaling) function is sensitive the frequencies
% from 0 Hz to the coarsest detail.  It's essentially a lowpass that
% covers the gap between 0 Hz and lower-corner frequency of the last
% detail bandpass.
afreq = [0 freq{end}(1)];
acfreq = mean(afreq);

switch lower(hzors)
  case 'hz'
    % Pass through; already in Hertz.

  case 's'
    freq = cellfun(@(xx) 1./xx, freq, 'UniformOutput', false)
    cfreq = 1 ./ cfreq;
    afreq = 1  ./ afreq;
    acfreq = 1 / acfreq;

  otherwise
    error('Specify one of ''Hz'' or ''s'' for input: hzors')

end
