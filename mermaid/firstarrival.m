function [tres, dat, syn, tadj, ph, delay, twosd, xw1, xaxw1, maxc_x, maxc_y, ...
          SNR, EQ, W1, xw2, W2, winflag, tapflag, zerflag, xax0] = ...
        firstarrival(s, ci, wlen, lohi, sacdir, evtdir, EQ, bathy, wlen2, fs, popas, pt0)
% [tres, dat, syn, tadj, ph, delay, twosd, xw1, xaxw1, maxc_x, maxc_y, ...
%  SNR, EQ, W1, xw2, W2, winflag, tapflag, zerflag, xax0] = ...
%  FIRSTARRIVAL(s, ci, wlen, lohi, sacdir, evtdir, EQ, bathy, wlen2, fs, popas, pt0)
%
% Computes the travel-time residual between the AIC-based arrival-time estimate
% of Simon, J. D. et al., (2020), BSSA, doi: 10.1785/0120190173, and the
% theoretical arrival time of the first-arriving phase in the associated EQ
% structure (the latter may be generated with cpsac2evt.m, and reviewed with
% reviewevt.m)
%
% The AIC arrival-time estimate is made in a time window of the length specified
% as input, which is centered on the first-arriving phase in EQ(1).  This
% windowed segment of data may optionally be filtered before the AIC pick is
% made if 'lohi' is specified.  In that case, windowed segment of data twice the
% length of the requested window is tapered using a Tukey window with a 0.5
% cosine taper; i.e., if 'wlen' is 30 s, the taper is flat in a 30 s window
% centered on the theoretical first arrival, then cosine-tapered over 15 seconds
% on either end for a total of 60 seconds of nonzero data.  After the data are
% tapered the entire time series is filtered, but only the 30 s window within
% the flat part of the taper is considered for finding the AIC pick.
%
% Input:
% s        SAC filename (def: '20180819T042909.08_5B7A4C26.MER.DET.WLT5.sac')
% ci       true to estimate arrival time uncertainty via
%              1000 realizations of M1 method (def: false)
% wlen     Window length [s] centered on the 'syn', the theoretical
%              first arrival, to consider for AIC pick (def: 30)
% lohi     1 x 2 array of corner frequencies [Hz] for Butterworth bandpass,
%              or NaN to skip filtering and use raw data (def: [1 5]])
% sacdir   Directory containing (possibly subdirectories)
%              of .sac files (def: $MERMAID/processed)
% evtdir   Directory containing (possibly subdirectories)
%              of .evt files (def: $MERMAID/events)
% EQ       EQ structure if event not reviewed, or [] if event reviewed
%              and to be retrieved with getrevevt.m (def: [])
% bathy    logical true apply bathymetric travel time correction,
%              computed with bathtime.m (def: true)
%              [NB, does not adjust EQ.TaupTimes]***
% wlen2    Length of second window, starting at the 'dat', the time of
%              the first arrival, in which to search for maxc_y [s]
%              (def: 1.75)
% fs       Re-sampled frequency (Hz) after decimation, or []
%              to skip decimation (def: [])
% popas    1 x 2 array of number of poles and number of passes for bandpass,
%              or NaN if no bandpass (def: [4 1])
% pt0      Time in seconds assigned to first sample of X-xaxis (def: 0)
%
% Output:
% tres     Travel time residual [s] w.r.t first phase arrival:
%              estimated (cpest.m) - theoretical (taupTime.m)
% dat      AIC arrival-time estimate computed with cpest.m [s]*
% syn      Theoretical arrival time computed with taupTime.m [s]*
%              NB, if 'bathy' is true this includes the (additive) tadj
% tadj     Time adjustment for bathymetry, if 'bathy' is true [s]
% ph       Phase name associated with tres
% delay    Time delay between true arrival time and time at largest
%             amplitude (max_y) [s]
% twosd    2-standard deviation error estimation per M1 method [s]** (def NaN)
% xw1      Windowed segment of x (maybe filtered) contained in W1 --
%              the entire segment of (maybe filtered) data considered
%              for the AIC pick
% xaxw1    x-axis centered on syn at 0 seconds, i.e., complement to xw1
% maxc_x   Time at of maximum (or minimum) amplitude of signal [s]*; if
%              multiple, only the first occurrence of this max. value is returned
% maxc_y   Amplitude (e.g., counts, nm) of maximum (or minimum) amplitude of
%              signal within W2 -- window beginning at dat and ending wlen2 later
% SNR      SNR, defined as ratio of biased variance of signal and
%              noise segments (see wtsnr.m)
% EQ       Input EQ structure or reviewed EQ struct associated with SAC file
%              via getrevevt.m
% W1       timewindow.m struct of length wlen [s] centered on theoretical
%              first arrival-time -- all the data considered for AIC pick
% xw2      Windowed segment of x (maybe filtered) contained in W2 --
%              window beginning at dat and ending wlen2 later
% W2       timewindow.m struct of length wlen2 [s]
%              beginning at 'dat' -- all the data considered for maxc_y pick
% winflag  Window flag (sentinel value)
%          0: Both time windows complete
%          1: W1 incomplete, W2 complete
%          2: W1 complete, W2 incomplete
%          3: Both time windows incomplete
% tapflag  Taper flag (sentinel value; only relevant if bandpass filtered)
%          NaN: Bandpass (and thus taper) not requested
%          0: Success; time series tapered before bandpass
%          1: Failure; time series not tapered before bandpass because
%             taper extends beyond start/end time of time series
% zerflag  Null-value flag (sentinel value), to catch if e.g.,
%              if gaps in data were filled with zeros
%          NaN: Data are decimated and thus zero-values averaged,
%               rendering this sentinel value meaningless
%          0: No two contiguous datum == 0 in W1, W2,
%             or taper (if the latter exists)
%          1: At least two contiguous datum == 0 in W1, W2,
%             or taper (if the latter exists)
% xax0     Time axis for complete signal, `xaxis(h.NPTS, h.DELTA, pt0)`
%
% *The x-axis here is w.r.t to original, NOT windowed, seismogram,
% i.e. xaxis(h.NPTS, h.DELTA, pt0), where h is the SAC header structure
% from readsac.m
%
% **See cpci.m: Simon, J. D. et al., (2020), BSSA, doi: 10.1785/0120190173
%
% ***If MERMAID depth is not contained in the header ('STDP' field),
% then it is assumed to be 1500 m below the sea surface
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 31-Jan-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults.
defval('s', '20180819T042909.08_5B7A4C26.MER.DET.WLT5.sac')
defval('ci', true)
defval('wlen', 30)
defval('lohi', [1 5])
defval('sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('EQ', []) % defaults to `getrevevt(s, evtdir)`, later
defval('bathy', true)
defval('wlen2', 1.75)
defval('fs', []) % defaults to not bandpass filter
defval('popas', [4 1])
defval('pt0', 0)

% Start with baseline assumption both time windows will be complete.
incomplete1 = false;
incomplete2 = false;

% Start with assumption that time series will not be tapered.
tapflag = NaN;

% Start with the assumption that the data have no 0 values (real data
% is unlikely to have ever have a value exactly equal to zero).
zerflag = 0;

% Read data and retrieve event structure.  EQ contains the theoretical
% arrival times of all phases included in the time window, computed
% with arrivaltime.m (which calls taupTime.m).

% Nab fullpath SAC file name, if not supplied.
if isempty(fileparts(s))
    s = fullsac(s, sacdir);

end
[x, h] = readsac(s);

% Nab EQ structure, if not supplied (assuming MERMAID data here; getrevevt.m at
% this time assumes MERMAID event directory structure.  If, for example, you
% want to use this function for a 'nearby' EQ you must supply it directly).
if isempty(EQ)
    EQ = getrevevt(s, evtdir);

else
    % Verify the filename in the supplied EQ structure matches the SAC file.
    nopath_sac = strippath(s);
    sac_idx = strfind(upper(nopath_sac), 'SAC');
    if ~strcmp(nopath_sac(1:sac_idx), EQ(1).Filename(1:sac_idx))
        error('Supplied EQ structure does not match SAC file')

    end
end

% Decimate, if requested.
decimated = false;
if ~isempty(fs)
    old_fs = round(1 / h.DELTA);
    if fs > old_fs
        error('Requested downsampled frequency greater than native sampling frequency')
    end

    % Decimate.
    R = floor(old_fs / fs);
    x = decimate(x, R);

    if R > 1
        decimated = true;
        fprintf('\nDecimated from %i Hz to %i Hz\n', old_fs, round(1 / (h.DELTA*R)));

        % Very important: adjust the appropriate SAMPLE header variables .NPTS and
        % .DELTA.  The absolute (SECONDS) timing variables (B, E) won't change
        % (except by maybe a sample-interval...see seistime.m, where it is properly
        % accounted for).  The length of a decimated array is: ceil(length(x)/r).
        % If R == 1 these are unchanged.
        h.NPTS = length(x);
        h.DELTA = h.DELTA * R;

    end
end

% Sanity.
nopath_sac = strippath(s);
sac_idx = strfind(upper(nopath_sac), 'SAC');
if ~strcmp(nopath_sac(1:sac_idx), EQ(1).Filename(1:sac_idx))
    error('Supplied EQ structure does not match SAC file')

end

if ~isstruct(EQ)
    if isempty(EQ)
        warning('No identified event associated with this SAC file')
        return

    end

    if isnan(EQ)
        warning(['No reviewed event associated with this SAC file ' ...
                 '(review it with reviewevt.m)'])

    end
end

% Ensure time at first sample (pt0) is the same in both the EQ structure and the
% SAC file header (both are seconds offset from the SAC header's reference time).
if ~isequal(EQ(1).TaupTimes(1).pt0, h.B)
    error('EQ(1).TaupTimes(1).pt0 ~= h.B')

end

% The synthetic (theoretical, 'syn') arrival time is stored in the EQ structure.
syn = EQ(1).TaupTimes(1).truearsecs;

% That arrival is set on a time axis relative to the SAC header's reference
% time, i.e., the the first sample is assigned h.B seconds. Determine the
% difference between the assigned first-sample time and the requested
% first-sample time to correct the synthetic arrival time on on the same x-axis
% as requested in the output.  If `pt0=h.B` this difference is 0 seconds.
pt0_diff = EQ(1).TaupTimes(1).pt0 - pt0;
syn = syn - pt0_diff;
fprintf('Reporting arrivals on an X-xaxis whose first sample is set to time: %.6f s\n', pt0)

% Correct the travel time for bathymetry (skipping surface-waves).
ph = EQ(1).TaupTimes(1).phaseName;
if bathy && ~endsWith(ph, 'kmps')
    z_ocean = gebco(h.STLO, h.STLA, '2014');
    if h.STDP == -12345 || isnan(h.STDP)
        warning('MERMAID depth not contained in header -- using 1500 m below sea surface')
        z_mermaid = -1500;

    else
        z_mermaid = -h.STDP;

    end
    tadj = bathtime(EQ(1).TaupTimes(1).model, ph, ...
                     EQ(1).TaupTimes(1).incidentDeg, z_ocean, z_mermaid);
    syn = syn + tadj;

else
    tadj = NaN;

end

% Window the time series.
[xw1, W1, incomplete1] = timewindow(x, wlen, syn, 'middle', h.DELTA, pt0);

% Check if any two contiguous datum within first time window == 0
% (likely signals missing, filler values).
zero_vals = find(xw1  == 0);
if any(diff(zero_vals) == 1) % diff == 1 means zero-values are next to each other
        zerflag = 1;

end

% Filter the windowed time series.
if ~isnan(lohi)
    % Ensure Nyquist frequency is respected.
    if 1/h.DELTA < 2*lohi(end)
        error('Upper cutoff frequency >= 1/2 the sampling frequency')

     end

     % Remove mean and trend.
     x = detrend(x, 'constant');
     x = detrend(x, 'linear');

     % The taper is exactly 1 in the timewindow of interest 'xw1', and
     % decays to zero outside.  It is constructed by generating a
     % Hanning window that is the length of the timewindow of
     % interest, splitting it down the middle, and attaching those
     % symmetrically-decreasing cosine tapers to either end of the
     % series of ones. That taper is then then be multiplied by the
     % original time series.  Finally, that whole, tapered time series
     % is bandpass filtered, and then is xw1 found again (it is still
     % located in the same place (time), though the values inside that
     % window have now changed thanks to filtering) from that
     % tapered, filtered complete time series.
     hanwin = hanning(length(xw1));
     hanwin_middle = length(hanwin) / 2;

     % This ensures isequal(left_taper,flip(right_taper)) is true
     % regardless whether x is length even or odd because hanning has
     % two repeated values in the middle for even length arrays, or a
     % unique, non repeated value (which is skipped here) for odd
     % length arrays (see hanning(3), hanning(4), hanning(5), etc.)
     %
     % x is even: (e.g., firstarrival([], [], 30.0000)
     % hanwin_middle = 301
     % left taper indices = 1:301
     % right taper indices = 302:602,
     % isequal(hanwin(301), hanwin(302))
     % isequal(left_taper,flip(right_taper))
     %
     % x is odd (firstarrival([], [], 29.9897):
     % hanwin_middle = 300.5
     % left taper indices = 1:300
     % right taper indices = 302:601 % skipped 301!
     % isequal(hanwin(300), hanwin(302))
     % isequal(left_taper,flip(right_taper))
     left_taper = hanwin(1:floor(hanwin_middle));
     right_taper = hanwin(ceil(hanwin_middle)+1:end);

     % Construct taper: unity within time window.
     taper = zeros(size(x));
     taper(W1.xlsamp:W1.xrsamp) = 1;

     % Taper from 0 to the full taper amplitude, ending at 1 sample index
     % before the untapered time window.
     left_taper_idx = [W1.xlsamp-length(left_taper) : W1.xlsamp-1];

     % Taper from full taper amplitude to 0, beginning at one sample index
     % after the untapered time window.
     right_taper_idx = [W1.xrsamp+1 : W1.xrsamp+length(right_taper)];

     % Only apply taper if it completely exists within the bounds of the
     % input time series (no partial/abbreviated/cut-off taper allowed).
     if left_taper_idx(1) >= 1 && right_taper_idx(end) <= length(x)
         % Taper applied.
         tapflag = 0;

         % Check if any two contiguous datum with the taper == 0
         % (likely signals missing, filler values).
         within_taper = x(left_taper_idx(1):right_taper_idx(end));
         zero_vals = find(within_taper == 0);
         if any(diff(zero_vals) == 1)
             zerflag = 1;

         end

         % Technically this taper is a Tukey taper with cosine taper fraction
         % 0.5 -- see the verification at the end.
         taper(left_taper_idx) = left_taper;
         taper(right_taper_idx) = right_taper;

         x = x .* taper;

     else
         % Taper not applied -- extends beyond first or last sample of 'x'.
         tapflag = 1;

     end

     % Bandpass entire (maybe tapered) time series.
     x = bandpass(x, 1/h.DELTA, lohi(1), lohi(2), popas(1), popas(2), 'butter');

     % Remove the relevant window from the tapered and filtered time series.
     [xw1, W1, incomplete1] = timewindow(x, wlen, syn, 'middle', h.DELTA, pt0);

end

% The offset x-axis, which sets syn at 0 s.
% N.B., W1.xax: places xw1 in the timing of the original input x
%        xaxw1: places xw1 such that it is centered on the theoretical first arrival at 0 s
xaxw1 = W1.xax - syn;

% Changepoint estimate sample considering only the windowed portion centered on
% the theoretical first arrival.
cp = cpest(xw1, 'fast', false, true);

% Signal-to-noise ratio considering window 1 (W1: centered on syn,
% length wlen), not window 2 (W2: starting at dat, length wlen2).
SNR = wtsnr({xw1}, cp, 1);

% The data ('dat') arrival sample is 1 sample after the changepoint estimate,
% which is an estimate of the last sample of the noise, unless SNR <= 1, at
% which point the arrival does not exist ("noise" has more power than the "signal")
if SNR > 1
    dat_samp = cp + 1;

    % The data arrival time on an axis beginning at the time assigned to the first
    % sample of the seismogram ('pt0' input).
    dat = W1.xax(dat_samp);

    % The travel time residual is defined as the arrival-time estimate (cp
    % + 1) of the windowed segment, mapped to the appropriate index in the
    % complete segment, minus the theoretical arrival time defined in the
    % complete time segment.
    tres = dat - syn;

    % Maximum absolute amplitude (e.g., counts or nm) considering a window
    % of length wlen2 starting at the actual phase arrival.
    [xw2, W2, incomplete2] = timewindow(x, wlen2, dat, 'first', h.DELTA, pt0);

    % Check if any two contiguous datum within the second time window == 0
    % (likely signals missing, filler values).
    zero_vals = find(xw2  == 0);
    if any(diff(zero_vals) == 1)
        zerflag = 1;

    end

    % Identify the maximum (or minimum) amplitude within W2.
    maxy = max(xw2);
    miny = min(xw2);
    if maxy > abs(miny)
        maxc_y = maxy;

    else
        maxc_y = miny;

    end

    % Find the time on the original x-axis of the (first occurrence of)
    % the maximum counts value.
    maxc_x = W2.xax(find(xw2 == maxc_y));

    % If that maximum value is reached multiple times keep only the first occurrence.
    maxc_x = maxc_x(1);

    % delay is then the time difference between the arrival time and the
    % time of the largest amplitude within the signal segment.
    delay = maxc_x - dat;

    % Uncertainty estimate.
    if ci
        M1 = cpci(xw1, 'kw', 1000, [], 'fast', false, true);

        % Do not remove 1 sample from M1 before multiplying it by the sampling
        % interval because 0 error is 0 samples, not 1 (as is the case for the
        % M2 method, where the interval under consideration is at minimum
        % length 1 -- see changepoint.m).
        twosd = M1.twostd * h.DELTA;

    else
        twosd = NaN;

    end
else
    dat = NaN;
    tres = NaN;
    xw2 = NaN;
    W2 = NaN;
    maxc_y = NaN;
    maxc_x = NaN;
    delay = NaN;
    twosd = NaN;

end

% Determine windows' completion classification.
if ~incomplete1 && ~incomplete2
    winflag = 0;

end
if incomplete1
    winflag = 1;

end
if incomplete2
    winflag = 2;

end
if incomplete1 && incomplete2
    winflag = 3;

end

% Decimation averages values, so if the original seismogram contains contiguous
% zeros (what is marked by the zerflag) the decimated seismogram does
% not. Rather than a major refactor of this function at this point (to check
% zero-values in all the windows before decimation) I will note that if data are
% decimated the zerflag is meaningless.
if decimated
    zerflag = NaN;

end

% Finally, compute the full time axis of the possibly decimated data, for reference.
xax0 = xaxis(h.NPTS, h.DELTA, pt0);

% Verify timing-axes.
if ~all(intersect(W1.xax, xax0) == W1.xax)
    error('First window does not align with full time axis')

end
if isstruct(W2) && ~all(intersect(W2.xax, xax0) == W2.xax)
    error('Second window does not align with full time axis')

end

% %_________________________________________________________________________________%
% % Verify equality between my taper and the Tukey window. Mine is
% % constructed the way it is so that I can keep track of timing easily.
% % Easier for me to do it that way than to derive a Tukey window of the
% % correct length and put it in the correct place.

% % This cosine taper is a Tukey window with cosine fraction 0.5.
% % Verified for both even- and odd-length windows.

% % Joel's taper.
% t1 = taper(find(taper > 0));

% % MATLAB's builtin.
% t2 = tukeywin(length(t1), 0.5);

% % Difference.
% max(abs(t1 -t2))

% % Also, in both even- and odd-length xw1 cases.
% isequal(length(left_taper), length(right_taper))

% % And, if xw1 is even:
% length(left_taper) + length(right_taper) == length(xw1)

% % And, if xw1 is odd: because the singular 1 directly in the middle of
% % the Hanning window is removed when it is split.
% length(left_taper) + length(right_taper) == length(xw1) - 1
