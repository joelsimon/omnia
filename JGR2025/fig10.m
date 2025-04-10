function fig10
% FIG10
%
% Figure 10: Correlation matrix
%
% Developed as: hunga_plot_timewindow_xdist_peak2peak.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 10-Mar-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

clc
close all

tz = -1350;
algo = 1;
crat = 1.0;
prev = false;
los = false;

% All false for fig10
skip_ims = false;
skip_H11 = false;
skip_48 = false;
skip_21_22 = false;
skip_04 = false;
skip_16 = false;
skip_28 = false;
add_26 = false;

hundir = getenv('HUNGA');
sacdir = fullfile(hundir, 'sac');
imsdir = fullfile(sacdir, 'ims');
staticdir = fullfile(hundir, 'code', 'static');

sac = globglob(sacdir, '*.sac');
imssac = globglob(imsdir, '*sac.pa');
sac = [sac ; imssac];

sac = rmbadsac(sac);
sac = rmgapsac(sac);
sac = keepsigsac(sac);
%sac = keeppeakysac(sac); % comment for fig10
%sac = keepH11S1H03S1sac(sac); % comment for fig10

if skip_ims
    sac(cellstrfind(strippath(sac), {'H11' 'H03'})) = [];

end

if skip_H11
    sac(cellstrfind(strippath(sac), 'H11')) = [];

end

if skip_48
    sac(cellstrfind(strippath(sac), '\.0048_')) = [];

end

if skip_21_22
    sac(cellstrfind(strippath(sac), {'\.21_' '\.22_'})) = [];

end

if skip_04
    sac(cellstrfind(strippath(sac), '\.04_')) = [];

end

if skip_16
    sac(cellstrfind(strippath(sac), '\.16_')) = [];

end

if skip_28
    sac(cellstrfind(strippath(sac), '28_')) = [];

end

if add_26
    sac26 = globglob(sacdir, '*.0026_*.sac');
    sac = [sac ; sac26];
end

% Note: hunga_write_timewindow_xdist_peak2peak renamed to fig6.m during code upload.
% So filename may be 'fig6--5min_post-25min....txt' 
txtfile = fullfile(staticdir, 'hunga_write_timewindow_xdist_peak2peak_pre--5min_post-25min_envlen-30s_envtype-rms_maxlags-2mins-2.5-10.0Hz.txt')
length(sac)

plot_adjacency_matrix(sac, txtfile, tz, algo, crat, prev, los)

%% ___________________________________________________________________________ %%

function plot_adjacency_matrix(sac, txtfile, tz, algo, crat, prev, los)

[mc, lags, seglen, kstnm, orderval] = ...
    corrmat(sac, txtfile, tz, algo, crat, prev, los);

mc = triu(mc);
mc(mc<=0) = NaN;

lags = triu(lags);
lags = abs(lags);

% % Remove diagonal (autocorrelations);
% mc = mc + diag(NaN - diag(mc));
% lags = lags + diag(NaN - diag(lags));

%% CORRELATIONS
%caxc = minmaxmat(mc);
%caxc = [.4 1.00]
caxc = [maxmat(mc, 'min') 1];
%mc(mc<caxc(1)) = NaN;

%% LAGS
%caxl = [0 60];
caxl = minmaxmat(lags);
%lags(mc<caxc(1)) = NaN;

% Ensure each other's NaNs match.
lags(isnan(mc)) = NaN;
mc(isnan(lags)) = NaN;

[a, b, c] = maxmat(mc, 'max');
fprintf('Max. Corr.:  %.2f (%s, %s; %.2f lag)\n', a, kstnm{b(1)}, kstnm{c(1)}, ...
        lags(b(1), c(1)));

[a, b, c] = maxmat(mc, 'min');
fprintf('Min. Corr.:  %.2f (%s, %s; %.2f lag)\n', a, kstnm{b(1)}, kstnm{c(1)}, ...
        lags(b(1), c(1)));

[a, b, c] = maxmat(lags, 'min');
fprintf('Min. Lags.:  %.2f (%s, %s; %.2f corr)\n', a, kstnm{b(1)}, kstnm{c(1)}, ....
        mc(b(1), c(1)));
[a, b, c] = maxmat(lags, 'max');
fprintf('Max. Lags.:  %.2f (%s, %s; %.2f corr)\n', a, kstnm{b(1)}, kstnm{c(1)}, ....
        mc(b(1), c(1)));

[imc, axc, cbc] = plot_matrix(mc, kstnm, orderval, caxc);
cbc.FontSize = axc.FontSize;

set(cbc.Label, 'String', 'Normalized Cross Correlation', 'Interpreter', 'Tex');
axc.DataAspectRatio = [1 1 1];
cbc.Position = [0.22 0.11 0.035 0.55];
latimes2
warning('you may need to manually moveh(cbc, -0.01) etc')
savepdf(sprintf('%s_corr', mfilename));

