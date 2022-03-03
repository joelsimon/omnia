function [h1, h2] = sacdiff(s1, s2, dmate, lohi, flipstack)
% [h1, h2] = SACDIFF(s1, s2, dmate, lohi, flipstack)
%
% Compares two SAC files:
% * UTC timing according to their header
% * Cross correlation between their data
%
% Useful for comparing MERMAID DET and (supposedly the same) REQ files.
%
% This will attempt to decimate SAC files with different sampling frequencies.
% Be wary of output headers in those cases, not all relevant variables updated.
%
% Input:
% s1/2    SAC files to be compared
%             (def: '20200805T121329.22_5F2AF4E8.MER.DET.WLT5.sac', ...
%                   '20200805T121328.22_5F62A85C.MER.REQ.WLT5.sac');
% dmate   Decimate to attempt to match sampling frequencies (def: false)
% lohi    2x1 array of [low, high] corner frequencies for `bandpass`,
%             or [] to leave unfiltered (def: [])
% flipstack true to reverse line stack order and send red to back
%           (def: false)
%
% Output:
% h1/2    Header structures from input SAC files
%
% Ex:
%    SACDIFF('20180728T225619.06_5B773AE6.MER.REQ.WLT5.sac', ...
%            '20180728T225619.06_5B773AE6.MER1.REQ.WLT5.sac');
%
% See also: alignxcorr.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 03-Mar-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

%% Wishlist:
%%
%% *Double x-axis, plotted in UTC time

% Defaults.
defval('s1', fullsac('20200805T121329.22_5F2AF4E8.MER.DET.WLT5.sac', ...
                     fullfile(getenv('MERMAID'), 'processed')))
defval('s2', fullsac('20200805T121328.22_5F62A85C.MER.REQ.WLT5.sac', ...
                     fullfile(getenv('MERMAID'), 'processed')))
defval('dmate', false)
defval('lohi', [])
defval('flipstack', false)

% Read the data
[x1, h1] = readsac(s1);
[x2, h2] = readsac(s2);

% Decimate signals so that sampling intervals may be compared
if dmate
    fs1 = efes(h1);
    fs2 = efes(h2);
    % This is imperfect because it only adjusts the SAC header variables related to
    % timing. Other values (e.g., depmin/max) are not also updated here.
    if fs1 > fs2
        R = fs1/fs2;
        x1 = decimate(x1, fs1/fs2);
        h1.DELTA = h1.DELTA*R;
        h1.NPTS = length(x1);
        warning('S1 decimated %i times', R)

    elseif fs2 > fs1
        R = fs2/fs1;
        x2 = decimate(x2, fs2/fs1);
        h2.DELTA = h2.DELTA * R;
        h2.NPTS = length(x2);
        warning('S2 decimated %i times', R)

    end
end

if lohi
    x1 = bandpass(x1, efes(h1), lohi(1), lohi(2));
    x2 = bandpass(x2, efes(h2), lohi(1), lohi(2));

end

%%______________________________________________________________________________________%%
% S1
xax1 = xaxis(h1.NPTS, h1.DELTA, 0);
seisdate1 = seistime(h1);
s1_date = seisdate1.B;

%%______________________________________________________________________________________%%
% S2
xax2 = xaxis(h2.NPTS, h2.DELTA, 0);
seisdate2 = seistime(h2);
s2_date = seisdate2.B;
start_time_diff = seconds(s1_date - s2_date);

%%______________________________________________________________________________________%%
%% PLOT UTC TIME
% Plot them on a common UTC datetime axis to see the offset between them.
xax_date1 = linspace(seisdate1.B, seisdate1.E, h1.NPTS);
xax_date2 = linspace(seisdate2.B, seisdate2.E, h2.NPTS);

figure
hold on
pl01 = plot(xax_date1, x1, 'k')
pl02 = plot(xax_date2, x2, 'r')
% minmax.m does not accept datetime arrays.
xl1 = min([xax_date1(1) xax_date2(1)]);
xl2 = max([xax_date1(end) xax_date2(end)]);
xlim([xl1 xl2])
%lg = legend( 'S1', 'S2');
lg = legend(h1.KSTNM, h2.KSTNM)
box on
hold off
title('S1 and S2 in UTC time')

%%______________________________________________________________________________________%%
%% PLOT IN ARBITRARY TIME

figure

