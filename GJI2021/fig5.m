function fig5
% FIG5
%
% Plots MERMAID record section, w/ and w/o other island stations' data.
%
% Developed as: $SIMON2020_CODE/simon2020_recordsections.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 11-Mar-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

% Define paths.
merdir = getenv('MERMAID');
procdir = fullfile(merdir, 'processed');
evtdir = fullfile(merdir, 'events');
nearbydir = fullfile(evtdir, 'nearbystations');

% Ensure in GJI21 git branch.
startdir = pwd;
cd(procdir)
system('git checkout GJI21');
cd(evtdir)
system('git checkout GJI21');
cd(startdir)

% Parameters for recordsection.m and its filters.
lohi = [1 5];
alignon = 'etime';
ampfac = 2;
normlize = true;
returntype = 'DET';
otype = 'vel';
popas = [4 1];
taper = 2;
incl_prelim = false;

axfs = 20;
txfs = 18;
txfs2 = 14;
lbfs = 28;


%%______________________________________________________________________________________%%
% M5
id = '11146921';
ph = 'p, P, s, S';
F = recordsection(id,  lohi, alignon, ampfac, evtdir, procdir, normlize, returntype, ph, popas, taper, incl_prelim);
axesfs(F.f, axfs, axfs)
set(F.ph, 'Color', 'k');
F.ph(2).Color = [0.6 0.6 0.6];  % Dashed line does not save correctly
F.ph(4).Color = [0.6 0.6 0.6];
F.lg = legend([F.ph(1) F.ph(2)], '\textit{p}, or \textit{P}', '\textit{s}, or \textit{S}');
xlim(F.ax, [-25 425])
F.ax.YTickLabel = cellfun(@(xx) [xx '$^{\circ}$'], F.ax.YTickLabel, 'UniformOutput', false);

set(F.txhz, 'Interpreter', 'LaTeX', 'FontSize', txfs)
set(F.lghz, 'Interpreter', 'LaTeX', 'FontSize', txfs)

[~, th] = labelaxes(gca, 'ul', true, 'FontSize', lbfs, 'Interpreter', 'LaTeX', 'FontName', 'Times');
movev(th, 40);
moveh(th, -50);

set(F.txhz, 'Interpreter', 'LaTeX', 'FontSize', txfs)
set(F.lghz, 'Interpreter', 'LaTeX', 'FontSize', txfs)

botz(F.ph)
F.txhz.String = sprintf('%.0f--%.0f Hz', lohi);
savepdf('fig5a_MER')
close

%%

F = nearbyrecordsection(id, lohi, alignon, 1.5, evtdir, procdir, normlize, ...
                        nearbydir, returntype, ph, popas, taper, otype, true, incl_prelim);
axesfs(F.f, axfs, axfs)
for i = 1:length(F.pltx2); F.pltx2(i).FontSize = txfs2; F.pltx2(i).Position(1) = 825; end
set(F.ph, 'Color', 'k');
xlim(F.ax, [-50 850])
ylim(F.ax, [0 70]);
F.ph(3).Color = [0.6 0.6 0.6];  % Dashed line does not save correctly
F.ph(4).Color = [0.6 0.6 0.6];
F.lg = legend([F.ph(1) F.ph(3)], '\textit{p}, or \textit{P}', '\textit{s}, or \textit{S}');
F.ax.YTickLabel = cellfun(@(xx) [xx '$^{\circ}$'], F.ax.YTickLabel, 'UniformOutput', false);

[~, th] = labelaxes(gca, 'ul', true, 'FontSize', lbfs, 'Interpreter', 'LaTeX', 'FontName', 'Times');
movev(th, 40);
moveh(th, -50);

set(F.txhz, 'Interpreter', 'LaTeX', 'FontSize', txfs)
set(F.lghz, 'Interpreter', 'LaTeX', 'FontSize', txfs)
F.lghz.Location = 'South';

rm_idx = [11, 21, 22, 14, 15, 16, 17, 19, 24, 25, 28, 26, 8, 3, 29, 30, 6, 7, 12, 13];
delete(F.pltx2(rm_idx));
delete(F.pltr2(rm_idx));
F.pltx2(20).Position(2) = 9.5;
F.pltx2(5).Position(2) = 63;
botz(F.ph);
F.txhz.String = sprintf('%.0f--%.0f Hz', lohi);
savepdf('fig5a')
close


