function simon2021SRL_PKPab
% SIMON2021SRL_PKPAB
%
% firstarrival.m plots for 20181025T231330.09_5BD6FE4A.MER.DET.WLT5.sac using
% PKPab- and PKPbc-centered windows.  This is '09' (top trace) in the core-phase
% record section.  This function proves my picker will identify both phases if
% the window is adjusted smartly.
%
% Developed as: simon2021_PKPab.m

% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 24-Jun-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

% Define paths.
merdir = getenv('MERMAID');
evtdir = fullfile(merdir, 'events');
procdir = fullfile(merdir, 'processed');

% Ensure in GJI21 git branch -- complimentary paper w/ same data set.
startdir = pwd;
cd(evtdir)
system('git checkout GJI21');
cd(procdir)
system('git checkout GJI21');
cd(startdir)

s = '20181025T231330.09_5BD6FE4A.MER.DET.WLT5.sac';
EQ = getevt(fullsac(s, procdir), evtdir);

% firstarrival.m parameters.
wlen = 30;
lohi = [1 2];
ci = true;
bathy = true;
wlen2 = 1.75;
fs = [];
popas = [4 1];

% Ensure PKPab.
keyboard
EQ.TaupTimes = EQ.TaupTimes([2 4]);

for i = 1:2
    tmp_EQ = EQ;
    tmp_EQ.TaupTimes = EQ.TaupTimes(i)
    [f, ax, tx] = plotfirstarrival(s, [], [],tmp_EQ, ci, wlen, lohi, [], [], true, ...
                                   wlen2, fs, popas);
    ax.YLabel.String = strrep(ax.YLabel.String, 'Amplitude', 'Counts');
    numticks(ax, 'x', 7);

    pause(0.1)
    tack2corner(ax, tx.ul, 'ul')
    pause(0.1)
    tack2corner(ax, tx.ur, 'ur')
    pause(0.1)
    tack2corner(ax, tx.lr, 'lr')
    pause(0.1)
    tack2corner(ax, tx.ll, 'll')

    keyboard
    close

end
