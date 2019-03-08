function [freq, cfreq, afreq, acfreq] = scale2freq(fs, n)
% [freq, cfreq, afreq, acfreq] = SCALE2FREQ(fs, n)
% 
% SCALE2FREQ (roughly) converts wavelet scales to frequencies (in Hz)
% using the rule of thumb that the first scale 'sees' in the frequency
% range of ~[fs/4 : fs/s2] (limited by Nyquist-Shannon), and every
% subsequent scale halves the center frequency of the previous scale.
%
% Ordered from scales 1:n, where 1 is the finest resolution (highest
% frequency bandpass) and n is the coarsest resolution (lowest
% frequency bandpass/lowpass).
%
% Literal one-liner: freq{i} = [fs/2^(i+1) fs/2^i]
%
% Inputs:
% fs                Sampling frequency (Hz)
% n                 Number of scales of wavelet decomposition 
%                       ('n' from wt.m)
% 
% Output:
% freq              Frequency bands (in Hz) approximately
%                       sensed by DETAILS at every scale 
% cfreq             Center frequency of DETAILS at each scale
% afreq             Frequency band (in Hz) approximately
%                      sensed by APPROXIMATION at coarsest scale
% acfreq            Center frequency of APPROXIMATION at each scale
%
% Ex: (sampling rate 20 Hz, 5 wavelet scales)
%    [freq, cfreq, afreq, acfreq] = SCALE2FREQ(20, 5)
%    % Using a, d from wt.m:
%    % Finest details (d{1}) see 5-10 Hz
%    % Coarsest details (d{end}) see 0.3125-0.6250 Hz
%    % Approximation (a) sees 0-0.3125 Hz
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 03-Oct-2019, Version 2017b

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
% covers the gap between 0 Hz and the last detail bandpass.
afreq = [0 freq{end}(1)];
acfreq = mean(afreq);
