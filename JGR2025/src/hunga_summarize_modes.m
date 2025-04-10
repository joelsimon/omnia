function [kstnm, minvp, minvp_depth, maxamp, maxamp_depth, vp, vp_depth, amp, amp_depth] = ...
    hunga_summarize_modes(freq, sigcat, excl48, plt)
% [kstnm, minvp, minvp_depth, maxamp, maxamp_depth, vp, vp_depth, amp, amp_depth] = ...
%     HUNGA_SUMMARIZE_MODES(freq, sigcat, excl48, plt)
%
% Input:
% freq    Frequency of mode, one of 2.5, 5.0, 7.5, or 10 [Hz]
% sigcat  0: category A, B, and C signal (35 stations)
%         1: only category A and B signals (yes signal; 29 stations) [def]
%         2: only category C stations (no signal; 6 stations);
% excl48  Exclude P0048 and P0049 (def: false)
% plt     Plot result (def: false)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 26-Mar-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

clc

% Default mode frequency and signal cateogry.
defval('freq', 2.5);
defval('sigcat', 1)
defval('excl48', false)
defval('plt', false);

% Get station-name list for given signal category.
kstnm = lskstnmcat(sigcat);

% Maybe remove P0048/9.
if excl48
    kstnm(cellstrfind(kstnm, {'P0048' 'P0049'})) = [];

end

% Average-ocean depth/PREM boundary boundary conditions for hunga_read_mode.
mtype = 1;

% Read the mode eigenvalues and the sound-speed profiles (different text files
% and read functions)
for i = 1:length(kstnm)
    [amp_depth{i}, amp{i}, ~, ~, maxamp_depth(i), maxamp(i)] = ...
        hunga_read_modes(kstnm{i}, mtype, freq, false);
    [vp_depth{i}, vp{i}] = hunga_read_ctdprofiles(kstnm{i}, mtype);
    [~, minvp_idx] = min(vp{i});
    minvp(i) = vp{i}(minvp_idx);
    minvp_depth(i) = vp_depth{i}(minvp_idx);

end

ave_minvp = mean(minvp);
ave_minvp_depth = mean(minvp_depth);

med_minvp = median(minvp);
med_minvp_depth = median(minvp_depth);

ave_maxamp = mean(maxamp);
ave_maxamp_depth = mean(maxamp_depth);

med_maxamp = median(maxamp);
med_maxamp_depth = median(maxamp_depth);

fprintf('For %i stations-->\n', length(kstnm))

fprintf('Average min. Vp of %.1f m/s at %i m\n', ave_minvp, round(ave_minvp_depth));
fprintf('Median min. Vp of %.1f m/s at %i m\n\n', med_minvp, round(med_minvp_depth));

fprintf('Average max. mode %.4f at %i m\n', ave_maxamp, round(ave_maxamp_depth));
fprintf('Median max. mode %.4f at %i m\n', med_maxamp, round(med_maxamp_depth));

if plt
    close all
    ax = krijetem(subnum(1,2));

    % Plot sound-speed profiles.
    hold(ax(1), 'on')
    for i = 1:length(kstnm)
        pl_vp(i) = plot(ax(1), vp{i}, vp_depth{i});

    end
    ax(1).YDir = 'reverse';
    xlabel(ax(1), 'Sound Speed [m/s]')
    ylabel(ax(1), 'Depth [m]')
    xlim(ax(1), [1475 1565])
    xticks(ax(1), [1475:25:1550])
    pl_minvp = plot(ax(1), ax(1).XLim, [med_minvp_depth med_minvp_depth], 'k');
    hold(ax(1), 'off')
    uistack(pl_minvp, 'bottom')

    % Plot modes.
    hold(ax(2), 'on')
    for i = 1:length(kstnm)
        pl_amp(i) = plot(ax(2), amp{i}, amp_depth{i}, 'Color', pl_vp(i).Color);

        % Put crosses on outliers where max amplitude at seafloor.
        if max(amp{i}) == amp{i}(end)
            pl_cross(i) = plot(amp{i}(end), amp_depth{i}(end), 'k+');

        end
    end
    ax(2).YDir = 'reverse';
    xlabel(ax(2), 'Pressure Eigenfunction')
    ylabel(ax(2), 'Depth [m]')
    xlim(ax(2), [-0.0008 0.037])
    xticks(ax(2), [0:0.01:0.03])
    pl_maxamp = plot(ax(2), ax(2).XLim, [med_maxamp_depth med_maxamp_depth], 'k');
    hold(ax(2), 'off')
    uistack(pl_maxamp, 'bottom')

    box(ax, 'on')
    longticks(ax, 2);
    axesfs([], 14, 14)
    latimes2

    ylim(ax, [0 6000]);
    ax(2).YLabel = [];
    ax(2).YTickLabel = [];
    moveh(ax(2), -.06)


    % Label axes.
    lbA = text(ax(1), 1478, 150, 'A', 'FontName', 'Helvetica', 'FontWeight',  'Bold', 'FontSize', 13);
    lbB = text(ax(2), 0.0335, 150, 'B', 'FontName', 'Helvetica', 'FontWeight',  'Bold', 'FontSize', 13);
    savepdf(mfilename)

end
