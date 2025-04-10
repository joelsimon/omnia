function [xw, W, tt, EQ] = hunga_timewindow(x, h, pre_mins, post_mins, ph)
% [xw, W, tt, EQ] = HUNGA_TIMEWINDOW(x, h, pre_mins, post_mins, ph)
%
% Construct time window around expected arrival time of ph.
% See timewindow.m for explanation of outputs xw, W.
%
% WARNING: does not include bathymetric time correction, ergo this script is really
%          most appropriate for horizontal ("*kmps") phases.
%
% pre_mins      Minutes before T wave to begin windowed segment,
%                   -OR- NaN to begin at start of segment (def: 15)
% post_mins     Minutes after T wave to end windowed segment,
%                   -OR- NaN to finish at end of segment (def: 45)
%
% Ex:
%     sac = fullfile(getenv('HUNGA'), 'sac', '20220115T040306.0041_63385B5E.MER.REQ.merged.sac');
%     [x, h] = mermaidtransfer(sac, [1/20 1/10 10 19.9]);
%     x = bandpass(x, efes(h), 5, 10);
%     [xw, W] = HUNGA_TIMEWINDOW(x, h, 15, 45);
%     figure; plot(x); hold on; plot([W.xlsamp:W.xrsamp], xw)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 05-May-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults.
defval('pre_mins', 15)
defval('post_mins', 45)
defval('ph', '1.5kmps')

if pre_mins < 0 || post_mins < 0
    error('`pre` and `post` must be positive')

end

% Load prototype event for main eruption.
hundir = getenv('HUNGA');
evtdir = fullfile(hundir, 'evt');
evt = load(fullfile(evtdir, '11516993.evt'), '-mat');
EQ = evt.EQ;

% Compute theoretical T-wave arrival time.
%% No need for bathymetric correction; we assume ~horizontal T wave from source
mod = 'ak135';
pt0 = 0;
tt = arrivaltime(h, ...
                 irisstr2date(EQ.PreferredTime), ...
                 [EQ.PreferredLatitude EQ.PreferredLongitude], ...
                 mod, ...
                 EQ.PreferredDepth, ...
                 ph, ...
                 pt0);
tt = tt(1);

% Determine sample indices to match requested time window.
lx = length(x);
delta = h.DELTA;
fs = 1 / delta;

% Generate base (whole-time series) X-axis, in seconds, starting at 0.
xax = xaxis(length(x), delta, pt0);

% Determine first/last sample indices to retain from base xaxis.
if ~isnan(pre_mins)
    pre_samps = floor(pre_mins * 60 * fs);

else
    pre_samps = tt.arsamp - 1;


end
if ~isnan(post_mins)
    post_samps = ceil(post_mins * 60 *fs);

else
    post_samps = length(x) - tt.arsamp;

end
xlsamp = tt.arsamp - pre_samps;
xrsamp = tt.arsamp + post_samps;

% Maybe add a single sample to end of windowed segment to top off and make at
% least as long as request, but maybe slightly longer, due to rounding.
if xrsamp < lx;
    xrsamp = xrsamp + 1;

end

% Sanity.
if xlsamp < 1
    warning('Requested time window beings earlier than SAC file...truncating request')
    xlsamp = 1;

end
if xrsamp > lx
    warning('Requested time window ends after than SAC file...truncating request')
    xrsamp = lx;

end

% Pull the relevant begin/end timing of the windowed segment using the base
% X-axis and the retained sample indices.
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
