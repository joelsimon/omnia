function ax = fig7_8_S45(tz, algo, crat, prev, los)
% ax = fig7_8_S45(tz, algo, crat, prev, los)
%
% Figures 7, 8, S45: SPL vs distance
%                    SPL* vs occlusion value
%                    RMS vs occlusion rank
% See internal comments for switches to generate various iterations of each.
%
% For inputs, see orderkstnm_occl.m
%
% Developed as: hunga_plot_timewindow_rms.m then fig11_13_14.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 15-Aug-2025, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

clc
close all

%% For Figure 7: all false except `only_sig` (keep Figure 5 window)
%% >> fig7_8_S45(-1350, 1, 1.0, false, false)
%%
%% For Figure 8: all false except `only_sig` (keep Figure 1 window)
%% 8a >> fig7_8_S45(-1350, 1, 0.0, false, false)
%% 8b >> fig7_8_S45(-1350, 1, 0.6, false, false)
%% 8c >> fig7_8_S45(-1350, 1, 1.0, false, false)
%%
%% For Figure S45: all false (keep Figure 4 window)
%% >> fig7_8_S45(-1350, 1, 1.0, false, false)
skip_occ0 = false;
skip_ims = false;
skip_H11 = false;
skip_H03 = false;
skip_21_22 = false;
skip_35 = false;
skip_48_49 = false;
skip_48 = false;
skip_49 = false;
only_peaky = false;
only_sig = true;

switch crat
  case 0
    lColor = 'r';

  case 0.6
    lColor = orange

  case 1.0
    lColor = 'm';

  otherwise
    lColor = 'k'

end

%%%%% Really should have one REFERENCE station list, not keep, e.g., occ_sta,
%%%%% after I've sorted all value lists.

%% Get epicentral distances
[dist_sta, dist_val] = hunga_read_gcarc;
%% Get epicentral distance

%% Get station depths
stdp = hunga_read_stdp;
stdp_sta = fieldnames(stdp);
stdp_val = structfun(@(xx) xx, stdp);
%% Get station depths

%% Get occlusion stats
[occ_sta, occ_val] = orderkstnm_occl([], tz, algo, crat, prev, los);
%[occ_sta, occ_val] = orderkstnm_geo([], 'azimuth', 'N0002');
%% Get occlusion stats

%% Get RMS stats
%rmsfile = 'hunga_write_timewindow_rms_pre--5min_post-25min_envlen-30s_envtype-rms_2.5-10.0Hz_signal.txt';
rmsfile = 'rms_signal.txt';
[rms_sta, rms_val] = hunga_read_timewindow_rms(rmsfile);
%% Get RMS stats

%%
if skip_occ0
    occ_0 = find(~occ_val);
    occ_sta(occ_0) = [];
    occ_val(occ_0) = [];

end

if skip_35
    occ_35 = cellstrfind(occ_sta, 'P0035');
    occ_sta(occ_35) = [];
    occ_val(occ_35) = [];

end

if skip_H03
    occ_H03 = cellstrfind(occ_sta, 'H03');
    occ_sta(occ_H03) = [];
    occ_val(occ_H03) = [];

end

if skip_48
    occ_48 = cellstrfind(occ_sta, 'P0048');
    occ_sta(occ_48) = [];
    occ_val(occ_48) = [];

end

if skip_ims
    occ_ims = cellstrfind(occ_sta, {'H11' 'H03'});
    occ_sta(occ_ims) = [];
    occ_val(occ_ims) = [];

end

if skip_21_22
    occ_21_22 = cellstrfind(occ_sta, {'P0021' 'P0022'});
    occ_sta(occ_21_22) = [];
    occ_val(occ_21_22) = [];

end

if skip_H11
    occ_11 = cellstrfind(occ_sta, 'H11');
    occ_sta(occ_11) = [];
    occ_val(occ_11) = [];

end

