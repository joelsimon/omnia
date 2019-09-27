function [tres, dat, syn, ph, delay, twosd, xw1, xaxw1, maxc_x, maxc_y, ...
          SNR, EQ, W1, xw2, W2] = firstarrival(s, ci, wlen, lohi, sacdir, evtdir, EQ)
% [tres, dat, syn, ph, delay, twosd, xw1, xaxw1, maxc_x, maxc_y, ...
%          SNR, EQ, W1, xw2, W2] = firstarrival(s, ci, wlen, lohi, sacdir, evtdir, EQ)
% NEEDS HEADER
%                  tres = dat - syn
%
% Input:
% s        SAC filename
% ci       true to estimate arrival time uncertainty via
%              1000 realizations of M1 method (def: false)
% wlen     Window length [s] (def: 30)
% lohi     1x2 array of corner frequencies (def: [1 5]])
% sacdir   Directory containing (possibly subdirectories)
%              of .sac files (def: $MERMAID/processed)
% evtdir   Directory containing (possibly subdirectories)
%              of .evt files (def: $MERMAID/events)
% EQ       EQ structure if event not reviewed, or [] if
%              event reviewed and to be retrieved with
%              getevt.m (def: [])
%
% Output:
% tres     Travel time residual [s] w.r.t first phase arrival:
%              estimated (cpest.m) - theoretical (taupTime.m)
% dat      Actual arrival time computed with cpest.m [s]*
% syn      Theoretical arrival time computed with taupTime.m [s]*
% ph       Phase name associated with tres
% delay    Time delay between true arrival time and time at largest
%             amplitude (max_y) [s]
% xw1      Windowed segment of x, after bandpass filtering,
%              centered on first theoretical arrival time
% xaxw1    x-axis centered on syn at 0 seconds, i.e., compliment to xw1
% maxc_x   Time at of maximum (or minimum) amplitude of bandpassed signal [s]*
% maxc_y   Amplitude (counts) of maximum (or minimum) amplitude of bandpassed
%              signal within window beginning at dat and ending wlen/2 later
% twosd    2-standard deviation error estimation per M1 method [s]**
%              (def NaN)
% EQ       Input EQ structure or reviewed EQ struct associated with SAC file
%              via getevt.m
%% W1
%% xw2
%% W2
%
% *The x-axis here is w.r.t to original, NOT windowed, seismogram,
% i.e. xaxis(h.NPTS, h.DELTA, h.B), where h is the SAC header
% structure from readsac.m
%
% **See cpci.m and paper??
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 05-Aug-2019, Version 2017b

defval('s', '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac')
defval('ci', true)
defval('wlen', 30)
defval('lohi', [1 5])
defval('sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('EQ', [])

% Read data and retrieve event structure.  EQ contains the theoretical
% arrival times of all phases included in the time window, computed
% with arrivaltime.m (which calls taupTimes.m).
s = fullsac(s, sacdir);
[x, h] = readsac(s);
if isempty(EQ)
    EQ = getevt(s, evtdir);

end

% Sanity.
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

% Ensure time at first sample (pt0) is the same in both the EQ
% structure and the SAC file header.
if ~isequal(EQ(1).TaupTimes(1).pt0, h.B)
    error('EQ(1).TaupTimes(1).pt0 ~= h.B')

end

% The synthetic (theoretical, 'syn') arrival time is stored in the EQ structure.
syn = EQ(1).TaupTimes(1).truearsecs;
ph = EQ(1).TaupTimes(1).phaseName;

% Bandpass filter the time series and select a windowed segment.
xf = bandpass(x, 1/h.DELTA, lohi(1), lohi(2));
[xw1, W1] = timewindow(xf, wlen, EQ(1).TaupTimes(1).truearsecs, 'middle', h.DELTA, h.B);

% The offset x-axis, which sets syn at 0 s.
xaxw1 = W1.xax - syn;

% Changepoint estimate sample considering only the windowed portion centered on the theoretical first arrival.
cp = cpest(xw1, 'fast', false, true);

% Signal-to-noise ratio considering window 1 (W1: centered on syn,
% length wlen), not window 2 (W2: starting at dat, length wlen/2).
SNR = wtsnr({xw1}, cp, 1);

% The data ('dat') arrival sample is 1 sample after the changepoint
% estimate, which is an estimate of the last sample of the noise,
% unless SNR <=1, at which point the arrival does not exist ("noise"
% has more power than the "signal")
if SNR > 1
    dat_samp = cp + 1;

    % The data arrival time on an axis beginning at the time assigned to
    % the first sample of the seismogram (h.B in the SAC header and
    % EQ(1).TaupTimes(1).pt0 in the EQ structure, which are the same) is
    % simply the arrival sample index of the windowed x-axis.
    dat = W1.xax(dat_samp);

    % The travel time residual is defined as the arrival-time estimate (cp
    % + 1) of the windowed segment, mapped to the appropriate index in the
    % complete segment, minus the theoretical arrival time defined in the
    % complete time segment.
    tres = dat - syn;

    % Maximum absolute amplitude (counts) considering a window of length
    % wlen/2 starting at the actual phase arrival.
    [xw2, W2] = timewindow(xf, wlen/2, dat, 'first', h.DELTA, h.B);
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
