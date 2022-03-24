function [c, mc, delay, xat1, xat2, xat1_pt0, xat2_pt0, sx1, sx2, px1, px2] = alignxcorr(x1, x2)
% [c, mc, delay, xat1, xat2, xat1_pt0, xat2_pt0, sx1, sx2, px1, px2] = ALIGNXCORR(x1, x2)
%
% Aligns signals common to x1 and x2, reports their delays, returns truncated
% and equal-length segments aligned on common signal, and reports the normalized
% cross correlation.
%
% To align, one must add the delay to x1, or subtract the delay from x2.
%
% `delay` is the sampling-interval delay (of the correlated signal) of x2 w.r.t. to x1:
%  * POSITIVE delay means that the signal in x2 is LATE compared to x1
%  * NEGATIVE delay means signal in x2 is EARLY compared to x1
%
% See `alignxcorrutc` to convert from arbitrary sample space of to seconds.
%
% This is just a wrapper for alignsignals.m and xcorr.m; see there for further
% details (e.g., if a signal is periodic only the first delay is returned...).
%
% Input:
% x1        A signal with something in common with x2
% x2        A signal with something in common with x1
%
% Output:
% c        Normalized ('coeff' in xcorr.m) cross correlation of xat1,2
%              (x1,2 after alignment and truncation)
% mc       Maximum absolute value normalized [0:1] cross correlation of xat1,2
% delay    How delayed the signal in x2 is, compared to x1, in samples
%              (x2 is delayed, "late", w.r.t. x1 if delay is positive)
% xat1     Aligned and truncated x1 (the correlated signal portion common to x2)
% xat2     Aligned and truncated x2 (the correlated signal portion common to x1)
% xat1_pt0 Number of uncorrelated samples removed from start of x1 to make xat1
% xat2_pt0 Number of uncorrelated samples removed from start of x2 to make xat2
% sx1*     Total number of samples cut (before and after correlated signal)
%              from x1 to generate xat1
% sx2*     Total number of samples cut (before and after correlated signal)
%              from x2 to generate xat2
% px1      Percentage of samples cut from x1 to generate xat1
% px2      Percentage of samples cut from x2 to generate xat2
%
% *`delay` and `sx1\2` are sampling intervals [sec=delay*fs], not [sec=(delay-1)*fs]
%   (do not remove 1 before multiplying by sampling frequency to convert to time)
%
% Ex1:
%    x1 = [1 2]
%    x2 = [0 0 1 2 0 0]
%    [c, mc, delay, xat1, xat2, xat1_pt0, xat2_pt0, sx1, sx2, px1, px2] = ALIGNXCORR(x1, x2)
%
% Ex2: (find the signal x2, an ADVANCED (negative delay) pure sine wave, in x1)
%    % Generate pure sin wave.
%    x1 = sin(linspace(0,2*pi,100)); x2 = x1; % x2 = -resample(x2,2,1);
%    % Delay the signal in x1 by 100 samples, append 100 more, and add noise.
%    x1 = [zeros(1,100) x1 zeros(1,100)]; x1 = x1 + 0.1*randn(1,length(x1));
%    % Compute aligned cross correlation.
%    [c, mc, delay, xat1, xat2, xat1_pt0, xat2_pt0, sx1, sx2, px1, px2] = ALIGNXCORR(x1, x2)
%    % Plot inputs.
%    xl = [1 300]; yl = [-2 2];
%    subplot(3,1,1); plot(x1, 'k'); legend('x1'); xlim([1 length(x1)]);
%    set(gca, 'XLim', xl, 'YLim', yl, 'Box', 'on')
%    subplot(3,1,2); plot(x2, 'r'); legend('x2'); xlim([1 length(x2)]);
%    set(gca, 'XLim', xl, 'YLim', yl, 'Box', 'on')
%    % To align you must subtract the delay from x2.
%    % (+1 because the signal in x1 starts at index 101)
%    align_x2t = [-delay+1:-delay+length(x2)];
%    % Alternatively: align_x2t = [xat1_pt0+1:xat1_pt0+length(x2)];
%    subplot(3,1,3); hold on; plot(x1, 'k'); plot(align_x2t, x2, 'r');
%    legend('x', 'x2 (with negative delay removed)'); set(gca, 'YLim', yl);
%    set(gca, 'XLim', xl, 'YLim', yl, 'Box', 'on')
%    xlabel('sample timing w.r.t. to x1 (x2 has been shifted!)')
%
% See also: alignxcorrutc.m, alignsignals.m, xcorr.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 24-Mar-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Align them, the lazy way (`alignsignals` runs xcorr.m in the background, so
% there is some redundancy in this script that could be worked out...)
[xa1, xa2, delay] = alignsignals(x1, x2);

% Note the direction of the delay.
if delay < 1
    % x1 was zero padded by `alignsignals`
    % x1 had to be shifted to right to align with x2
    % x2 is delayed (negative delay required for alignment) w.r.t x1
    % Common signal starts at a sampling-interval offset of -delay for x1, 0 for x2
    xat1_pt0 = -delay;
    xat2_pt0 = 0;

else
    % x2 was zero padded by `alignsignals`
    % x2 had to be shifted to right to align with x2
    % x2 is advanced (positive delay required for alignment) w.r.t x1
    % Common signal starts at a sampling-interval offset of 0 for x1, +delay x2
    xat1_pt0 = 0;
    xat2_pt0 = +delay;

end

% Cut samples from both x1 and x2 so that the "signal" common to both starts at
% sample 1 (one of them was zero padded to account for the extra signal
% contained in the non-padded time series).
D = abs(delay);
xat1 = xa1(D+1:end); % sig starts at d+1 because alignsignals.m appends d zeros
xat2 = xa2(D+1:end);

% Truncate the end of the longer time series so that their lengths match.
len_xat1 = length(xat1);
len_xat2 = length(xat2);
if len_xat1 < len_xat2
    xat2 = xat2(1:len_xat1);
    len_xat2 = length(xat2);

elseif len_xat1 > len_xat2
    xat1 = xat1(1:len_xat2);
    len_xat1 = length(xat1);

end

% Compute number of samples and total percentage cut from each time series.
len_x1 = length(x1);
len_x2 = length(x2);

sx1 = len_x1 - len_xat1;
sx2 = len_x2 - len_xat2;

px1 = (1 - len_xat1/len_x1) * 100;
px2 = (1 - len_xat2/len_x2) * 100;

% Compute normalized cross correlation of the aligned and truncated signals.
c = xcorr(xat1, xat2, 'coeff');
[~, idx] = max(abs(c));
mc = c(idx);

% Their max xcorr now occurs at zero lag because they have been aligned:
% lags(idx) == 0

% % Organize output structure.
% A = struct('c', c, ...
%            'mc', mc, ...
%            'delay', delay, ...
%            'xat1', xat1, ...
%            'xat2', xat2, ...
%            'xat1_pt0', xat1_pt0, ...
%            'xat2_pt0', xat2_pt0, ...
%            'sx1', sx1, ...
%            'sx2', sx2, ...
%            'px1',px1, ...
%            'px2', px2);
