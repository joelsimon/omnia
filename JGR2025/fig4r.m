function fig4r(label)
% FIG4R(label)
%
% Figure 4 (right column): Envelope correlations.
%
% It also, importantly, writes corr.txt which is used in the correlation
% matrix of Figure 6.
%
% Input:
% label     [a-e] to generate HTHH figures from Simon et al., JRG
%               (def: [], to generate all figs and corr text file)
%
% Write and plot correlation after aligning on second (or third) peak.
%
% NB: Run on full data set to write full textfile for, e.g., correlation
% matrix.  Additionally may run on SAC pair (see internally) to adjust colors
% for Figure 5, but will want to revert overwritten and truncated data file.
%
% Developed as: hunga_write_timewindow_xdist_peak2peak.m then fig4r.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 15-Aug-2025, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

defval('label', [])

travtimeadj = false;

clc
close all

%% Paths
hundir = getenv('HUNGA');
sacdir = fullfile(hundir, 'sac');
imsdir = fullfile(sacdir, 'ims');
imssac = globglob(imsdir, '*sac.pa');
staticdir = fullfile(hundir, 'code', 'static');

sac = globglob(sacdir, '*.sac');
imssac = ordersac_geo(imssac, 'gcarc');

sac = [sac ; imssac];

sac = rmbadsac(sac);
sac = rmgapsac(sac);
sac = keepsigsac(sac);

% Use these to generate Figure 4 (right column), but make sure to run on full
% data set first to save output .txt file, and also revert to full output .txt
% after running these individual pairs for figures.
if ~isempty(label)
    switch label
      case 'a'
        [~, sac] = cellstrfind(sac, {'45_' '53_'});

      case 'b'
        [~, sac] = cellstrfind(sac, {'45_' 'H03S1'});

      case 'c'
        [~, sac] = cellstrfind(sac, {'45_' 'H11S1'});

      case 'd'
        [~, sac] = cellstrfind(sac, {'45_' '26_'});

      case 'e'
        % P0049 -- have to add manually because `keepsigsac` deletes
        sac = fullfile(sacdir, {'20220115T034444.0045_62AAD314.MER.REQ.merged.sac',
                            '20220115T034444.0049_62AD8DA4.MER.REQ.merged.sac'});

      otherwise
        error('bad label')

    end
end

genplot = true;

lohi = [2.5 10];
env_len_secs = 30;
env_type = 'rms';

pre_mins = -5;
post_mins = 25;
min_corr_seg = 0;

% previously:
% "hunga_write_timewindow_xdist_peak2peak_pre--5min_post-25min_envlen-30s_envtype-rms_maxlags-2mins-2.5-10.0Hz.txt"
% despite there being no concept of "maxlags" here
fstr = sprintf('corr.txt');
fname = fullfile(staticdir, fstr)
fmt = '%5s-%5s  |  %7.4f  |  %7.2f  |  %7.2f\n';
writeaccess('unlock', fname, false)
fid = fopen(fname, 'w');

sacsac = nchoosek(sac, 2);
combos = size(sacsac, 1);
for i = 1:combos
    fprintf('\nComputing combo %i of %i...\n', i, combos)
    sac1 = sacsac{i, 1};
    sac2 = sacsac{i, 2};

    [h1, h2, maxcorr, tarr_diff_secs, seg_len_secs] ...
        = timewindow_xdist(sac1, sac2, lohi, env_len_secs, env_type, pre_mins, post_mins, min_corr_seg, genplot, travtimeadj);

    fprintf(fid, fmt, h1.KSTNM, h2.KSTNM, maxcorr, tarr_diff_secs, seg_len_secs);

end
fclose(fid);
writeaccess('lock', fname)
fprintf('Wrote: %s\n', fname)

%% ___________________________________________________________________________ %%

function [h1, h2, maxcorr, tarr_diff_secs, seg_len_secs] ...
    = timewindow_xdist(s1, s2, lohi, env_len_secs, env_type, pre_mins, post_mins, min_corr_seg, genplot, travtimeadj)

c = 1480;
ph = c2ph(c, 'm/s');
p2t_m = -1350; % m; P-T conversion depth for `dist2slope`

% Bandpass poles and passes -- must update here if changed in `hunga_transfer_bandpass`
popas = [4 1];

[xb1, h1] = readsac_filter(s1, lohi, popas);
[xb2, h2] = readsac_filter(s2, lohi, popas);

%xb1 = randn(size(xb1));
%xb2 = randn(size(xb2));

xe1 = envelope(xb1, (env_len_secs * efes(h1, true) + 1), env_type);
xe2 = envelope(xb2, (env_len_secs * efes(h2, true) + 1), env_type);

% Cut small local events -- set gap to average of envelope pre/post 1 min of gap.
cut_gap1 = readginput(s1);
cut_gap2 = readginput(s2);

xe1 = fillgap(xe1, cut_gap1, -12345, 0, efes(h1));
xe2 = fillgap(xe2, cut_gap2, -12345, 0, efes(h2));

