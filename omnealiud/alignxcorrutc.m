function [delay, mc, xat1, xat2, daxt1, daxt2, dax1, dax2, xat1_pt0, xat2_pt0, F] = ...
    alignxcorrutc(x1, start1, delta1, x2, start2, delta2, plt)
% [delay, mc, xat1, xat2, daxt1, daxt2, dax1, dax2, xat1_pt0, xat2_pt0, F] = ...
%        alignxcorrutc(x1, start1, delta1, x2, start2, delta2, plt)
%
% Report signal cross correlation and delay in UTC time.
%
% From `alignxcorr`, to align: add delay to x1 -or- subtract delay from x2.  See
% internal plotting subfunction for details on computing alignment shifts.
%
% Input:
% x1       Time series, maybe with signal common in x2
% start1   Starttime of x1, as `datetime`
% delta1   Sampling interval of x1, in seconds
% x2       Time series, maybe with signal common in x1
% start2   Starttime of x2, as `datetime`
% delta2   Sampling interval of x2, in seconds
% plt      true to plot (def: false)
%
% Output:
% delay    How delayed the signal in x2 is, compared to x1, in seconds
%              (x2 is delayed, "late", w.r.t. x1 if delay is positive)
% mc       Maximum absolute value normalized [0:1] cross correlation of xat1,2
% xat1     Aligned and truncated x1 (the correlated signal portion common to x2)
% xat2     Aligned and truncated x2 (the correlated signal portion common to x1)
% daxt1    UTC datetime axis corresponding to xat1
% daxt2    UTC datetime axis corresponding to xat2
% dax1     UTC datetime axis corresponding to x1
% dax2     UTC datetime axis corresponding to x2
% xat1_pt0 Number of uncorrelated samples removed from start of x1 to make xat1
% xat2_pt0 Number of uncorrelated samples removed from start of x2 to make xat2
% F        Figure handles, if plotted (def: [])
%
% Ex:
%    s1 = '20220115T041444.0045_620D861C.MER.REQ.RAW.sac';
%    s2 = '20220115T044314.23_6204AEDB.MER.REQ.RAW.merged.sac';
%    %s2 = '/Users/joelsimon/mermaid/requests/2022/Hunga_Tonga/sac/20220115T045249.21_623B8CB8.MER.REQ.WLT5.sac';
%    [x1, h1] = readsac(s1);  [x2, h2] = readsac(s2);
%    x1 = bandpass(x1, efes(h1), 5, 10, 4, 1);
%    x2 = bandpass(x2, efes(h2), 5, 10, 4, 1);
%    start1 = seistime(h1); start1 = start1.B;
%    start2 = seistime(h2); start2 = start2.B;
%    delta1 = h1.DELTA; delta2 = h2.DELTA;
%    delay = ALIGNXCORRUTC(x1, start1, delta1, x2, start2, delta2, true)
%
% See also: alignxcorr.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 25-Mar-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('F', [])

% Sanity.
if ~strcmp(start1.TimeZone, 'UTC')
    start1.TimeZone = 'UTC';

end
if ~strcmp(start2.TimeZone, 'UTC')
    start2.TimeZone = 'UTC';

end

% If required, decimate to match lower of two sampling frequencies (does not
% make sense to do xcorr if sampling intervals differ).  We don't have to check
% that sampling frequencies are integer multiples because `decimate` fails if
% `R` is not and integer.
fs1 = round(1 / delta1);
fs2 = round(1 / delta2);
if fs1 > fs2
    R = fs1 /fs2;
    x1 = decimate(x1, R); % Requires integer `R`
    delta1 = delta1 * R;
    warning('decimated x1 %i times', R)

elseif fs2 > fs1
    R = fs2 / fs1;
    x2 = decimate(x2, R);
    delta2 = delta2 * R;
    warning('decimated x2 %i times',  R)

end

% Determine delay of x2 in arbitrary sample space (x1, x2 start at sample 1).
[corr_delay_samp, mc, xat1, xat2, xat1_pt0, xat2_pt0] = alignxcorr(x1, x2);

% Convert correlation delays from sampling intervals to seconds
% Do not remove 1 sample; delays of 0 samples = 0 seconds.
corr_delay_sec = corr_delay_samp * delta2;

% Correlation delay is signed as x2-x1.
% Start time delay  is signed as x2-x1.
% Ergo, the two delays are additive.
start_delay_sec = seconds(start2 - start1);
delay = corr_delay_sec + start_delay_sec;