if skip_48_49
    occ_48_49 = cellstrfind(occ_sta, {'P0048' 'P0049'});
    occ_sta(occ_48_49) = [];
    occ_val(occ_48_49) = [];

end

if skip_49
    occ_49 = cellstrfind(occ_sta, 'P0049');
    occ_sta(occ_49) = [];
    occ_val(occ_49) = [];

end

if only_sig
    [~, idx] = keepsigsac(occ_sta);
    occ_sta = occ_sta(idx);
    occ_val = occ_val(idx);

end

if only_peaky
    [~, idx] = keeppeakysac(occ_sta);
    occ_sta = occ_sta(idx);
    occ_val = occ_val(idx);

end
%%

ref_sta = intersect(intersect(intersect(dist_sta, stdp_sta), occ_sta), rms_sta);
fprintf('\n\nNum. sta.: %i\n\n', length(ref_sta))

[dist_sta, dist_val] = order_sta_val(ref_sta, dist_sta, dist_val);
[stdp_sta, stdp_val] = order_sta_val(ref_sta, stdp_sta, stdp_val);
[occ_sta, occ_val] = order_sta_val(ref_sta, occ_sta, occ_val);
[rms_sta, rms_val] = order_sta_val(ref_sta, rms_sta, rms_val);

if ~isequal(dist_sta, stdp_sta, rms_sta, occ_sta)
    error('List of station names/values not identically ordered')

end

%% ___________________________________________________________________________ %%

