function [xw, W, tt, EQ] = hunga_timewindow2_travtimeadj(x, h, min1, min2, kstnm, c, p2t_m)
% [xw, W, tt, EQ] = HUNGA_TIMEWINDOW2_TRAVTIMEADJ(x, h, min1, min2, kstnm, c, p2t_m)
%
% Adds the `hunga_travtimeadj` time-adjustment to `hunga_timewindow2` in the
% form of a travel-time adjustment in tt.timeadj.
%
% Like hunga_timewindow.m but does not assume pre/post minutes relative to input
% phase wave, rather inputs must be signed (negative is before ph; positive after).
%
% WARNING: does not include bathymetric time correction, ergo this script is ONLY
%          appropriate for horizontal ("*kmps") phases (input velocity as `c`).
%
% min1     +-minutes relative to phase arrival to begin windowed segment,
%                   -OR- NaN to begin at start of segment (def: -15)
% min2     +-minutes after phase arrival to end windowed segment,
%                   -OR- NaN to finish at end of segment (def: 45)
%
% tt.timeadj is the travel-time adjustment (tt_adj) from `hunga_travtimeadj` --
% it tells you how much sooner the TRUE phase arrives due to faster transit
% through rock (before the slope) compared to the time of a phase that is purely
% hydroacoustic and transits at, e.g., c = 1.483 km/s from the source.  The tt
% struct here assumes that velocity for full path, the times are just offset
% (negative) to account for first segment through faster rock.
%
% Input:
% ...
% kstnm   Station name
% c       Acoustic velocity [m/s] (def: 1480)
% p2t_m   Elevation (negative meters) of P-T conversion on slope (def: -1385)
%
% Ex:
%     sac = fullfile(getenv('HUNGA'), 'sac', '20220115T040306.0041_63385B5E.MER.REQ.merged.sac');
%     [x, h] = hunga_transfer_bandpass(sac);
%     [xw, W] = HUNGA_TIMEWINDOW2_TRAVTIMEADJ(x, h, -15, +45, 'H03S1', 1483, -1385);
%     figure; plot(x); hold on; plot([W.xlsamp:W.xrsamp], xw)
%
% See also: hunga_travtimeadj
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 12-Feb-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

% Defaults.
defval('min1', -15)
defval('min2', +45)
defval('c', 1480);
defval('p2t_m', -1350)

% Load prototype event for main eruption.
hundir = getenv('HUNGA');
evtdir = fullfile(hundir, 'evt');
evt = load(fullfile(evtdir, '11516993.evt'), '-mat');
EQ = evt.EQ;

% Compute theoretical T-wave arrival time.
%% No need for bathymetric correction; we assume ~horizontal T wave from source
mod = 'ak135';
ph = sprintf('%.3fkmps', c/1e3);

% From hunga_travtimeadj.m we know tt^star = tt + tt_adj, so set pt0=tt_adj.
% This negative time will shrink the expected travel time (adjust it to correct
% for path through rock before trench).
pt0 = 0;
tadj = hunga_travtimeadj(kstnm, c, p2t_m);
tt = arrivaltime(h, ...
                 irisstr2date(EQ.PreferredTime), ...
                 [EQ.PreferredLatitude EQ.PreferredLongitude], ...
                 mod, ...
                 EQ.PreferredDepth, ...
                 ph, ...
                 pt0, ...
                 tadj);


% Determine sample indices to match requested time window.
lx = length(x);
delta = h.DELTA;
fs = 1 / delta;

% Generate base (whole-time series) X-axis, in seconds, starting at 0.
xax = xaxis(length(x), delta, pt0);

% Determine first/last sample indices to retain from base xaxis.
if ~isnan(min1)
    samps1 = floor(min1 * 60 * fs);

else
    samps1 = tt.arsamp - 1;


end
if ~isnan(min2)
    samps2 = ceil(min2 * 60 *fs);

else
    samps2 = length(x) - tt.arsamp;

end
xlsamp = tt.arsamp + samps1;
xrsamp = tt.arsamp + samps2;

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
