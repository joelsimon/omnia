function [xw, W] = timewindow(x, wlen, pivot, fml, delta, pt0)
% [xw, W] = TIMEWINDOW(x, wlen, pivot, fml, delta, pt0)
%
% TIMEWINDOW returns a windowed segmentation of x and a structure
% relating the timing of the windowed segmentation to the original
% time series.
%
% Input:
% x         The time series to be windowed
% wlen      Window length in seconds, or NaN to return
%           the entire segment before/after 'pivot' (see Ex2)
% pivot     Time on x-axis around which window is constructed
%               Note: not seconds offset from pt0, but rather
%               the absolute time on the x-axis when
%               x-axis = xaxis(length(x), delta, pt0)
% fml       Position of pivot relative to window
%           'first': pivot time is time at first sample of window
%           'middle' pivot time is time at middle sample of window
%                    which extends 1/2*wlen from pivot left and right 
%           'last: pivot time is time at last sample of window
% delta     Sampling interval in seconds
%               (e.g, h.DELTA in SAC header)
% pt0       Time assigned to the first sample of x, in seconds
%              (e.g., h.B in SAC header)
%
% Output:
% xw        Windowed time series
% W         Structure of timing info that relates xw to x:
%           .delta: input delta
%           .xax: x-axis of x observed by window
%           .xlsamp: sample index in x of first sample of xw
%           .xrsamp: sample index in x of last sample of xw
%           .xlsecs: time assigned in x to first sample of xw
%           .xrsecs: time assigned in x to last sample of xw
%           .wlensamp: true window length in samples
%           .wlensecs: true window length in seconds
%
% Ex1: (Seismogram in blue, windowed portions in red and magenta.)
%      (Note that 0 seconds here is the event origin time (h.O).)
%    [x, h] = readsac('centcal.1.BHZ.SAC');
%    xax = xaxis(length(x), h.DELTA, h.B);
%    % 300 s window starting at -100 s and looking to right
%    [x300, W300] = TIMEWINDOW(x, 300, -100, 'first', h.DELTA, h.B);
%    % 80 s window starting at 600 s and looking to left
%    [x80, W80] = TIMEWINDOW(x, 80, 600, 'last', h.DELTA, h.B);
%    plot(xax, x); hold on
%    plot(W300.xax, x300, 'r')
%    plot(W80.xax, x80, 'm'); shg
%
% Ex2: (if wlen = NaN the entire segment before / after pivot is returned)
%    [x, h] = readsac('centcal.1.BHZ.SAC');
%    % Assign first sample of seismogram t = 0 s.
%    xax = xaxis(length(x), h.DELTA, 0);
%    % All data from 400 seconds after first sample.
%    [x400, W400] = TIMEWINDOW(x, NaN, 400, 'first', h.DELTA, 0);
%    % All data up to  200 seconds after first sample.
%    [x200, W200] = TIMEWINDOW(x, NaN, 200, 'last', h.DELTA, 0);
%    plot(xax, x); hold on
%    plot(W400.xax, x400, 'r')
%    plot(W200.xax, x200, 'm'); shg
%
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 12-Sep-2019, Version 2017b on GLNXA64

% Set up x-axis of complete time series and perform some error
% catching.
lx = length(x);
xax = xaxis(lx, delta, pt0);
if pivot < xax(1) || pivot > xax(end)
    error(['The requested pivot time of %.2f s not within the time ' ...
           'range of x.\nSpecify a pivot time between 0 and %.2f ' ...
           's.'], pivot, xax(end))

end

% Find approximate start and end of window in time (seconds), not samples.
switch lower(fml)
  case 'first'
    requested_xlsecs = pivot;
    if ~isnan(wlen)
        requested_xrsecs = requested_xlsecs + wlen;

    else
        requested_xrsecs = xax(end);

    end

  case 'middle'
    if isnan(wlen)
        error('wlen = NaN only allowed for fml = ''first'' or ''last''')

    end
    requested_xlsecs = pivot - (1/2 * wlen);
    requested_xrsecs = pivot + (1/2 *wlen);

  case 'last'
    requested_xrsecs = pivot;
    if ~isnan(wlen)
        requested_xlsecs = requested_xrsecs - wlen;

    else
        requested_xlsecs = xax(1);

    end

  otherwise
    error(['Please specify ''first'', ''middle'' or ''last'' for ' ...
           'input fml.'])

end

hit_edge = false;
if requested_xlsecs < xax(1)
    hit_edge = true;
    requested_xlsecs = xax(1);
    warning(sprintf(['Requested window extends beyond first sample ' ...
                     'of x.\nUsing first sample of x as first sample ' ...
                     'of windowed time series.']))

end

if requested_xrsecs > xax(end);
    hit_edge = true;
    requested_xrsecs = xax(end);
    warning(sprintf(['Requested window extends beyond last sample ' ...
                     'of x.\nUsing last sample of x as last sample ' ...
                     'of windowed time series.']))

end

% Actual samples and times that nearest match requested times.
xlsamp = nearestidx(xax, requested_xlsecs);
xrsamp = nearestidx(xax, requested_xrsecs);
xlsecs = xax(xlsamp);
xrsecs = xax(xrsamp);

% Actual window length in samples and seconds.
wxax = xax(xlsamp:xrsamp);
wlensamp = length(wxax);
wlensecs = wxax(end) - wxax(1);

% Organized the output structure.
xw = x(xlsamp:xrsamp);

W.delta = delta;
W.xax = wxax;
W.xlsamp = xlsamp;
W.xrsamp = xrsamp;
W.xlsecs = xlsecs;
W.xrsecs = xrsecs;
W.wlensamp = wlensamp;
W.wlensecs = wlensecs;

% Final check to see if rounding on left and right increased the
% difference in the actual window length beyond one sampling interval.
if abs(W.wlensecs - wlen) > delta && ~hit_edge
    error(['Difference between actual and requested window length ' ...
           'greater than one sampling interval'])

end
