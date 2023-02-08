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
% !! Be wary of output headers in those cases, not all relevant variables updated !!
%
% Note that "truncate" here refers to chopping off whatever data exist
% before/after the signal common to both SAC files; it is not the same
% "truncate" as optional input argument for `alignsignals`.
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
% Last modified: 08-Feb-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

%% Wishlist:
%%
%% *Double x-axis, plotted in UTC time?

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
        %warning('%s decimated %i times', h1.KSTNM, R)
        warning('s1 decimated %i times', R)

    elseif fs2 > fs1
        R = fs2/fs1;
        x2 = decimate(x2, fs2/fs1);
        h2.DELTA = h2.DELTA * R;
        h2.NPTS = length(x2);
        %warning('%s decimated %i times',  h2.KSTNM, R)
        warning('s2 decimated %i times', R)

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
s1_sdate = seisdate1.B;
s1_edate = seisdate1.E;

%%______________________________________________________________________________________%%
% S2
xax2 = xaxis(h2.NPTS, h2.DELTA, 0);
seisdate2 = seistime(h2);
s2_sdate = seisdate2.B;
s2_edate = seisdate2.E;


%%______________________________________________________________________________________%%
%% PLOT UTC TIME
% Plot them on a common UTC datetime axis to see the offset between them.
xax_date1 = linspace(seisdate1.B, seisdate1.E, h1.NPTS);
xax_date2 = linspace(seisdate2.B, seisdate2.E, h2.NPTS);

figure
hold on
pl01 = plot(xax_date1, x1, 'k');
pl02 = plot(xax_date2, x2, 'r');
% minmax.m does not accept datetime arrays.
xl1 = min([xax_date1(1) xax_date2(1)]);
xl2 = max([xax_date1(end) xax_date2(end)]);
xlim([xl1 xl2])
lg = legend( 's1', 's2');
%lg = legend(h1.KSTNM, h2.KSTNM);
box on
hold off
%title(sprintf('%s and %s in UTC time', h1.KSTNM, h2. KSTNM))
title('s1 and s2 in UTC time')

%%______________________________________________________________________________________%%
%% PLOT IN ARBITRARY TIME

figure

% Seismograms.
[~, ha1] = krijetem(subnum(3,1));
pl11 = plot(ha1(1), xax1, x1, 'k');
hold(ha1(1), 'on')
pl12 = plot(ha1(1), xax2, x2, 'r');
xlim(ha1(1), [1 max([xax1(end) xax2(end)])])
% xlabel(ha1(1), sprintf('Seconds into %s and %s seismograms, first sample set to 0 s in both', ...
%                        h1.KSTNM, h2.KSTNM))
xlabel(ha1(1), 'Seconds into s1 and s2 seismograms, first sample set to 0 s in both')
ylabel(ha1(1), 'Counts')
lg1 = legend(ha1(1), [pl11 pl12], 's1', 's2');
%lg1 = legend(ha1(1), [pl11 pl12], h1.KSTNM, h2.KSTNM);

%%______________________________________________________________________________________%%
%% PLOT ALIGNED AND TRUNCATED

% Compute their cross correlation and signal delay.
[delay, mc, xat1, xat2, ~, ~, sx1, sx2, px1, px2, c] = alignxcorr(x1, x2);
delay_time = delay * h2.DELTA;

% Generate x-axis for aligned and truncated S1 and S2 signals where they
% are w.r.t. to S1; i.e., the signals are aligned at S1 = 0 s.
xax2_delayed = xax2 - delay_time;

pl21 = plot(ha1(2), xax1, x1, 'k');
hold(ha1(2), 'on')
pl22 = plot(ha1(2), xax2_delayed, x2, 'r');
% xlabel(ha1(2), sprintf('Aligned, not truncated, %s shifted so that %s starts at 0 s', ...
%                        h2.KSTNM, h1.KSTNM))
xlabel(ha1(2), 'Aligned, not truncated, s2 shifted so that s1 starts at 0 s')
ylabel(ha1(2), 'Counts')
xlim(ha1(2), minmax([xax1' xax2_delayed']))
lg2 = legend(ha1(2), [pl21 pl22], 's1', 's2');
%lg2 = legend(ha1(2), [pl21 pl22], h1.KSTNM, h2.KSTNM);