% I figure it's okay to now downsample to lower, common frequency for
% correlation analysis because we've already computed the 30-s long envelope on
% the properly bandpassed trace above.
[xe1, h1] = decimatesac(xe1, h1, 10, false);
[xe2, h2] = decimatesac(xe2, h2, 10, false);

fs1 = efes(h1, true);
fs2 = efes(h2, true);

if fs1 == fs2
    fs = fs1;

else
    error('sampling frequencies differ')

end

if travtimeadj
    [xew1, W1, tt1] = ...
        hunga_timewindow2_travtimeadj(xe1, h1, pre_mins, post_mins, h1.KSTNM, c, p2t_m);
    [xew2, W2, tt2] = ...
        hunga_timewindow2_travtimeadj(xe2, h2, pre_mins, post_mins, h2.KSTNM, c, p2t_m);
else
    [xew1, W1, tt1] = ...
        hunga_timewindow2(xe1, h1, pre_mins, post_mins, ph);
    [xew2, W2, tt2] = ...
        hunga_timewindow2(xe2, h2, pre_mins, post_mins, ph);

end

xew1_mean = mean(xew1);
xew1_dmean = xew1 - xew1_mean;

xew2_mean = mean(xew2);
xew2_dmean = xew2 - xew2_mean;

tarr_samp = abs(pre_mins) * 60 * efes(h1); % efes(h1) == efes(h2)
if strcmp(h1.KSTNM, 'P0028')
    peak_samp1 = third_peak_samp(xew1, tarr_samp, efes(h1), travtimeadj);

else
    peak_samp1 = second_peak_samp(xew1, tarr_samp, efes(h1), travtimeadj);

end

if strcmp(h2.KSTNM, 'P0028')
    peak_samp2 = third_peak_samp(xew2, tarr_samp, efes(h2), travtimeadj);

else
    peak_samp2 = second_peak_samp(xew2, tarr_samp, efes(h2), travtimeadj);


end
samp_lags = peak_samp1 - peak_samp2;

% Do the correlation.
[c, lags] = xdist(xew1_dmean, xew2_dmean, samp_lags);

% `lag_samp` are number of samples to remove to align
% (alignment starts at lag_samp + 1)
[~, maxcorr_idx] = max(c); % No reason to expect anti-correlation; don't use max(abs(x))
maxcorr = c(maxcorr_idx);
lag_samp = lags(maxcorr_idx);

xew1_dmean_xat = xew1_dmean;
xew2_dmean_xat = xew2_dmean;

tarr1_samp = tt1.arsamp - (W1.xlsamp-1);
tarr2_samp = tt2.arsamp - (W2.xlsamp-1);

if lag_samp < 0
    % Cut samples from start of x2 (delay the second signal)
    xew1_dmean_xat(end-abs(lag_samp)+1:end) = [];

    xew2_dmean_xat = xew2_dmean_xat(abs(lag_samp)+1:end);
    tarr2_samp = tarr2_samp - abs(lag_samp);

elseif lag_samp > 0
    % Cut samples from start of x1 (delay the first signal)
    xew2_dmean_xat(end-lag_samp+1:end) = [];

    xew1_dmean_xat = xew1_dmean_xat(lag_samp+1:end);
    tarr1_samp = tarr1_samp - lag_samp;

end

% Sanity: ensure proper alignment and truncation
%(recompute xcorr in area of overlap)
if xdist(xew1_dmean_xat, xew2_dmean_xat, 0) ~= maxcorr
    error('Alignment/truncation issue')

end

tarr1_secs = (tarr1_samp - 1)  / fs;
tarr1_mins = tarr1_secs / 60;

tarr2_secs = (tarr2_samp - 1)  / fs;
tarr2_mins = tarr2_secs / 60;

tarr_diff_secs = tarr1_secs - tarr2_secs;
seg_len_secs = (length(xew1_dmean_xat) - 1) * h1.DELTA;

if genplot
    [F, ax] = plotit(xew1_dmean_xat, xew1_mean, xew2_dmean_xat, xew2_mean, h1, ...
                     h2, tarr1_mins, tarr2_mins, tarr_diff_secs, env_type, env_len_secs, maxcorr);

    plotit(xew2_dmean_xat, xew2_mean, xew1_dmean_xat, xew1_mean, h2, ...
           h1, tarr2_mins, tarr1_mins, tarr_diff_secs, env_type, env_len_secs, maxcorr);

end

% Check if the aligned and truncated correlated segment is shorter than the
% required length to consider it aligned on the T wave (~20 mins).  Do this
% after plotting because we want the label on the output.
if ((length(xew1_dmean_xat)-1) * h1.DELTA) / 60 < min_corr_seg
    maxcorr = NaN;

end

figure
plot(lags/fs, c)
hold on
plot(lag_samp/fs, maxcorr, 'ro')
plot([lag_samp/fs lag_samp/fs], get(gca, 'YLim'), 'k--')
xlabel('time (s)')
ylabel('correlation')
savepdf(sprintf('%s_%s_lags', h1.KSTNM, h2.KSTNM));
close all


%% ___________________________________________________________________________ %%
function [xb, h] = readsac_filter(s, lohi, popas)