%%______________________________________________________________________________________%%
% M6
id = '11109519';
ph = 'p, P, s, S';
F = recordsection(id,  lohi, alignon, ampfac, evtdir, procdir, normlize, returntype, ph, popas, taper, incl_prelim);
axesfs(F.f, axfs, axfs)
set(F.ph, 'Color', 'k');
F.ph(2).Color = [0.6 0.6 0.6];  % Dashed line does not save correctly
F.ph(4).Color = [0.6 0.6 0.6];
F.lg = legend([F.ph(1) F.ph(2)], '\textit{p}, or \textit{P}', '\textit{s}, or \textit{S}');
xlim(F.ax, [-50 650])
F.ax.YTickLabel = cellfun(@(xx) [xx '$^{\circ}$'], F.ax.YTickLabel, 'UniformOutput', false);

[~, th] = labelaxes(gca, 'ul', true, 'FontSize', lbfs, 'Interpreter', 'LaTeX', 'FontName', 'Times');
th.String = strrep(th.String, 'a', 'b');
movev(th, 40);
moveh(th, -50);

set(F.txhz, 'Interpreter', 'LaTeX', 'FontSize', txfs)
set(F.lghz, 'Interpreter', 'LaTeX', 'FontSize', txfs)

botz(F.ph);
F.txhz.String = sprintf('%.0f--%.0f Hz', lohi);
savepdf('fig5b_MER')
close

%%

F = nearbyrecordsection(id, lohi, alignon, 1.5, evtdir, procdir, normlize, ...
                        nearbydir, returntype, ph, popas, taper, otype, true, incl_prelim);
axesfs(F.f, axfs, axfs)
for i = 1:length(F.pltx2); F.pltx2(i).FontSize = txfs2; F.pltx2(i).Position(1) = 825; end
set(F.ph, 'Color', 'k');
xlim(F.ax, [-50 850])
ylim(F.ax, [0 70]);

F.ph(3).Color = [0.6 0.6 0.6];  % Dashed line does not save correctly
F.ph(4).Color = [0.6 0.6 0.6];
F.lg = legend([F.ph(1) F.ph(3)], '\textit{p}, or \textit{P}', '\textit{s}, or \textit{S}');
F.ax.YTickLabel = cellfun(@(xx) [xx '$^{\circ}$'], F.ax.YTickLabel, 'UniformOutput', false);

[~, th] = labelaxes(gca, 'ul', true, 'FontSize', lbfs, 'Interpreter', 'LaTeX', 'FontName', 'Times');
th.String = strrep(th.String, 'a', 'b');
movev(th, 40);
moveh(th, -50);

set(F.txhz, 'Interpreter', 'LaTeX', 'FontSize', txfs)
set(F.lghz, 'Interpreter', 'LaTeX', 'FontSize', txfs)

F.lghz.Location = 'South';
rm_idx = [11 12 19 20 16 17 22 23 28 1 8 2 29 25 26 27 4 5 6 14];
delete(F.pltr2(rm_idx));
delete(F.pltx2(rm_idx))
F.pltx2(18).Position(2) = 10;
F.pltx2(24).Position(2) = 31.5;
F.pltx2(13).Position(2) = 63.75;
F.pltx(end).Position(2) = 47;
botz(F.ph);
F.txhz.String = sprintf('%.0f--%.0f Hz', lohi);
savepdf('fig5b')
close

%%______________________________________________________________________________________%%

% M7
id = '11007849';
ph = 'P';
F = recordsection(id,  lohi, alignon, ampfac, evtdir, procdir, normlize, returntype, ph, popas, taper, incl_prelim);
axesfs(F.f, axfs, axfs)
set(F.ph, 'Color', 'k');
F.lg.String = '\textit{P}';
xlim(F.ax, [400 950])
F.ax.YTickLabel = cellfun(@(xx) [xx '$^{\circ}$'], F.ax.YTickLabel, 'UniformOutput', false);

[~, th] = labelaxes(gca, 'ul', true, 'FontSize', lbfs, 'Interpreter', 'LaTeX', 'FontName', 'Times');
th.String = strrep(th.String, 'a', 'c');
movev(th, 40);
moveh(th, -50);

set(F.txhz, 'Interpreter', 'LaTeX', 'FontSize', txfs)
set(F.lghz, 'Interpreter', 'LaTeX', 'FontSize', txfs)

botz(F.ph);
F.txhz.String = sprintf('%.0f--%.0f Hz', lohi);
savepdf('fig5c_MER')
close

%%

F = nearbyrecordsection(id, lohi, alignon, 1.5, evtdir, procdir, normlize, ...
                        nearbydir, returntype, ph, popas, taper, otype, true, incl_prelim);
