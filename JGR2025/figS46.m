function figS46
% FIGS46
%
% Figure 46: RMS signal versus RMS noise*
%
% *as explained in paper, really, only Category C signals have noise in earlier
% window (the eruption was bubblin' for a while).
%
% Developed as: hunga_plot_timewindow_rms_signal_noise.m then fig12.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 15-Aug-2025, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

clc
close all

%% Get epicentral distances
[dist_sta, dist_val] = hunga_read_gcarc;
%% Get epicentral distance

%% Get RMS values
sig_file = 'rms_signal.txt';
noi_file = 'rms_noise.txt';

[rms_sig_sta, rms_sig_val] = hunga_read_timewindow_rms(sig_file);
[rms_noi_sta, rms_noi_val] = hunga_read_timewindow_rms(noi_file);
%% Get RMS values

ref_sta = intersect(intersect(rms_sig_sta, rms_noi_sta), dist_sta);
fprintf('\n\nNum. sta.: %i\n\n', length(ref_sta))

[dist_sta, dist_val] = order_sta_val(ref_sta, dist_sta, dist_val);
[rms_sig_sta, rms_sig_val] = order_sta_val(ref_sta, rms_sig_sta, rms_sig_val);
[rms_noi_sta, rms_noi_val] = order_sta_val(ref_sta, rms_noi_sta, rms_noi_val);

if ~isequal(dist_sta, rms_sig_sta, rms_noi_sta)
    error('List of station names/values not identically ordered')

end

%rms_sig_val = rms_sig_val .* sqrt(dist_val);

[ax, F] = plotxy(rms_noi_val, rms_sig_val, ref_sta);
xlabel('RMS Noise [Pa]')
ylabel('RMS Signal [Pa]')

box on

xlim(ylim);
hold(ax, 'on');
plot(xlim, ylim, 'k');
plot(xlim, 2*ylim, 'k--');
xlim([0 0.3]);
ylim([0 0.85])

xl = [0.025 0.075];
yl = [0.03 0.1];

longticks(ax, 2);
hold on
% Rectangle defines a new axis
rec = rectangle(ax, 'Position', [xl(1) yl(1) xl(2)-xl(1) yl(2)-yl(1)], 'EdgeColor', 'r')
axes(ax)
movev(F.rms_tx, +0.03)
xy = proplim(ax, [0.05 0.95]);
axesfs([], 14, 14);
latimes2
lbl = text(xy(1), xy(2), 'A', 'FontName', 'Helvetica', 'FontWeight',  'Bold', ...
           'Color', 'k', 'FontSize', 15);
savepdf('A')
delete(lbl)

xlim(xl);
ylim(yl);
xticks([0.025:0.01:0.075]);
xy = proplim(ax, [0.05 0.95]);
lbl = text(xy(1), xy(2), 'B', 'FontName', 'Helvetica', 'FontWeight',  'Bold', ...
           'Color', 'k', 'FontSize', 15);
movev(F.rms_tx, -0.027)
delete(rec)
savepdf('B')

%% ___________________________________________________________________________ %%
%% Subfuncs
%% ___________________________________________________________________________ %%

function [sta, val] = order_sta_val(ref_sta, sta, val)

[~, idx] = ismember(ref_sta, sta);
idx(find(~idx)) = [];
sta = sta(idx);
val = val(idx);

%% ___________________________________________________________________________ %%

function [ax, F] = plotxy(x, y, sta)

sigtype = catsac;

figure
ax =  gca;
hold(ax, 'on')
for i = 1:length(sta)
    if strcmp(sigtype.(sta{i}), 'A')
        Color = [0 0 1];
        %continue

    elseif strcmp(sigtype.(sta{i}), 'B')
        Color = [0 0 0];

    elseif strcmp(sigtype.(sta{i}), 'C')
        Color = [0.6 0.6 0.6];

    else
        error('unexpected signal type')

    end

    if ~startsWith(sta{i}, 'H')
        F.rms_pl(i) = plot(x(i), y(i), 'v', 'MarkerFaceColor', Color, 'MarkerEdgeColor', ...
                       'black', 'MarkerSize', 10);

    else
        F.rms_pl(i) = plot(x(i), y(i), 'd', 'MarkerFaceColor', Color, 'MarkerEdgeColor', ...
                       'black', 'MarkerSize', 10);
    end

    F.rms_tx(i) = text(x(i), y(i), sta{i}, 'HorizontalAlignment', 'Center', 'Color', 'Black');
    
end
hold(ax, 'off')
