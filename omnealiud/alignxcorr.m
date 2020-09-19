function [c, mc, xat, yat, dx, dy, px, py] = alignxcorr(x, y)
% [c, mc, xat, yat, dx, dy, px, py] = ALIGNXCORR(x, y)
%
% Aligns common signals in x and y, reports their delays, truncates the aligned
% signals so they are equal length, and reports their normalized cross
% correlations.
%
% ALIGNXCORR is convenient because delays are always given as positive integers.
%
% Delays dx and dy are given in terms of postive samples where:
% * dx ~= 0, dy == 0 means that x must be delayed by dx to align with y
% * dx == 0, dy ~= 0 means that y must be delayed by dy to align with x
%
% Because dx and dy are samples and not lags, the total time in seconds that
% they represent is (dx-1)*fs, where fs is the sampling frequency.
%
% This is just a wrapper for alignsignals.m and xcorr.m; see there for further
% details (e.g., if a signal is periodic only the first delay is returned...).
%
% Input:
% x        A signal with something in common with y
% y        A signal with something in common with x
%
% Output:
% c        Normalized ('coeff' in xcorr.m) cross correlation of x and y after
%              alignment and truncation
% mc       Maximum absolute value of the normalized [0:1] cross correlation
% xat      Aligned and truncated x
% xat      Aligned and truncated y
% dx       Samples that x must be delayed to match the "same" signal in y (or 0),
%              or, how delayed y is w.r.t x
% dy       Samples that y must be delayed to match the "same" signal in x (or 0),
%              or, how delayed x is w.r.t. y
% px       Percentage that x was tuncated to generate xat (or 0)
% px       Percentage that y was tuncated to generate yat (or 0)
%
% Ex1:
%    x = [1 2];
%    y = [0 0 1 2 0 0];
%    [c, mc, xat, yat, dx, dy, px, py] = ALIGNXCORR(x, y)
%
% Ex2: (find the signal y, a pure sine wave, in x, which includes it plus noise)
%    % Generate pure sin wave.
%    x = sin(linspace(0,2*pi,100)); y = x;
%    % Delay the signal in x by 100 samples, append 100 more, and add noise.
%    x = [zeros(1,100) x zeros(1,100)]; x = x + 0.1*randn(1,length(x));
%    % Compute aligned cross correlation.
%    [c, mc, xat, yat, dx, dy, px, py] = ALIGNXCORR(x, y);
%    % Plot inputs.
%    subplot(3,1,1); plot(x, 'k'); legend('x'); xlim([1 length(x)]);
%    yl = get(gca, 'YLim');
%    subplot(3,1,2); plot(y, 'r'); legend('y'); xlim([1 length(x)]);
%    set(gca, 'YLim', yl)
%    % Because dy is positive, delay y by that number of samples to align.
%    delayed_yt = [dy+1:dy+length(y)];
%    subplot(3,1,3); hold on; plot(x, 'k'); plot(delayed_yt, y, 'r');
%    legend('x', 'y (delayed by dy)'); set(gca, 'YLim', yl); xticks([0])
%
% See also: alignsignals.m, xcorr.m
%
% Author: Dr. Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 19-Sep-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Align them, the easy way -- alignsignals.m runs xcorr.m in the background, so
% there is some redundancy in this script that could be worked out...
[xa, ya, delay] = alignsignals(x, y);

% Note the direction of the delay.
dx = 0;
dy = 0;
if delay < 1
    % * signal in x is delayed w.r.t to the "same" signal in y
    % * therefore, y had to be delayed by -delay to align with x
    % (y was zero padded)
    dy = -delay;

else
    % * signal in y is delayed w.r.t. the "same" signal in x
    % * therefore, x had to be delayed by +delay to align with y
    % (x was zero padded)
    dx = +delay;

end

% Cut the length from both x and y so that the "signal" common to both starts at
% the same time (one of them was zero padded to account for the extra signal
% contained in the non-padded time series).
D = abs(delay);
xat = xa(D+1:end);
yat = ya(D+1:end);

% Truncate the end of the longer time series so that their lengths match.
len_xat = length(xat);
len_yat = length(yat);
if len_xat < len_yat
    yat = yat(1:len_xat);

elseif len_xat > len_yat
    xat = xat(1:len_yat);

end

% Compute percentage cut from each time series.
px = (1 - length(xat)/length(x)) * 100;
py = (1 - length(yat)/length(y)) * 100;

% Compute normalized cross correlation of the aligned and truncated signals.
[c, lags] = xcorr(xat, yat, 'coeff');
[mc, idx] = max(abs(c));

% Their max xcorr now occurs at zero lag because they have been aligned:
% lags(idx) == 0
