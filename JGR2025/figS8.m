function figS8
% FIGS8
%
% Figure S8: Acoustic eigenfunctions (modes)
% 
% Unfortunately `boxplot` is a trash function and expands the figure, leaving
% a lot of whitespace on the lhs. Use trim, crop in LaTeX.
%
% Developed as: hunga_plot_modes.m then fig8.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 15-Aug-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

clc
close all

tz = 1350;
freq = 2.5;

% Mode type and boundary conditions for hunga_read_modes.
mtype_deep = 1;
mtype_shallow = 2;

% For mode summary: only include A and B signals.
sigcat = 1;
excl48 = false;

% Establish axis limits.
xl = [-0.0008 0.055];
yl = [0 6000];

xt = [0:0.015:0.05];
yt = [0:1000:6000];

% Generate subplot.
ax = krijetem(subnum(1,2));
f = gcf;
moveh(ax(2), -.06)

%% P0045
%% ___________________________________________________________________________ %%
% Get 2.5 Hz fundamental mode of archetypal station, say P0045.
kstnm45 = 'P0045';
local_ocdp45 = 5640;
[mode_depth45, mode_amp45, stdp45] = hunga_read_modes(kstnm45, mtype_deep, freq);
ave_ocdp45 = mode_depth45(end);

% Get average station/ocean depths for stations with signal (category A and B).
[sig_stdp45, sig_ocdp45] = hunga_average_depths(1);

% Get average station/ocean depths for stations with no signal (category C);
[nul_stdp, nul_ocdp] = hunga_average_depths(2);

% Get average depths of mode maximums.
[~, ~, ~, ~, maxamp_depth] = hunga_summarize_modes(freq, sigcat, excl48, false);

% Get mode value at stdp.
mode_stdp45 = mode_amp45(nearestidx(mode_depth45, stdp45));

% Plot mode.
axes(ax(1))
hold('on')
pl_mode45 = plot(mode_amp45, mode_depth45, 'k', 'LineWidth', 1);
pl_stdp45 = plot(mode_stdp45, stdp45, 'v', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k', 'MarkerSize', 22);
tx45 = text(mode_stdp45, stdp45, '45', 'Color', 'w', 'HorizontalAlignment', 'Center');

ax(1).YDir = 'reverse';
xlabel('Pressure Eigenfunction At P0045')
ylabel('Depth [m]');
box('on')

% Overlay boxplots.
boxplot(sig_stdp45, 'Positions', 0.04, 'Widths', 0.014, 'colors', 'b');
tx_stdp = text(0.04, 1250, 'STDP', 'HorizontalAlignment', 'Center', 'Color', 'b');
boxplot(sig_ocdp45, 'Positions', 0.04, 'Widths', 0.014, 'colors', 'k');
tx_ocdp = text(0.04, 5000, sprintf('GCP\nOCDP'), 'HorizontalAlignment', 'Center', 'Color', 'k');
boxplot(maxamp_depth, 'Positions', 0.01, 'Widths', 0.014, 'colors', 'k', 'Symbol', '+k');
tx_mode = text(0.01, 975, sprintf('Mode\nMax.'), 'HorizontalAlignment', 'Center', 'Color', 'k');

xlim(xl);
ylim(yl);
xticks(xt);
yticks(yt);
xticklabels(xticks);
yticklabels(yticks);

pl_ave_ocdp45 = plot([xl(1) 0.0255], [ave_ocdp45 ave_ocdp45], 'k-');
tx_ave_ocdp45 = text(0.002, 5375, 'Ave. OCDP', 'Color', 'k');

pl_local_ocdp45 = plot([xl(1) 0.0255], [local_ocdp45 local_ocdp45], 'r-');
%pl_local_ocdp45 = plot([xl(1) 0.0255/2], [local_ocdp45 local_ocdp45], 'r-');
tx_local_ocdp45 = text(0.0015, 5800, 'Local OCDP', 'Color', 'r');

longticks(ax(1), 2)
hold('off')

%% H11S3
%% ___________________________________________________________________________ %%
kstnmh11 = 'H11S3';
local_ocdph11 = 1146;  % from ims, not gebco
[mode_depthh11_deep, mode_amph11_deep, stdph11] = hunga_read_modes(kstnmh11, mtype_deep, freq);
mode_stdph11_deep = mode_amph11_deep(nearestidx(mode_depthh11_deep, stdph11));
ave_ocdph11 = mode_depthh11_deep(end);

[mode_depthh11_shallow, mode_amph11_shallow] = hunga_read_modes(kstnmh11, mtype_shallow, freq);
mode_stdph11_shallow = mode_amph11_shallow(nearestidx(mode_depthh11_shallow, stdph11));

% Plot mode.
axes(ax(2));
hold('on')
pl_mode_deep = plot(mode_amph11_deep, mode_depthh11_deep, 'k', 'LineWidth', 1);
pl_mode_shallow = plot(mode_amph11_shallow, mode_depthh11_shallow, 'k--', 'LineWidth', 1);

pl_stdph11_shallow = plot(mode_stdph11_shallow, stdph11, 'd', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k', 'MarkerSize', 22);
pl_stdph11_deep = plot(mode_stdph11_deep, stdph11, 'd', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k', 'MarkerSize', 22);

ax(2).YDir = 'reverse';
xlabel('Pressure Eigenfunction At H11S3')
ylabel('Depth (m)');
box('on')

lg = legend([pl_stdph11_shallow pl_mode_shallow pl_mode_deep], ...
            'H11S3 Station Depth', 'Local-OCDP Mode', 'Average-OCDP Mode', ...
            'AutoUpdate', 'off', 'Location', 'South');

pl_ave_ocdph11 = plot([xl(1) 0.0255], [ave_ocdph11 ave_ocdph11], 'k-');
tx_ave_ocdph11 = text(0.002, 4200, 'Ave. OCDP', 'Color', 'k');

pl_local_ocdph11 = plot([xl(2)-0.0255 xl(2)], [local_ocdph11 local_ocdph11], 'r-');
%pl_local_ocdph11 = plot([xl(2)-0.0255/2 xl(2)], [local_ocdph11 local_ocdph11], 'r-');
tx_local_ocdph11 = text(0.032, 1320, 'Local OCDP', 'Color', 'r');

xlim(xl);
ylim(yl);
xticks(xt);
yticks(yt);
xticklabels(xticks);
yticklabels(yticks);

longticks(ax(2), 2)
axesfs(f, 14, 14)
ax(2).XTickLabelRotation = 0;
latimes2
hold('off')

ax(2).YTickLabels = [];
ax(2).YLabel = [];

% Label axes.
lbA = text(ax(1), 0.05, 200, 'A', 'FontName', 'Helvetica', 'FontWeight',  'Bold', 'FontSize', 13);
lbB = text(ax(2), 0.05, 200, 'B', 'FontName', 'Helvetica', 'FontWeight',  'Bold', 'FontSize', 13);
savepdf(mfilename)

% Finish with some printouts.
p45_amp_diff = mode_amp45(nearestidx(mode_depth45, abs(tz))) / mode_amp45(nearestidx(mode_depth45, 3000));
h11_amp_diff = mode_stdph11_shallow / mode_stdph11_deep;

fprintf('P0045 amp. at %i m is %.1fx biggger than at 3000 m\n', abs(tz), p45_amp_diff);
fprintf('H11S3 shallow is %.1f bigger than deep (at STDP %i m)\n', h11_amp_diff, stdph11);
