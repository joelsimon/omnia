function [h1, h2] = sacdiff(s1, s2)
% [h1, h2] = SACDIFF(s1, s2)
%
% Compares two SAC files:
% * UTC timing according to their header
% * Cross correlation between their data
%
% Input:
% s1/2    SAC files to be compared
%             (def: '20200805T121329.22_5F2AF4E8.MER.DET.WLT5.sac', ...
%                   '20200805T121328.22_5F62A85C.MER.REQ.WLT5.sac')
%
% Output:
% h1/2    Header structures from input SAC files
%
% Useful for comparing MERMAID DET and (supposedly the same) REQ files.
%
% Author: Dr. Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 09-Oct-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults.
defval('s1', fullsac('20200805T121329.22_5F2AF4E8.MER.DET.WLT5.sac', ...
                     fullfile(getenv('MERMAID'), 'test_processed')))
defval('s2', fullsac('20200805T121328.22_5F62A85C.MER.REQ.WLT5.sac', ...
                     fullfile(getenv('MERMAID'), 'processed')))

%%______________________________________________________________________________________%%
% S1
[x1, h1] = readsac(s1);
xax1 = xaxis(h1.NPTS, h1.DELTA, 0);
seisdate1 = seistime(h1);
s1_date = seisdate1.B;

%%______________________________________________________________________________________%%
% S2
[x2, h2] = readsac(s2);
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
plot(xax_date1, x1, 'k')
plot(xax_date2, x2, 'r')
% minmax.m does not accept datetime arrays.
xl1 = min([xax_date1(1) xax_date2(1)]);
xl2 = max([xax_date1(end) xax_date2(end)]);
xlim([xl1 xl2])
lg = legend( 'S1', 'S2');
box on
hold off
title('S1 and S2 in UTC time')

%%______________________________________________________________________________________%%
%% PLOT IN ARBITRARY TIME

figure

% Seismograms.
[~, ha1] = krijetem(subnum(3,1));
pl1 = plot(ha1(1), xax1, x1, 'k');
hold(ha1(1), 'on')
pl2 = plot(ha1(1), xax2, x2, 'r');
xlim(ha1(1), [1 max([xax1(end) xax2(end)])])
xlabel(ha1(1), 'Seconds into S1 and S2 seismograms')
ylabel(ha1(1), 'Counts')
lg1 = legend(ha1(1), [pl1 pl2], 'S1', 'S2');


%% PLOT ALIGNED AND TRUNCATED

% Compute their cross correlation.
[xcorr_norm, max_xcorr, xat1, xat2, dx1, dx2, px1, px2] = ...
    alignxcorr(x1, x2);


%% PLOT
% Delays form alignxcorr.m are always positive.
if dx1 > 0
    % S2 is advanced w.r.t. S1.
    delay_time = (dx1-1) * h1.DELTA;
    delay_time = -delay_time;

elseif dx2 > 0
    % S2 is delayed w.r.t. S1.
    delay_time = (dx2-1) * h2.DELTA;

else
    delay_time = 0;

end

% Generate x-axis for aligned and truncated S1 and S2 signals where they
% are w.r.t. to S1; i.e., the signals are aligned at S1 = 0 s.
xax2_delayed = xax2 + delay_time;

pl21 = plot(ha1(2), xax1, x1, 'k');
hold(ha1(2), 'on')
pl22 = plot(ha1(2), xax2_delayed, x2, 'r');
xlabel(ha1(2), 'Time shift of S2  w.r.t S1 required for alignment (s)')
ylabel(ha1(2), 'Counts')
xlim(ha1(2), minmax([xax1' xax2_delayed']))
lg2 = legend(ha1(2), [pl21 pl22], 'S1', 'S2');

%% Plot the aligned traces on top of one another.
xax_xat1 = xaxis(length(xat1), h1.DELTA, 0);
xax_xat2 = xaxis(length(xat2), h2.DELTA, 0);

pl31 = plot(ha1(3), xax_xat1, xat1, 'k');
hold(ha1(3), 'on')
pl32 = plot(ha1(3), xax_xat2, xat2, 'r');
xlim(ha1(3), minmax([0 xax_xat1' xax_xat2']))
lg1 = legend(ha1(3), [pl31 pl32], 'S1', 'S2');
xlabel(ha1(3), 'Aligned and truncated')
ylabel(ha1(3), 'Counts')

% Format plots.
latimes

%%______________________________________________________________________________________%%
fprintf('\nAccording to the SAC headers:\n')

if start_time_diff == 0
    fprintf('* S2 and S1 seismogram start at exactly the same UTC time\n')

elseif start_time_diff < 0
    fprintf('* S2 starts %.2f s before the S1 seismogram\n', -start_time_diff)

else
    fprintf('* S2 starts %.2f s after the S1 seismogram\n', start_time_diff)

end
fprintf('* the sampling frequency of S1 is %i Hz, and S2 is %i Hz\n', efes(h1), efes(h2))

fprintf('\n---------------------------------------------------------------------\n')

fprintf('Comparing their arrays in arbitrary time:\n')
if isequal(x1, x2)
    fprintf('* S2 and S1 data are exactly equal\n');

else
    fprintf('* S2 is delayed w.r.t to S1 %.2f s\n', delay_time);

end

fprintf('\n---------------------------------------------------------------------\n')

fprintf('After aligning S1 and S2, and truncating them to be equal length:\n')
fprintf('* their normalized max cross correlation is %.2f %s\n', 100*max_xcorr, '%')
fprintf('* %.2f %s of S1 was cut to match the signal common to S2\n', px1, '%')
fprintf('* %.2f %s of S2 was cut to match the signal common to S1\n\n', px2, '%')