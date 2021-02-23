function ex_firstarrivals
% ex_firstarrivals
%
% Scriptish to show how to modify time axis with with `pt0` in firstarrivals.m.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 22-Feb-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

% Load SAC file and corresponding EQ metadata.
exdir = fullfile(getenv('OMNIA'), 'exfiles');
s = '20180819T042909.08_5B7A4C26.MER.DET.WLT5.sac';
[~, h] = readsac(fullfile(exdir, s));
EQ = load(fullfile(exdir, '20180819T042909.08_5B7A4C26.MER.DET.WLT5.evt'), '-mat');
EQ = EQ.EQ;

%% Compute three examples with difference times assigned to the first sample.

% (1) Time is seconds after SAC reference time.
% This is the same pt0 reference as the times in the associated EQ structure.
pt01 = h.B;

[tres1, dat1, syn1, tadj1, ~, delay1, ~, xw1, ~, ~, ~, ~, ~, W1] = ...
    firstarrival(s, false, [], [], [], [], EQ, [], [], [], [], pt01);

% (2) Time is seconds after 0 s.
% In this case, h.B nearly equals 0, so (1) and (2) are indistinguishable.
pt02 = 0;

[tres2, dat2, syn2, tadj2, ~, delay2, ~, xw2, ~, ~, ~, ~, ~, W2] = ...
    firstarrival(s, false, [], [], [], [], EQ, [], [], [], [], pt02);

% (3) Time is seconds after theoretical arrival time (syn = 0). Requires you set
% pt0 at the total time elapsed since start of seismogram to arrival, hence you
% must subtract h.B from syn1 because syn1 is on a time axis where pt0 is
% ALREADY offset by h.B (alternatively, use syn2; see ex_firstarrivals.pdf).
pt03 = -(syn1 - h.B); % == -syn2

[tres3, dat3, syn3, tadj3, ~, delay3, ~, xw3, ~, ~, ~, ~, ~, W3] = ...
    firstarrival(s, false, [], [], [], [], EQ, [], [], [], [], pt03);

% Should be zero.
syn3
diff([tres1 tres2 tres3])
diff([tadj1 tadj2 tadj3])
diff([delay1 delay2 delay3])

%% Plot all.

figure
subplot(311)
plot(W1.xax, xw1)
axis tight
vl_dat1 = vertline(dat1, [], 'r');
vl_syn1 = vertline(syn1, [], 'k');
legend([vl_syn1{1} vl_dat1{1}], sprintf('Theoretical arrival: %.4f', syn1), ...
       sprintf('Observed arrival: %.4f', dat1))
xlabel(sprintf('Seconds after SAC reference time; tres=%.4f (tadj=%.4f)', ...
               tres1, tadj1))

subplot(312)
plot(W2.xax, xw2)
axis tight
vl_dat2 = vertline(dat2, [], 'r');
vl_syn2 = vertline(syn2, [], 'k');
legend([vl_syn2{1} vl_dat2{1}], sprintf('Theoretical arrival: %.4f', syn2), ...
       sprintf('Observed arrival: %.4f', dat2))
xlabel(sprintf('Seconds after 0; tres=%.4f (tadj=%.4f)', ...
               tres2, tadj2))

subplot(313)
plot(W3.xax, xw3)
axis tight
vl_dat3 = vertline(dat3, [], 'r');
vl_syn3 = vertline(syn3, [], 'k');
legend([vl_syn3{1} vl_dat3{1}], sprintf('Theoretical arrival: %.4f', syn3), ...
       sprintf('Observed arrival: %.4f', dat3))
xlabel(sprintf('Seconds after theoretical arrival time; tres=%.4f (tadj=%.4f)', ...
               tres3, tadj3))


%% Prove that datetimes match.
[~, ~, ~, refdate] = seistime(h);

% Should be zero: if you add the arrival time as offset from the SAC reference
% time (and subtracting the tadj; recall, syn1 is tadj with bathtime.m) it
% should be equal to the absolute UTC arrival time in the EQ structure.
seconds((refdate + seconds(syn1) - seconds(tadj1)) - EQ(1).TaupTimes(1).arrivaldatetime)