%fprintf('%s is delayed by %.3f seconds compared to %s\n', h2.KSTNM, delay_sec, h1.KSTNM);
%fprintf('x2 is delayed by %.3f seconds compared to x1\n', delay_sec)
dax1 = datexaxis(length(x1), delta1, start1);
dax2 = datexaxis(length(x2), delta2, start2);

% Recompute UTC datetime axes for truncated correlated time series.
daxt1 = datexaxis(length(xat1), delta1, start1+seconds(xat1_pt0*delta1));
daxt2 = datexaxis(length(xat2), delta2, start2+seconds(xat2_pt0*delta2));

if plt
    %% From `alignxcorr`, to align: add delay to x1 -or- subtract delay from x2

    F(1).f = figure;
    set(gcf, 'Position', [961 529 960 448])
    F(1).ax1 = subplot(3,1,1);
    plot(dax1, x1, 'r'); hold on
    plot(dax2, x2, 'k')
    %title(sprintf('Full time series, x1 (%s) and x2 (%s)', h1.KSTNM, h2.KSTNM))
    title('Full time series, x1 and x2')
    legend('x1', 'x2')
    xlabel('UTC time')
    xl = F(1).ax1.XLim;

    % Plot x1 in UTC time, shift x2 to align/overlay
    shift_dax2 = datexaxis(length(x2), delta2, start2-seconds(delay));
    F(1).ax2 = subplot(3,1,2);
    title('x1 in UTC time; x2 shifted to align')
    plot(dax1, x1, 'r'); hold on
    plot(shift_dax2, x2, 'k')
    legend('x1', 'x2 (aligned by removing delay)')
    xlabel('UTC time of x1 (invalid timing for x2, which has been shifted)')
    xl = [xl F(1).ax2.XLim];

    % Plot x2 in UTC time, shift x1 to align/overlay
    shift_dax1 = datexaxis(length(x1), delta1, start1+seconds(delay));
    F(1).ax3 = subplot(3,1,3);
    title('x2 in UTC time; x2 shifted to align')
    plot(shift_dax1, x1, 'r'); hold on
    plot(dax2, x2, 'k')
    legend('x1 (aligned by adding delay)', 'x2')
    xlabel('UTC time of x2 (invalid timing for x1, which has been shifted)')
    xl = [xl F(1).ax3.XLim];

    set([F(1).ax1 F(1).ax2 F(1).ax3], 'XLim', [min(xl) max(xl)])
    latimes

    F(2).f = figure;
    set(gcf, 'Position', [961 4 960 448])
    F(2).ax1 = subplot(3,1,1);
    plot(daxt1, xat1, 'r'); hold on
    plot(daxt2, xat2, 'k')
    %title(sprintf('Truncated time series, xat1 (%s) and xat2 (%s)', h1.KSTNM, h2.KSTNM))
    title('Correlated signal, truncated time series xat1 and xat2 ')
    legend('xat1', 'xat2')
    xlabel('UTC time')
    textpatch(F(1).ax1, 'NorthWest', sprintf('Delay: %.2f\nXCorr: %.1f%s', delay, mc*100, '%'));

    % Plot xat1 in UTC time, shift xat2 to align/overlay
    shift_daxt2 = datexaxis(length(xat2), delta2, ...
                            start2-seconds(delay)+seconds(xat2_pt0*delta2));
    F(2).ax2 = subplot(3,1,2);
    title('xat1 in UTC time; xat2 shifted to align')
    plot(daxt1, xat1, 'r'); hold on
    plot(shift_daxt2, xat2, 'k')
    legend('xat1', 'xat2 (aligned by removing delay and ...)')
    xlabel('UTC time of xat1 (invalid timing for xat2, which has been shifted)');

    % Plot xat2 in UTC time, shift xat1 to align/overlay
    shift_daxt1 = datexaxis(length(xat1), delta1, ...
                            start1+seconds(delay)+seconds(xat1_pt0*delta1));
    F(2).ax3 = subplot(3,1,3);
    title('xat2 in UTC time; xat2 shifted to align')
    plot(shift_daxt1, xat1, 'r'); hold on
    plot(daxt2, xat2, 'k')
    legend('xat1 (aligned by adding delay and ...)', 'xat2')
    xlabel('UTC time of xat2 (invalid timing for xat1, which has been shifted)')

    set([F(2).ax1 F(2).ax2 F(2).ax3], 'XLim', F(1).ax1.XLim)
    latimes

end
