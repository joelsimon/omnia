% FIGURE 3a--c
%
% Cite: Simon, J. D. et al., (2020), BSSA, doi: 10.1785/0120190173
%
% I.e., image2normlysmix.m with some formatting.  See notes at bottom
% of that function for further discussion.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 09-Jan-2020, Version 2017b on GLNXA64

clear
close all

% Presets
perc = 25;
trusigmas = [1 sqrt(2)];
axlim = [0.5 1.5];
npts = 1e3+1;
lx = 1e3;
bp = 500;
ntests = 1e3;
tinc = 0.25;

% Plot it.
[f1, f2, f3, maxly, nMLE, sMLE] = image2normlysmix(perc, trusigmas, ...
                                                  lx, bp, axlim, ...
                                                  npts, ntests, tinc);

clim = [-1640 -1590];
set([f1.ax1 f2.ax1 f3.ax1], 'CLim', clim)
set([f1.cf f2.cf f3.cf], 'Limits', clim)

for f = [f1 f2 f3]
    colormap(f.ax1, jet(8))
    shrink([f.ax1 f.ax2], 1.75, 1.75)

    set(f.cf, 'FontSize', get(f.ax1, 'FontSize'), 'FontName', 'Times', 'Location', 'SouthOutside');
    shrink(f.cf, 1, 1.5)
    set([f.tx1 f.tx2], 'Visible', 'off')
    set([f.ax1 f.ax2], 'TickLength', [0.025 0.025])
    set(f.cf, 'TickLength', 0.025)

    f.cf.Label.Interpreter = 'Latex';
    f.cf.Label.FontSize = f.ax1.XLabel.FontSize;
    numticks(f.cf, 'y', 3);

    movev([f.ax1 f.ax2], 0.1)
    movev(f.cf, 0.08)
    movev(f.ax1.XLabel, -5)
    moveh(f.ax1.YLabel, -5)
    movev(f.ax2.XLabel, 5)
    moveh(f.ax2.YLabel, 5)

end

% Manually label.
text(f1.ax1, -200, 1200, '(a)', 'FontSize', 12)
text(f2.ax1, -200, 1200, '(b)', 'FontSize', 12)
text(f3.ax1, -200, 1200, '(c)', 'FontSize', 12)

% Pause for a second and then adjust the axes so they match.
pause(1)
f1.ax2.Position = f1.ax1.Position;
f2.ax2.Position = f2.ax1.Position;
f3.ax2.Position = f3.ax1.Position;

savepdf('fig3a', f1.f)
savepdf('fig3b', f2.f)
savepdf('fig3c', f3.f)