% Sound pressure level (dB re uPa, although NIST specs say don't print "dB")
p_val = rms_val;
p_sta = rms_sta;

% Distance normalizer: multiply
% "wave's energy is directly proportional to its amplitude squared"
% RMS and amplitude are linearly related
% sound pressure is RMS
% sound pressure decays as 1/sqrt(r) for cylindrical spreading
% https://sengpielaudio.com/calculator-distancelaw.htm
p_star_val = p_val .* sqrt(dist_val);
p_star_sta = p_sta;

%% If we wanted to correct for depth, which we don't (mode argument)
%d_prime = norm_mode_amp(p_sta);
%p_star_val = p_star_val ./ d_prime;
%% If we wanted to correct for depth, which we don't (mode argument)

% Sound pressure level (dB re 1 uPa) but what are the units, REALLY (deg dB re 1
% uPa?)...you normalize by a distance (deg or km) and then by a normed depth, so
% that's unitless...maybe you out to normalize distance by the max of the set,
% as before. d_prime is normed already;
Lp_star_val = spl(p_star_val, 1);
Lp_star_sta = p_star_sta;

[~, max_idx] = max(Lp_star_val);
max_Lp_star_val = Lp_star_val(max_idx);
max_Lp_star_sta = Lp_star_sta{max_idx};

x = log10(occ_val+1);
y = Lp_star_val - max_Lp_star_val;

[ax(1), F(1)] = plotxy(x, y, occ_sta, 0);

xlabel('Log Occlusion Count')
switch crat
  case 0.0
    frestr = 'Great-Circle Path Only';
    %frestr = 'Great-Circle Path Only [\Lambda_{0.0}]';
    %xlabel('Log Occlusion Count, Great-Circle Path Only [\Lambda_{0.0}]')

  case 0.6
    frestr = sprintf('60%s Fresnel Clearance', '%');
    %frestr = sprintf('60%s Fresnel Clearance [\\Lambda_{0.6}]', '%');
    %xlabel(sprintf('Log Occlusion Count, 60%s Fresnel Clearance [\\Lambda_{0.6}]', '%'))

  case 1.0
    frestr = 'Full Fresnel Zone';
    %frestr = 'Full Fresnel Zone [\\Lambda_{1.0}]';
    %xlabel('Log Occlusion Count, Full Fresnel Zone [\\Lambda_{1.0}]');

end
if ismember(crat, [0.0 0.6 1.0])
    frestx = text(0.5, -18.25, frestr, 'HorizontalAlignment', 'Center');

end

% LaTeX
%ylabel('log$_{10}$(RMS$^2\cdot\|\Delta\|$)')

% tex
ylabel(sprintf('Adjusted Sound Pressure Level, {\\itL}_{\\itp}^* [dB from %s]', max_Lp_star_sta));

ax(1).XLim(1) = ax(1).XLim(1) - 0.025*range(ax(1).XLim);
ax(1).XLim(2) = ax(1).XLim(2) + 0.025*range(ax(1).XLim);

% Compute best-fitting linear reguression model
[r2, p, ~, yfit] = linreg(x, y, 1);

% x,y aren't sorted -- order them by occlusion so that (e.g., dashed) lines
% can be rendered correctly
xyfit = sortrows([x yfit]);

hold(ax(1), 'on')
pf = plot(xyfit(:, 1), xyfit(:, 2), 'Color', lColor, 'LineWidth', 2);
uistack(pf, 'bottom');

% Compute breadth of 0-occlusion stations; add that line above/below
% least-squares fit.
occ0_idx = find(occ_val == 0);
if ~skip_occ0 && ~isempty(occ0_idx)
    occ0_y = y(occ0_idx);
    occ0_rng = range(occ0_y);
    pf_top = plot(xyfit(:, 1), xyfit(:, 2) + 0.5*occ0_rng, 'k--', 'LineWidth', 1);
    pf_bot = plot(xyfit(:, 1), xyfit(:, 2) - 0.5*occ0_rng, 'k--', 'LineWidth', 1);

end
uistack([pf_top pf_bot], 'bottom')

%% Compute bootstrapped statistics
% https://www.mathworks.com/help/stats/linearmodel.predict.html#namevaluepairarguments
% https://www.mathworks.com/matlabcentral/answers/1988948-confidence-intervals-returned-by-predict

% The anon func linreg_local returns (for each instance of nboot) a 1x3 array
% of r2, p(1) (slope) and p(2) (intercept) for a order 1 polynomail.
nboot = 1e3;
[boot_r2_p1_p2, boot_idx] = bootstrp(nboot, @(a, b) linreg_local(a, b), x, y);
boot_r2 = boot_r2_p1_p2(:,1);
boot_p1 = boot_r2_p1_p2(:,2);
boot_p2 = boot_r2_p1_p2(:,3);

% % and it's confidence interval (this is just for r2 of slope)
% boot_std_err = std(boot_r2) / sqrt(nboot);
% boot_tscore = tinv([0.025  0.975], nboot - 1);
% boot_ci = mean(boot_r2) + boot_tscore * boot_std_err; % CI in terms of real numbers
% boot_ci = 0.5*range(boot_ci); % CI in terms of +- the mean

% also: fitdist(boot_r2, 'normal'); so 95 % confidence on mean(boot_r2)
% https://www.mathworks.com/matlabcentral/answers/159417-how-to-calculate-the-confidence-interval
%https://www.mathworks.com/matlabcentral/answers/324973-95-area-under-data-set

% Generate normal distribution objects for each model estimate.
[boot_r2_mu, boot_r2_ci] = pdboot(boot_r2);
[boot_p1_mu, boot_p1_ci] = pdboot(boot_p1);
[boot_p2_mu, boot_p2_ci] = pdboot(boot_p2);

% Plot some randomly chosen bootstrapped regressions in gray. Note not all
% lines to max(x) because resampling didn't pick those values; most always it
% will go to min(x) because there are so many 0 occlusion values that
% statistically they get sampled.
rand_idx = randi(nboot, 10, 1);
for i = 1:length(rand_idx)
    boot_col = boot_idx(:, rand_idx(i));
    rand_x = x(boot_col);
    rand_y = y(boot_col);
    [rand_r2, rand_p, rand_r2_adj, rand_yfit] = linreg(rand_x, rand_y, 1);
    boot_pf(i) = plot(rand_x, rand_yfit, 'Color', ColorGray);

    % Verify this (recomputed) r^2 value matches index of bootstrp anon func
    if ~isequal(boot_r2(rand_idx(i)), rand_r2)
        error('Bootstrapping with anonymous function not indexing as expected')

    end
end
uistack(boot_pf, 'bottom')
box on
longticks([], 2);
ax(1).FontSize = 14;

xlim([-0.1 3.5]);

latimes2(gcf)

xlim([-0.1 3.5]);
ylim([-25 5]);

rngy = range(ax(1).YLim);
midy = ax(1).YLim(1) + 0.5*rngy;

dstr = sprintf('\\boldmath{$L_p^*  = %0.1f \\log_{10}( \\Lambda_{%.1f} +1) %0.1f$}\n\\boldmath{$R^2=%.2f$}', p(1), crat, p(2), r2);
tx_d = text(0.93*ax(1).XLim(2), midy+0.40*rngy, dstr, 'Color', lColor, ...
            'HorizontalAlignment', 'Right', 'FontSize', 14, 'Interpreter', ...
            'LaTex');

fr_x = linspace(0, 1, 100);
fr_y = fresnelradius(fr_x, 1, 1, 1/25);

for i = 1:length(F(1).rms_tx)
    if any(strcmp(F(1).rms_tx(i).String, {'H11S3' 'H11S1' 'H11N2' 'H11N3' 'H03S3' 'H03S2'}))
        F(1).rms_tx(i).String = '';
        continue

    end
    if strcmp(F(1).rms_tx(i).String, 'H11S2')
        F(1).rms_tx(i).String = 'H11S1-H11S3';
        %F(1).rms_tx(i).String = ['H11S1'  char(8211) 'H11S3']

    end
    if strcmp(F(1).rms_tx(i).String, 'H11N1')
        F(1).rms_tx(i).String = 'H11N1-H11N3';
        %F(1).rms_tx(i).String = ['H11N1'  char(8211) 'H11N3']

    end
    if strcmp(F(1).rms_tx(i).String, 'H03S1')
        F(1).rms_tx(i).String = 'H03S1-H03S3';
        %F(1).rms_tx(i).String = ['H03S1'  char(8211) 'H03S3']

    end
end

%% To set positions I manually adjusted (arrow above graph in MATLAB figure), then:
%% pos = gettxpos(F(1).rms_tx);
%% save('static/fig8[a-c]_pos.mat', 'pos');

% These pos .mat files are only valid for Figs. 7 and 8 where we only keep
% category A and B signals; I didn't adjust for null (Category C) labels, so we
% want to skip this section when making, e.g., the rank figure of S45.
if only_sig
    if crat == 0
        lb1 = text(0, 3.5, 'A', 'FontName', 'Helvetica', 'FontWeight',  'Bold', 'FontSize', 15);
        plot(fr_x, fr_y-21.5, 'k:');
        plot(fr_x, -fr_y-21.5, 'k:');

        plot(fr_x, 0.6*fr_y-21.5, 'k:');
        plot(fr_x, -0.6*fr_y-21.5, 'k:');

        plot(fr_x, repmat(-21.5, size(fr_x)), 'Color', lColor, 'LineWidth', 2);

        load('static/fig8a_pos.mat', 'pos');
        for i = 1:length(F(1).rms_tx)
            F(1).rms_tx(i).Position = pos(i,:);
            F(1).rms_tx(i).Position(3) = 1;

        end
    elseif crat == 0.6
        lb1 = text(0, 3.5, 'B', 'FontName', 'Helvetica', 'FontWeight',  'Bold', 'FontSize', 15);
        plot(fr_x, fr_y-21.5, 'k:');
        plot(fr_x, -fr_y-21.5, 'k:');

        plot(fr_x, repmat(-21.5, size(fr_x)), 'k:');

        plot(fr_x, 0.6*fr_y-21.5, 'Color', lColor, 'LineWidth', 2);
        plot(fr_x, -0.6*fr_y-21.5, 'Color', lColor, 'LineWidth', 2);

        load('static/fig8b_pos.mat', 'pos');
        for i = 1:length(F(1).rms_tx)
            F(1).rms_tx(i).Position = pos(i,:);
            F(1).rms_tx(i).Position(3) = 1;

        end
    elseif crat == 1.0
        lb1 = text(0, 3.5, 'C', 'FontName', 'Helvetica', 'FontWeight',  'Bold', 'FontSize', 15);

        plot(fr_x, 0.6*fr_y-21.5, 'k:');
        plot(fr_x, -0.6*fr_y-21.5, 'k:');

        plot(fr_x, repmat(-21.5, size(fr_x)), 'k:')

        plot(fr_x, fr_y-21.5, 'Color', lColor, 'LineWidth', 2);
        plot(fr_x, -fr_y-21.5, 'Color', lColor, 'LineWidth', 2);

        load('static/fig8c_pos.mat', 'pos');
        for i = 1:length(F(1).rms_tx)
            F(1).rms_tx(i).Position = pos(i,:);
            F(1).rms_tx(i).Position(3) = 1;

        end
    end
end
hold(ax(1), 'off')

%% ___________________________________________________________________________ %%

figure

lm = fitlm(x, y)
plot(lm);
hold on
lax = gca;

predx = linspace(min(x), max(x), 100)';
[~, ycur1] = predict(lm, predx, 'Prediction', 'Curve', 'Simultaneous', false);
xycur1 = sortrows([predx ycur1]);
aaa = plot(xycur1(:, 1), xycur1(:, 2), 'b', 'DisplayName', 'Curve');
bbb = plot(xycur1(:, 1), xycur1(:, 3), 'b', 'HandleVisibility','off');
uistack([aaa bbb], 'bottom')

[~, ycur2] = predict(lm, predx, 'Prediction', 'Curve', 'Simultaneous', true);
xycur2 = sortrows([predx ycur2]);
plot(xycur2(:, 1), xycur2(:, 2), 'r', 'DisplayName', 'Curve, Simultaneous');
plot(xycur2(:, 1), xycur2(:, 3), 'r', 'HandleVisibility','off');

[~, yobs1] = predict(lm, predx, 'Prediction', 'Observation', 'Simultaneous', false);
xyobs1 = sortrows([predx yobs1]);
plot(xyobs1(:, 1), xyobs1(:, 2), 'g', 'DisplayName', 'Observation');
plot(xyobs1(:, 1), xyobs1(:, 3), 'g', 'HandleVisibility','off');

[~, yobs2] = predict(lm, predx, 'Prediction', 'Observation', 'Simultaneous', true);
xyobs2 = sortrows([predx yobs2]);
plot(xyobs2(:, 1), xyobs2(:, 2), 'y', 'DisplayName', 'Observation, Simultaneous');
plot(xyobs2(:, 1), xyobs2(:, 3), 'y', 'HandleVisibility','off');

%% ___________________________________________________________________________ %%
% Plot occlusion as a function of distance.

ax(2) =  plotxy(dist_val, x, occ_sta);
xlabel('Epicentral Distance [deg.]')
ylabel('Log Occlusion Count')

[dist_r2, dist_p, ~, dist_yfit] = linreg(dist_val, x, 1);
hold(ax(2), 'on')
dist_pf = plot(dist_val, dist_yfit, 'k:');
uistack(dist_pf, 'bottom');
hold(ax(2), 'off')
box on
longticks([], 2);

textpatch(gca, 'NorthEast', sprintf('R^2=%.2f', dist_r2), [], [], false);
latimes2(gcf)
shg
hold(ax(2), 'off')
ax(2).FontSize = 14;


%% ___________________________________________________________________________ %%
% Plot by rank - sortrows would be clearer here; but "don't fix it if it aint broke"

[rank_x, rank_y, rank_sta] = rankit(occ_val, rms_val, occ_sta, rms_sta);

ax(3) = plotxy(rank_x, rank_y, rank_sta, 1);
hold(ax(3), 'on')
rank_line = plot(rank_x, rank_y, 'k');
uistack(rank_line, 'bottom');
hold(ax(3), 'off')

ax(3).YDir = 'reverse';
ax(3).XAxisLocation = 'top';
xlabel('Occlusion Rank [Least Occluded First]')
ylabel('Signal RMS Rank [Largest RMS First]')

xticks(ax(3), unique(rank_x));
yticks(ax(3), unique(rank_y));

ax(3).XLim = [1 max(xticks)];
ax(3).YLim = [1 max(yticks)];

xtl = xticklabels;
for i = 2:length(xtl);
    if ~endsWith(xtl{i}, {'0' '5'});
        xtl{i} = '';

    end
end
ax(3).XTickLabel = xtl;

ytl = yticklabels;
for i = 2:length(ytl);
    if ~endsWith(ytl{i}, {'0' '5'});
        ytl{i} = '';

    end
end
ax(3).YTickLabel = ytl;

box on
grid on
longticks([], 2);
latimes2(gcf)
ax(3).XAxis.TickLabelRotation = 0;
ax(3).DataAspectRatio = [1 1 1];
ax(3).GridColor = 'k';
ax(3).GridAlpha = .25;
axesfs(gcf, 10, 10);

%% ___________________________________________________________________________ %%
%% Plot raw sound pressure level vs distance
%% ___________________________________________________________________________ %%

if ~isequal(dist_sta, p_sta)
    error('')

end

Lp_val = spl(p_val, 1);
Lp_sta = p_sta;

[ax(4), F(4)] = plotxy(deg2km(dist_val), Lp_val, dist_sta)

% Shift KSTNM labels up slightly.
kstnm_tx = findobj(ax(4).Children, 'type', 'text');
for i = 1:length(kstnm_tx)
    kstnm_tx(i).Position(2) = kstnm_tx(i).Position(2) * 1.005;

end

% Add SPL propto 1/sqrt(r) (cylindrical spreading) lines for P0045 reference station.
spldist_r1_sta = 'P0045';
spldist_r1_dist_deg = dist_val(cellstrfind(dist_sta, spldist_r1_sta));
spldist_r1_dist_m = 1e3 * deg2km(spldist_r1_dist_deg);
spldist_r1_p = rms_val(cellstrfind(rms_sta, spldist_r1_sta));
spldist_r2_dist_m = [500e3:100e3:10000e3-100e3];

[Lp2_val, Lp1_val] = spldist(spldist_r2_dist_m, spldist_r1_p, 1, spldist_r1_dist_m, 2);
if Lp1_val ~= Lp_val(cellstrfind(Lp_sta, spldist_r1_sta));
    error('Sound-pressure level (at r_1) in `spl` and `spldist` do not match\n')

end
hold(ax(4), 'on')
pl_spldist2 = plot(ax(4), spldist_r2_dist_m/1e3, Lp2_val, 'k');
tx_spldist2 = text(ax(4), 5000, 112.5, '{\itp}\propto1/sqrt({\itr})');
tx_spldist2.Rotation = 351.5;

% Add SPL propto 1/r (spherical spreading) beginning at 500 km for P0045 reference.
[Lp3_val, Lp1_val] = spldist(spldist_r2_dist_m, spldist_r1_p, 1, spldist_r1_dist_m, 1);
pl_spldist3 = plot(ax(4), spldist_r2_dist_m/1e3, Lp3_val, 'Color', ColorGray);
tx_spldist3 = text(ax(4), 6000, 104.5, '{\itp}\propto1/{\itr}', 'Color', ColorGray);
tx_spldist3.Rotation = 345;

uistack([pl_spldist2 pl_spldist3], 'bottom')
hold(ax(4), 'off')

xlim(ax(4), [0 10000]);
ylim(ax(4), [90 130]);
xlabel('Epicentral Distance, {\itr} [km]')
ylabel('Sound Pressure Level, {\itL}_{\itp} [dB re 1 \muPa]')

box on
grid on
axesfs([], 12, 12)
longticks([], 2);
latimes2(gcf)
ax(4).FontSize = 14;

% Make attenuation-curve labels (ONLY) LaTeX for proper sqrt.
set(tx_spldist2, 'String',' \boldmath{$p \propto 1/\sqrt{r}$}', 'Interpreter', 'LaTeX', 'FontSize', 13);
set(tx_spldist3, 'String',' \boldmath{$p \propto 1/r$}', 'Interpreter', 'LaTeX', 'FontSize', 13);

for i = 1:length(F(4).rms_tx)
    if any(strcmp(F(4).rms_tx(i).String, {'H11S3' 'H11S1' 'H11N2' 'H11N3' 'H03S3' 'H03S2'}))
        F(4).rms_tx(i).String = '';
        continue

    end
    if strcmp(F(4).rms_tx(i).String, 'H11S2')
        F(4).rms_tx(i).String = 'H11S1-H11S3';
        %F(4).rms_tx(i).String = ['H11S1'  char(8211) 'H11S3']

    end
    if strcmp(F(4).rms_tx(i).String, 'H11N1')
        F(4).rms_tx(i).String = 'H11N1-H11N3';
        %F(4).rms_tx(i).String = ['H11N1'  char(8211) 'H11N3']

    end
    if strcmp(F(4).rms_tx(i).String, 'H03S1')
        F(4).rms_tx(i).String = 'H03S1-H03S3';
        %F(4).rms_tx(i).String = ['H03S1'  char(8211) 'H03S3']

    end
end

% Manually adjusted labels, got positions, saved in mat (two comment lines below)
%pos = gettxpos(F(4).rms_tx);
%save('static/fig7_pos.mat', 'pos');
load('static/fig7_pos.mat', 'pos');
for i = 1:length(F(4).rms_tx)
    F(4).rms_tx(i).Position = pos(i,:);

end
keyboard

% %% ___________________________________________________________________________ %%
% % Plot corrected sound pressure level vs azimuth

% %az_val =
% az_sta = Lp_sta;

% ax(4) = plotxy(deg2km(dist_val), Lp_val, dist_sta)
% xlabel('Distance [km]')
% ylabel('{\itL}_{\itp} (re 1 \muPa)')
% box on
% grid on
% longticks([], 2);
% latimes2


%% END MAIN



%% ___________________________________________________________________________ %%
%% Subfuncs
%% ___________________________________________________________________________ %%

function [sta, val] = order_sta_val(ref_sta, sta, val)

[~, idx] = ismember(ref_sta, sta);
idx(find(~idx)) = [];
sta = sta(idx);
val = val(idx);

%% ___________________________________________________________________________ %%

function [ax, F] = plotxy(x, y, kstnm, pos1)

% pos1 = first index that you want labels shifted to right; 0 for occluion
% and 1 for rank.
defval('pos1', NaN)

sigtype = catsac;

figure
ax =  gca;
hold(ax, 'on')
for i = 1:length(kstnm)
    if strcmp(sigtype.(kstnm{i}), 'A')
        Color = [0 0 1];

    elseif strcmp(sigtype.(kstnm{i}), 'B')
        Color = [0 0 0];

    elseif strcmp(sigtype.(kstnm{i}), 'C')
        Color = ColorGray;

    else
        error('unexpected signal type')

    end

    if ~startsWith(kstnm{i}, 'H')
        F.rms_pl(i) = plot(x(i), y(i), 'v', 'MarkerFaceColor', Color, 'MarkerEdgeColor', ...
                       'black', 'MarkerSize', 10);

    else
        F.rms_pl(i) = plot(x(i), y(i), 'd', 'MarkerFaceColor', Color, 'MarkerEdgeColor', ...
                       'black', 'MarkerSize', 10);
    end

    F.rms_tx(i) = text(x(i), y(i)+0.04*range(y), kstnm{i}, 'HorizontalAlignment', 'Center', ...
                   'Color', 'black');

    if x(i) == pos1
        F.rms_tx(i).Position(1) = F.rms_tx(i).Position(1)+0.06*range(x);

    end
end
hold(ax, 'off')

%% ___________________________________________________________________________ %%

function d_prime = norm_mode_amp(kstnm)

mtype = 1;
freq = 2.5;
for i = 1:length(kstnm)
    %figure
    [~, ~, ~, stamp(i), maxdepth(i)] = hunga_read_modes(kstnm{i}, mtype, freq, false);
    [vp_depth, vp] = hunga_read_ctdprofiles(kstnm{i}, mtype);
    vp_idx = nearestidx(vp_depth, maxdepth(i));
    vp_at_mode_max(i) = vp(vp_idx);

    %title(sprintf('%s %.3f', kstnm{i}, stamp(i)))
    %savepdf(kstnm{i})
    %close all

end

% Normalize by amplitude eigenfunction at station depth.
d_prime = [stamp / max(stamp)]';

fprintf('Average depth of mode maximum = %i m\n', round(mean(maxdepth)))
fprintf('Average Vp at mode maximum = %.1f km/s\n', mean(vp_at_mode_max))
% Get velocity at max mode depth.



%% ___________________________________________________________________________ %%

function [occ_rank, rms_rank, sta_rank] = rankit(occ_val, rms_val, occ_sta, rms_sta)

% Ensure station lists are ordered identically.
if ~isequaln(occ_sta, rms_sta);
    error('Stations lists not ordered identically');

end

% Make one master reference station list and delete redudant occlusion, rms
% station lists.
sta = occ_sta;

% Let's first sort all stations by rms, so that in the zero-occlusion case
% the higher RMS stations appear first (P0045 ahead of H03).
A = [occ_val rms_val];
[B, rms_idx] = sortrows(A, 2, 'descend');  % sort by second column, rms, most to least
sta = sta(rms_idx);

% Now resort matrix by occlusion.
[C, occ_idx] = sortrows(B, 1, 'ascend'); % sort by first column, occlusion, least to most
sta_rank = sta(occ_idx);

% Matrix C is now sorted in ascending order of occlusion.
% C = [least_occ_count  least_occ_rms;
%                     ...            ;
%        most_occ_count  most_occ_rms]
%
% And stations are similarly ordered.

% Now the row index of of C is simply the occlusion rank.
% (use `rankdata` just for consistency')
%occ_rank = 1:size(C, 1);
occ_rank = rankdata(C(:,1), 'ascend');

% Now we want rms rank, in descending order.
rms_rank = rankdata(C(:,2), 'descend');

% Let's replace all instances of 0 occlusion with rank 1.
zero_occ_idx = find(C(:,1) == 0);
occ_rank(zero_occ_idx) = 1;

occ_rank_idx = 1:length(occ_rank);
nonzero_occ_rank_idx = setdiff(occ_rank_idx, zero_occ_idx);

% And subtract that number of 0-occlusion values from the occlusion rank list
% (so that if goes from e.g., 1 to 2 and not 1 to 11).
num_zero = length(zero_occ_idx);
occ_rank(num_zero+1:end) = occ_rank(num_zero+1:end) - num_zero + 1;

%% ___________________________________________________________________________ %%

function [r2_p1_p2] = linreg_local(x, y)
% Local version of `linreg` that groups first two output, r2, p, into single
% output assuming ONLY order polynomial 1.

[r2, p] = linreg(x, y, 1);
r2_p1_p2 = [r2 p(1) p(2)];

%% ___________________________________________________________________________ %%

function [mu, ci] = pdboot(x)
% Generate normal distributoin object.
pd = fitdist(x, 'normal');
mu = pd.mu;

% Get 99% confidence intervals on mu, sigma (first, second columns).
% Only interested in confidence interval on mu, so ditch second column.
ci = pd.paramci('Alpha', 0.01);
ci = ci(:,1);

% The +- confidence interval then is the half range/
ci = 0.5*range(ci);
