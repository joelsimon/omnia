function fig12
% FIG12
%
% Figure 12: RMS signal versus RMS noise*
%
% *as explained in paper, really, only Category C signals have noise in earlier
% window (the eruption was bubblin' for a while).
%
% Developed as: hunga_plot_timewindow_rms_signal_noise.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 22-Jan-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

%% Get epicentral distances
[dist_sta, dist_val] = hunga_readgcarc;
%% Get epicentral distance

%% Get RMS values
sig_file = 'hunga_write_timewindow_rms_pre--5min_post-25min_envlen-30s_envtype-rms_2.5-10.0Hz_signal.txt';
noi_file = 'hunga_write_timewindow_rms_pre--5min_post-25min_envlen-30s_envtype-rms_2.5-10.0Hz_noise.txt';

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

ax = plotxy(rms_noi_val, rms_sig_val, ref_sta);
xlabel('RMS Noise (Pa)')
ylabel('RMS Signal (Pa)')

box on

xlim(ylim);
hold(ax, 'on');
plot(xlim, ylim, 'k--');

longticks(ax, 2);
latimes2
axesfs([], 14, 14);
keyboard

ylim([0.03 0.1]);
xlim([0.025 0.075]);
xticks([0.025:0.01:0.075]);

keyboard

%% ___________________________________________________________________________ %%
%% Subfuncs
%% ___________________________________________________________________________ %%

function [sta, val] = order_sta_val(ref_sta, sta, val)

[~, idx] = ismember(ref_sta, sta);
idx(find(~idx)) = [];
sta = sta(idx);
val = val(idx);

%% ___________________________________________________________________________ %%

function ax = plotxy(x, y, sta)

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

    F.rms_tx(i) = text(x(i), y(i)+0.0025, sta{i}, 'HorizontalAlignment', 'Center', 'Color', 'Black');
    % F.rms_tx(i) = text(x(i), y(i)+0.03*range(y), sta{i}, 'HorizontalAlignment', 'Center', ...
    %                'Color', 'black');

end
hold(ax, 'off')
