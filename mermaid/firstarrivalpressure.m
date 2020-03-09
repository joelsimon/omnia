function [RMS, ph, P, maxc_y, delay, xw3, W3, xw2, W2, EQ, winflag, tapflag, zerflag] = ...
        firstarrivalpressure(s, wlen, lohi, sacdir, evtdir, EQ, bathy, wlen2)
% [RMS, ph, P, maxc_y, delay, xw3, W3, xw2, W2, EQ, winflag, tapflag, zerflag] = ...
%       FIRSTARRIVALPRESSURE(s, wlen, lohi, sacdir, evtdir, EQ, bathy, wlen2)
%
% Extension of firstarrival.m (which deals with travel time residuals)
% that computes the RMS value of the first arrival considering the
% time window starting at the first arrival of the signal (the AIC
% pick), and extending until the 'wlen2' seconds.
%
% Input:
% s        SAC filename '20180819T042909.08_5B7A4C26.MER.DET.WLT5.sac')
% wlen     Window length [s] (def: 30)
% lohi     1 x 2 array of corner frequencies, or NaN to skip
%              bandpass and use raw data (def: [1 5]])
% sacdir   Directory containing (possibly subdirectories)
%              of .sac files (def: $MERMAID/processed)
% evtdir   Directory containing (possibly subdirectories)
%              of .evt files (def: $MERMAID/events)
% EQ       EQ structure if event not reviewed, or [] if
%              event reviewed and to be retrieved with
%              getevt.m (def: [])
% bathy    logical true apply bathymetric travel time correction,
%              computed with bathtime.m (def: true)
% wlen2    Length of second window, starting at the 'dat', the time of
%              the first arrival, in which to search for maxc_y [s]
%              (def: 1)
%
% Output:
% RMS      Root mean squared value of xw3: arrival to max. amplitude of wavetrain
% ph       Phase name associated with RMS
% P        Theoretical pressure of first arrival computed with reid.m [Pa]
% maxc_y   Amplitude (counts) of maximum (or minimum) amplitude of bandpassed
% delay    Time delay between true arrival time and time at largest
%             amplitude (max_y) [s]
% xw3      Windowed segment of x (maybe filtered) contained in W3 and used for
%              RMS calculation
% W3       timewindow.m struct of length delay [s]
%              beginning at dat
% xw2      Windowed segment of x (maybe filtered) contained in W2
% W2       timewindow.m struct of length wlen/2 [s]
%              beginning at dat
% EQ       EQ structure, either input or retrieved with getevt.m
% win/tap/zerflag  Flag (sentinel) values from firstarrival.m, see there
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 06-Mar-2020, Version 2017b on GLNXA64

% Defaults.
defval('s', '20180819T042909.08_5B7A4C26.MER.DET.WLT5.sac')
defval('wlen', 30)
defval('lohi', [1 5])
defval('sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('EQ', [])
defval('bathy', true)
defval('wlen2', 1)

% Run firstarrival to retrieve relevant statistics about the first-arriving phase.
[~, ~, ~, ~, ph, delay, ~, ~, ~, ~, maxc_y, ~, EQ, ~, xw2, W2, winflag, tapflag, zerflag] = ...
    firstarrival(s, false, wlen, lohi, sacdir, evtdir, EQ, bathy, wlen2);

% Find the new RMS time window which brackets just the time starting
% at the AIC pick of the first arrival and extending 'delay' seconds,
% e.g., from the arrival to the abs. maximum amplitude of the
% wavetrain. Make time window in reference to W2.

% Do not need to be worried about it being incomplete because that was
% checked in firstarrival.m and we know the delay will be at most as
% long as the input time series.
if ~isnan(delay)
    [xw3, W3] = timewindow(xw2, delay, W2.xlsecs, 'first', W2.delta, W2.xlsecs);

    % Compute the RMS
    RMS = rms(xw3);

    % Retrieve the theoretical pressure (Pa) of the first-arriving phase,
    % if it exists (requires an 'Mb' or 'Ml' magnitude type; see sac2evt.m).
    P = EQ(1).TaupTimes.pressure;

else
    xw3 = NaN;
    W3 = NaN;
    RMS = NaN;
    P = NaN;

end