%% Plot the aligned traces on top of one another.
xax_xat1 = xaxis(length(xat1), h1.DELTA, 0);
xax_xat2 = xaxis(length(xat2), h2.DELTA, 0);

pl31 = plot(ha1(3), xax_xat1, xat1, 'k');
hold(ha1(3), 'on')
pl32 = plot(ha1(3), xax_xat2, xat2, 'r');
xlim(ha1(3), minmax([0 xax_xat1' xax_xat2']))
lg3 = legend(ha1(3), [pl31 pl32], 's1', 's2');
%lg3 = legend(ha1(3), [pl31 pl32], h1.KSTNM, h2.KSTNM);
xlabel(ha1(3), 'Aligned and truncated (keeping only the overlapping portion from above)')
ylabel(ha1(3), 'Counts')

textpatch(ha1(3), 'NorthWest', sprintf('xcorr: %.2f%s', 100*mc, '%'));

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

start_time_diff = seconds(s2_sdate - s1_sdate);
if start_time_diff == 0
    fprintf('* s1 and s2 seismogram start at exactly the same UTC time\n')

else
    fprintf('* s2 starts %.3f seconds after s1\n', start_time_diff)
end

end_time_diff = seconds(s2_edate - s1_edate);
if end_time_diff == 0
    fprintf('* s1 and s2 seismogram end at exactly the same UTC time\n')

else
    fprintf('* s2   ends %.3f seconds after s1\n', end_time_diff)
end

fprintf('\n')

fprintf('After aligning s1 and s2, and truncating them to be equal length:\n')
if isequal(x1, x2)
    fprintf('* s1 and s2 data are exactly equal\n')

else
    fprintf('* s2 is %.3f seconds delayed w.r.t. to s1\n', delay_time)

end
fprintf('* their normalized max cross correlation is %.2f %s\n', 100*mc, '%')
fprintf('* %.2f%s (%i %s) of s1 was cut to match the signal common to s2\n', ...
        px1, '%', sx1, plurals('sample', sx1))
fprintf('* %.2f%s (%i %s) of s2 was cut to match the signal common to s1\n\n', ...
        px2, '%', sx2, plurals('sample', sx2))

%% ___________________________________________________________________________ %%

% if start_time_diff == 0
%     fprintf('* %s and %s seismogram start at exactly the same UTC time\n', ...
%             h2.KSTNM, h1.KSTNM)

% else
%     fprintf('* %s starts %.3f seconds after %s\n', ...
%             h2.KSTNM, start_time_diff, h1.KSTNM)
% end

% end_time_diff = seconds(s2_edate - s1_edate);
% if end_time_diff == 0
%     fprintf('* %s and %s seismogram end at exactly the same UTC time\n', ...
%             h2.KSTNM, h1.KSTNM)

% else
%     fprintf('* %s ends %.3f seconds after %s\n', ...
%             h2.KSTNM, end_time_diff, h1.KSTNM)
% end

% fprintf('\n')

% fprintf('After aligning %s and %s, and truncating them to be equal length:\n', ...
%         h1.KSTNM, h2.KSTNM)
% if isequal(x1, x2)
%     fprintf('* %s and %s data are exactly equal\n', h2.KSTNM, h1.KSTNM);

% else
%     fprintf('* %s is %.3f seconds delayed w.r.t. to %s\n', h2.KSTNM, delay_time, h1.KSTNM)

% end
% fprintf('* their normalized max cross correlation is %.2f %s\n', 100*mc, '%')
% fprintf('* %.2f%s (%i %s) of %s was cut to match the signal common to %s\n', ...
%         px1, '%', sx1, plurals('sample', sx1), h1.KSTNM, h2.KSTNM)
% fprintf('* %.2f%s (%i %s) of %s was cut to match the signal common to %s\n\n', ...
%         px2, '%', sx2, plurals('sample', sx2), h2.KSTNM, h1.KSTNM)