figure
[iml, axl, cbl] = plot_matrix(lags, kstnm, orderval, caxl);
set(cbl.Label, 'String', 'Absolute Time Shift [s]', 'Interpreter', 'Tex');
cbl.FontSize = axl.FontSize;
axl.DataAspectRatio = [1 1 1];
latimes2
colormap(flip(colormap))
warning('you may need to manually moveh(cbc, -0.01) etc')
%keyboard
cbl.Position = [0.22 0.11 0.035 0.55];
savepdf(sprintf('%s_lags', mfilename))

%% ___________________________________________________________________________ %%

function [mc, lg, sl, kstnm, val] = ...
    corrmat(sac, txtfile, tz, algo, crat, prev, los)

%% JOEL -- manually flip here if you want to sort based on, e.g., gcarc)
kstnm = sackstnm(sac);
%[kstnm, val] = orderkstnm_geo(kstnm, 'azimuth', 'H11S3'); %% OPT: orderksnm
[kstnm, val, idx] = orderkstnm_occl(kstnm, tz, algo, crat, prev, los);
%% JOEL -- manually flip here if you want to sort based on, e.g., gcarc)

fmt = '%11s  |  %.4f  |  %7.2f  |  %7.2f\n';
fid = fopen(txtfile, 'r');
c = textscan(fid, fmt);
fclose(fid);

combo = c{1};
maxcorr = c{2};
lags = c{3};
seglen = c{4};

ln = length(kstnm);
mc = NaN(ln, ln);
lg = NaN(ln, ln);
sl = NaN(ln, ln);

for i = 1:ln
    for j = 1:ln
        if i == j;
            mc(i, j) = 1;
            lg(i, j) = 0;
            continue

        end

        seek = sprintf('%s-%s', kstnm{i}, kstnm{j});
        idx = cellstrfind(combo, seek);
        if idx
            mc(i, j) = maxcorr(idx);
            lg(i, j) = lags(idx);
            sl(i, j) = seglen(idx);
            continue

        end

        seek = sprintf('%s-%s', kstnm{j}, kstnm{i});
        idx = cellstrfind(combo, seek);
        if idx
            mc(i, j) = maxcorr(idx);
            lg(i, j) = -lags(idx); % lags opposite sign?
            sl(i, j) = seglen(idx);
            continue

        end
        warning('Combo %s-%s/%s-%s not found', kstnm{i}, kstnm{j}, kstnm{j}, kstnm{i})
        keyboard
        error()

    end
end

%% ___________________________________________________________________________ %%
function [im, ax, cb] = plot_matrix(imageval, kstnm, orderval, cax)

im = imagesc(abs(imageval), 'AlphaData', ~isnan(imageval));
ax = gca;
cmap = spring;
colormap(cmap(1:240,:));
cb = colorbar;
cb.TickDirection = 'out';
caxis(cax)
cb.Limits = cax;

xticks([1:length(kstnm)]);
yticks([1:length(kstnm)]);

for i = 1:length(kstnm)
    xlab{i} = sprintf('%.1f', log10(orderval(i)+1));
    %ylab{i} = sprintf('%s (%3.1f)', kstnm{i}, log10(orderval(i)+1));
    %xlab{i} = sprintf('%s', kstnm{i}(end-1:end));
    %xlab{i} = sprintf('%.1f', orderval(i)); % %% OPT: orderksnm

end
xticklabels(xlab');

ax.XAxisLocation = 'top';
ax.XAxis.TickLabelRotation = -90;

ax.XAxis.TickLength = [0 0];
ax.YAxis.TickLength = [0 0];

ylab = kstnm;
addhalfgrid(im, ylab')

%% ___________________________________________________________________________ %%
function addhalfgrid(im, ylab)

lx = length(im.CData);
for i = 1:lx
    line([i-0.5 lx+0.5], [i+0.5 i+0.5], 'Color', 'black'); % hor
    text(i-0.75, i+0.25, ylab{i}, 'HorizontalAlignment', 'Right', ...
         'VerticalAlignment', 'Middle');
end

for i=0:lx
    line([i+0.5 i+0.5], [0 i+1.5], 'Color', 'black'); % vert

end

ax = gca;
ax.Box = 'off';
ax.YAxisLocation = 'right';
yticklabels([]);

%% ___________________________________________________________________________ %%
function sac = keepH11S1H03S1sac(sac)

kstnm = sackstnm(sac);

ditch = {'H11S2'...
         'H11S3'...
         'H11N1'...
         'H11N2'...
         'H11N3'...
         'H03S1'...
         'H03S2'...
         'H03S3'...
         'H03N1'...
         'H03N2'...
         'H03N3'};

sac(cellstrfind(kstnm, ditch)) = [];