% Seismograms.
[~, ha1] = krijetem(subnum(3,1));
pl11 = plot(ha1(1), xax1, x1, 'k');
hold(ha1(1), 'on')
pl12 = plot(ha1(1), xax2, x2, 'r');
xlim(ha1(1), [1 max([xax1(end) xax2(end)])])
xlabel(ha1(1), sprintf('Seconds into %s and %s seismograms, first sample set to 0 s in both', ...
                       h1.KSTNM, h2.KSTNM))
ylabel(ha1(1), 'Counts')
%lg1 = legend(ha1(1), [pl11 pl12], 'S1', 'S2');
lg1 = legend(ha1(1), [pl11 pl12], h1.KSTNM, h2.KSTNM);

%%______________________________________________________________________________________%%
%% PLOT ALIGNED AND TRUNCATED

% Compute their cross correlation.
[xcorr_norm, max_xcorr, xat1, xat2, dx1, dx2, px1, px2, sx1, sx2] = ...
    alignxcorr(x1, x2);

% Delays form alignxcorr.m are always positive.
% Do not remove 1 from dx---its units are sample offsets (intervals).
if dx1 > 0
    % S2 is advanced w.r.t. S1.
    delay_time = dx1 * h1.DELTA;
    delay_time = -delay_time;

elseif dx2 > 0
    % S2 is delayed w.r.t. S1.
    delay_time = dx2 * h2.DELTA;

else
    delay_time = 0;

end

% Generate x-axis for aligned and truncated S1 and S2 signals where they
% are w.r.t. to S1; i.e., the signals are aligned at S1 = 0 s.
xax2_delayed = xax2 + delay_time;

pl21 = plot(ha1(2), xax1, x1, 'k');
hold(ha1(2), 'on')
pl22 = plot(ha1(2), xax2_delayed, x2, 'r');
xlabel(ha1(2), sprintf('Aligned, not truncated, %s shifted so that %s starts at 0 s', ...
                       h2.KSTNM, h1.KSTNM))
ylabel(ha1(2), 'Counts')
xlim(ha1(2), minmax([xax1' xax2_delayed']))
%lg2 = legend(ha1(2), [pl21 pl22], 'S1', 'S2');
lg2 = legend(ha1(2), [pl21 pl22], h1.KSTNM, h2.KSTNM);

%% Plot the aligned traces on top of one another.
xax_xat1 = xaxis(length(xat1), h1.DELTA, 0);
xax_xat2 = xaxis(length(xat2), h2.DELTA, 0);

pl31 = plot(ha1(3), xax_xat1, xat1, 'k');
hold(ha1(3), 'on')
pl32 = plot(ha1(3), xax_xat2, xat2, 'r');
xlim(ha1(3), minmax([0 xax_xat1' xax_xat2']))
%lg3 = legend(ha1(3), [pl31 pl32], 'S1', 'S2');
lg3 = legend(ha1(3), [pl31 pl32], h1.KSTNM, h2.KSTNM);
xlabel(ha1(3), 'Aligned and truncated (keeping only the overlapping portion from above)')
ylabel(ha1(3), 'Counts')

textpatch(ha1(3), 'NorthWest', sprintf('xcorr: %.2f%s', 100*max_xcorr, '%'));

% Format plots.
latimes

if flipstack
    uistack(pl02, 'bottom')
    uistack(pl12, 'bottom')
    uistack(pl22, 'bottom')
    uistack(pl32, 'bottom')

end

%%______________________________________________________________________________________%%
fprintf('\nAccording to the SAC headers:\n')

if start_time_diff == 0
    fprintf('* S2 and S1 seismogram start at exactly the same UTC time\n')

elseif start_time_diff < 0
    fprintf('* S2 starts %.3f s before the S1 seismogram\n', -start_time_diff)

else
    fprintf('* S2 starts %.3f s after the S1 seismogram\n', start_time_diff)

end

fprintf('\n')

fprintf('After aligning S1 and S2, and truncating them to be equal length:\n')
if isequal(x1, x2)
    fprintf('* S2 and S1 data are exactly equal\n');

elseif delay_time
    fprintf('* S2 is delayed w.r.t to S1 by %.3f s (%i %s)\n', delay_time, max([dx1 dx2]), plurals('sample', max([dx1 dx2])));
else

end
fprintf('* their normalized max cross correlation is %.2f %s\n', 100*max_xcorr, '%')
fprintf('* %.2f%s (%i %s) of S1 was cut to match the signal common to S2\n', ...
        px1, '%', sx1, plurals('sample', sx1))
fprintf('* %.2f%s (%i %s) of S2 was cut to match the signal common to S1\n\n', ...
        px2, '%', sx2, plurals('sample', sx2))