axesfs(F.f, axfs, axfs)
for i = 1:length(F.pltx2); F.pltx2(i).FontSize = txfs2; end
xlim(F.ax, [300 1100])
ylim(F.ax, [35 105])
set(F.ph, 'Color', 'k');
F.lg.String = '\textit{P}';
F.ax.YTickLabel = cellfun(@(xx) [xx '$^{\circ}$'], F.ax.YTickLabel, 'UniformOutput', false);

[~, th] = labelaxes(gca, 'ul', true, 'FontSize', lbfs, 'Interpreter', 'LaTeX', 'FontName', 'Times');
th.String = strrep(th.String, 'a', 'c');
movev(th, 40);
moveh(th, -50);

set(F.txhz, 'Interpreter', 'LaTeX', 'FontSize', txfs)
set(F.lghz, 'Interpreter', 'LaTeX', 'FontSize', txfs)

F.lghz.Location = 'South';
rm_idx = [8 2 3 4 12 20 21 22 23 18 19 16 10 14];
delete(F.pltr2(rm_idx));
delete(F.pltx2(rm_idx))
F.tl.Position(2) = 106;
F.pltx(3).Position(2) = 55;
F.pltx(10).Position(2) = 69.25;
F.pltx2(13).Position(2) = 99.2;

botz(F.ph);
F.txhz.String = sprintf('%.0f--%.0f Hz', lohi);
savepdf('fig5c')

% % Remove MERMAID traces to show how we are filling the seismic data gap.
% delete(F.pltx)
% delete(F.pltr)
% savepdf('fig5c_no_MER')
close

%%______________________________________________________________________________________%%

% M8
id = '11041250';
ph = 'P';
F = recordsection(id,  lohi, alignon, ampfac, evtdir, procdir, normlize, returntype, ph, popas, taper, incl_prelim);
axesfs(F.f, axfs, axfs)
set(F.ph, 'Color', 'k');
F.lg.String = '\textit{P}';
xlim(F.ax, [425 975])
F.ax.YTickLabel = cellfun(@(xx) [xx '$^{\circ}$'], F.ax.YTickLabel, 'UniformOutput', false);

[~, th] = labelaxes(gca, 'ul', true, 'FontSize', lbfs, 'Interpreter', 'LaTeX', 'FontName', 'Times');
th.String = strrep(th.String, 'a', 'd');
movev(th, 40);
moveh(th, -50);

set(F.txhz, 'Interpreter', 'LaTeX', 'FontSize', txfs)
set(F.lghz, 'Interpreter', 'LaTeX', 'FontSize', txfs)

botz(F.ph);
F.txhz.String = sprintf('%.0f--%.0f Hz', lohi);
savepdf('fig5d_MER')
close

%%

F = nearbyrecordsection(id, lohi, alignon, 1.5, evtdir, procdir, normlize, ...
                        nearbydir, returntype, ph, popas, taper, otype, true, incl_prelim);
axesfs(F.f, axfs, axfs)
for i = 1:length(F.pltx2); F.pltx2(i).FontSize = txfs2; end
xlim(F.ax, [300 1100])
ylim(F.ax, [35 105])
set(F.ph, 'Color', 'k');
F.lg.String = '\textit{P}';
F.ax.YTickLabel = cellfun(@(xx) [xx '$^{\circ}$'], F.ax.YTickLabel, 'UniformOutput', false);

[~, th] = labelaxes(gca, 'ul', true, 'FontSize', lbfs, 'Interpreter', 'LaTeX', 'FontName', 'Times');
th.String = strrep(th.String, 'a', 'd');
movev(th, 40);
moveh(th, -50);

set(F.txhz, 'Interpreter', 'LaTeX', 'FontSize', txfs)
set(F.lghz, 'Interpreter', 'LaTeX', 'FontSize', txfs)

F.lghz.Location = 'South';
F.tl.Position(2) = 106;
rm_idx = [11 5 6 7 15 25 27 26 8 2 1 24 21 22 18 19 13 17];
delete(F.pltr2(rm_idx))
delete(F.pltx2(rm_idx))
F.pltx(3).Position(2) = 56.5;
F.pltx(4).Position(2) = 56.75;
F.pltx(9).Position(2) = 69.8;
F.pltx2(16).Position(2) = 98.9;

botz(F.ph);
F.txhz.String = sprintf('%.0f--%.0f Hz', lohi);
savepdf('fig5d')
close