if startsWith(strippath(s), 'H11') || startsWith(strippath(s), 'H03')
    [foo, h] = readsac(s);
    xb = bandpass(foo, efes(h), lohi(1), lohi(2), popas(1), popas(2));

else
    [xb, h] = hunga_transfer_bandpass(s, lohi, popas);

end

%% ___________________________________________________________________________ %%
function peak_samp = second_peak_samp(xew, tarr_samp, fs, travtimeadj)

% For all stations OTHER THAN P0028 -- identifies "second" peak
if travtimeadj
    second_peak_window = [tarr_samp:tarr_samp+5*60*fs];

else
    second_peak_window = [tarr_samp-0.5*30*fs:tarr_samp+4.5*60*fs];

end
[~, window_peak_idx] = max(xew(second_peak_window));
peak_samp = second_peak_window(1) + window_peak_idx;

%% ___________________________________________________________________________ %%
function peak_samp = third_peak_samp(xew, tarr_samp, fs, travtimeadj)
% For P0028 ONLY -- identifies "third" peak

if travtimeadj
    third_peak_window = [tarr_samp+1.5*60*fs:tarr_samp+5*60*fs];

else
    third_peak_window = [tarr_samp+0.5*60*fs:tarr_samp+5.5*60*fs];

end
[~, window_peak_idx] = max(xew(third_peak_window));
peak_samp = third_peak_window(1) + window_peak_idx;

%% ___________________________________________________________________________ %%
function [F, ax] = plotit(x1, x1_mean, x2, x2_mean, h1, h2, tarr1_mins, ...
                          tarr2_mins, tarr_diff_secs, env_type, env_len_secs, ...
                          maxcorr)

[~, col1] = kstnmcat(h1.KSTNM);
[~, col2] = kstnmcat(h2.KSTNM);

% Colors for examples in paper.
if strcmp(h1.KSTNM, 'P0053')
    col1 = [0 0.33 1];

end
if strcmp(h1.KSTNM, 'H03S1')
    col1 = [0 0.67 1];

end
if strcmp(h1.KSTNM, 'H11S1')
    col1 = [0 1 1];

end

if strcmp(h2.KSTNM, 'P0053')
    col2 = [0 0.33 1];

end
if strcmp(h2.KSTNM, 'H03S1')
    col2 = [0 0.67 1];

end
if strcmp(h2.KSTNM, 'H11S1')
    col2 = [0 1 1];

end

normx1 = norm2ab(x1, 0, 1);
normx2 = norm2ab(x2, 0, 1);

figure
ax = gca;
box(ax, 'on')
hold(ax, 'on')
shrink(ax, 1, 2);
xax_mins = xaxis(length(x2), h2.DELTA, 0) / 60;
xax_mins = xax_mins - tarr2_mins;
F.pl1 = plot(ax, xax_mins, +normx1, 'Color', col1, 'LineStyle', '-', 'LineWidth', 2);
F.pl2 = plot(ax, xax_mins, -normx2, 'Color', col2, 'LineStyle', '-', 'LineWidth', 2);
ax.YLim = [-1.1 1.1];
xlabel(ax, 'Time [min]')
%xlabel(ax, sprintf('Minutes Relative To Per-Station Predicted \textit{T}-Wave Arrival Time [reference %s]', h1.KSTNM))
ylabel(ax, 'Normalized Envelope Amplitude')
ax.YTick = [];

F.lg = legend(ax, h1.KSTNM, h2.KSTNM, 'Location', 'SouthEast');

h1_offset_sec = (tarr1_mins - tarr2_mins) * 60;
F.tx_corr = textpatch(ax, 'NorthEast', sprintf('    Offset: %+.1f s\nCorrelation: %.2f', h1_offset_sec, maxcorr), ...
                      [], [], false, 'FontName', 'Times', 'FontSize', 12);
F.tx_corr.Box = 'off';
moveh(F.tx_corr, .035);

xlim(ax, [xax_mins(1) xax_mins(end)])
F.lg.AutoUpdate = 'off';
plot(ax, [tarr1_mins tarr1_mins]-tarr2_mins, [0 max(ax.YLim)], '-', 'Color', col1)
plot(ax, [tarr2_mins tarr2_mins]-tarr2_mins, [0 min(ax.YLim)], '-', 'Color', col2)
plot(ax, ax.XLim, [0 0], '-','Color', [0.6 0.6 0.6])

% tx = text(ax, 5, 0.1*ax.YLim(2), ....
%      sprintf('%s Shifted %+.1f s To Align With %s', h1.KSTNM, h1_offset_sec, h2.KSTNM), ...
%      'FontSize', 15, 'HorizontalAlignment', 'Left')
hold(ax, 'off')
ax.XAxis.MinorTick = 'on';
latimes2
longticks(ax, 2)
axesfs(gcf, 12, 12)

% For paper, to correlation txt visible in lower right
if strcmp(h1.KSTNM, 'P0049');
    movev(F.tx_corr, -0.115)

end

savepdf(sprintf('%s_%s', h1.KSTNM, h2.KSTNM));
close all
