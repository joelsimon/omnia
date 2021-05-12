function fig2
% FIG2
%
% Plots an S wave record section.
%
% Developed as: simon2021_swave
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 12-May-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

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

% Parameters for recordsection.m and its filters.
lohi = [0.10 0.20]; % Hz
alignon = 'etime';
ampfac = 2;
nearbydir = fullfile(evtdir, 'nearbystations');
normlize = true;
returntype = 'DET';
otype = 'vel';
popas = [4 1];
taper = false;
incl_prelim = false;

axfs = 20;
txfs = 18;
txfs2 = 14;
lbfs = 28;

%%______________________________________________________________________________________%%
% S wave -- turn tapering off!
filename = 'simon2021_swave';
id = '10953779'
ph = 'p, P, s, S';
F = recordsection(id, lohi, alignon, 2, evtdir, procdir, normlize, returntype, ...
                  ph, popas, taper, incl_prelim);

F.txhz.String = sprintf('%.1f--%.1f Hz', lohi);
axesfs(F.f, axfs, axfs)
set([F.pltr F.pltx], 'Color', 'k')
set(F.ph, 'Color', 'k');
xlim(F.ax, [-0 400])
ylim(F.ax, [6 16])
F.ph(2).Color = 'r';
F.ph(4).Color = 'r';

F.pltx(1).Position(1) = 5;
F.pltx(2).Position(1) = 30;
F.pltx(3).Position(1) = 50;

F.lg = legend([F.ph(1) F.ph(2)], '\textit{p}, or \textit{P}', '\textit{s}, or \textit{S}');
F.ax.YTickLabel = cellfun(@(xx) [xx '$^{\circ}$'], F.ax.YTickLabel, 'UniformOutput', false);

set(F.txhz, 'Interpreter', 'LaTeX', 'FontSize', 0.9*txfs)
set(F.lghz, 'Interpreter', 'LaTeX', 'FontSize', 0.9*txfs)

botz(F.ph);

savepdf(mfilename)
close

% Print the catalog this event metadata was culled from.
[s, EQ] = getsacevt(id, evtdir, procdir, true, 'DET');
for i = 1:length(s)
    fprintf('\n')
    s{i}
    [~, contrib_author, ~] = eventid(EQ{i})

end
