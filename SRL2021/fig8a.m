function fig8a
% FIG8A
%
% Plots core-phase record section including nearby island-station data.
%
% Developed as: simon2021_nearbyPKPrs (and simon2021_PKPrs before that...)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 03-May-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

% Define paths.
merdir = getenv('MERMAID');
evtdir = fullfile(merdir, 'events');
procdir = fullfile(merdir, 'processed');
nearbydir = fullfile(evtdir, 'nearbystations');

% Ensure in GJI21 git branch -- complimentary paper w/ same data set.
startdir = pwd;
cd(evtdir)
system('git checkout GJI21');
cd(procdir)
system('git checkout GJI21');
cd(startdir)

% `recordsection` inputs.
lohi = [1 2];
alignon = 'etime';
ampfac = 1;
normlize = true;
returntype = 'DET';
popas = [4 1];
ph = [];
taper = 2;
otype = 'vel';
incl_CPPT = true;
incl_prelim = false;

% Plot the baseline record section, to be edited and annotated.
id = 10964158;
F = nearbyrecordsection(id, lohi, alignon, ampfac, evtdir, procdir, normlize, ...
                        nearbydir, returntype, ph, popas, taper, otype, ...
                        incl_CPPT, incl_prelim);

axesfs(F.f, 15, 15);
F.txhz.String = sprintf('%.0f--%.0f Hz', lohi);
F.txhz.FontSize = 18;

% Color the ab and bc branches of PKP separately.
PKP_y = F.ph(2).YData;
PKP_x = F.ph(2).XData;

[~, caustic] = min(PKP_y);

PKPab_x = PKP_x(1:caustic);
PKPab_y = PKP_y(1:caustic);

PKPbc_x = PKP_x(caustic:end);
PKPbc_y = PKP_y(caustic:end);

hold(F.ax, 'on')
pl_PKPab = plot(F.ax, PKPab_x, PKPab_y, '-m', 'LineWidth', 1);
pl_PKPbc = plot(F.ax, PKPbc_x, PKPbc_y, '-g', 'LineWidth', 1);

% Edit the PKIKP and PKiKP phase branch colors and lines.
pl_PKIKP = F.ph(1);
pl_PKiKP = F.ph(3);

delete(F.ph(2))
delete(F.lg)

set(F.pltr, 'Color', 'k')
set(pl_PKIKP, 'Color', 'b', 'LineStyle', '-', 'LineWidth', 1)
set(pl_PKiKP, 'Color', 'r', 'LineStyle', '-', 'LineWidth', 1)

lg = legend([pl_PKIKP pl_PKPbc pl_PKiKP pl_PKPab], '\textit{PKIKP}', ...
            '\textit{PKPbc}', '\textit{PKiKP}', '\textit{PKPab}', 'Location', ...
            'NorthWest', 'AutoUpdate', 'off');

% Remove (make invisible) most of the nearby traces.
keep_idx = [5 23 14 7 12 26 6];
set([F.pltr2 F.pltx2], 'Visible', 'off');
set([F.pltr2(keep_idx) F.pltx2(keep_idx)], 'Visible', 'on');

xlim(F.ax, [1050 1400])
ylim(F.ax, [138 160])


axesfs(F.f, 20, 20)
lw = 1
for i = 1:length(F.pltx)
    F.pltx(i).Position(1) = F.pltr(i).XData(1) - 5;
    F.pltx(i).HorizontalAlignment = 'Right';
    F.pltx(i).Color = 'k';
    F.pltr(i).LineWidth = lw;
    F.pltr(i).Color = 'k';

end

gray = [0.6 0.6 0.6];
for i = 1:length(F.pltx2)
    F.pltx2(i).String = strtrim(F.pltx2(i).String);
    F.pltx2(i).Position(1) = F.ax.XLim(2) - 5;
    F.pltx2(i).Position(2) = F.pltr2(i).YData(end) + 0.5;
    F.pltx2(i).HorizontalAlignment = 'Right';
    F.pltx2(i).Color = gray;
    F.pltr2(i).LineWidth = lw;
    F.pltr2(i).Color = gray;

end

latimes
F.tl.Position(1) = mean(F.ax.XLim);
F.tl.Position(2) = 160.25;

hold(F.ax, 'on')
xl = [1170 1230];
yl = [144 156];

plb(1) = plot(F.ax, [xl(1) xl(2)], [yl(1)  yl(1)]);
plb(2) = plot(F.ax, [xl(1) xl(2)], [yl(2)  yl(2)]);

plb(3) = plot(F.ax, [xl(1) xl(1)], [yl(1)  yl(2)]);
plb(4) = plot(F.ax, [xl(2) xl(2)], [yl(1)  yl(2)]);

set(plb, 'LineStyle', '-', 'Color', 'k', 'LineWidth', F.ax.LineWidth)
botz(plb);

% Add labels.
[lgp, txp] = textpatch(F.ax, 'NorthWest', '(a)', 25, 'Helvetica', false);
lgp.Box = 'off';
movev(lgp, 0.11);
moveh(lgp, -0.125);
savepdf(mfilename)
