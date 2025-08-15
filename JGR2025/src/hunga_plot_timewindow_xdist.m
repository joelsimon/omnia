function hunga_plot_timewindow_xdist
% HUNGA_PLOT_TIMEWINDOW_XDIST
%
% Plot the correlation matrix using textifle output by hunga_write_timewindow_xdist.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 14-Oct-2024, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

clc
close all

midx = -1385;
tz = midx;
algo = 1;
crat = 1.0;
prev = false;
los = false;

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
%sac = keeppeakysac(sac);
%sac = keepH11S1H03S1sac(sac);

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

txtfile = fullfile(staticdir, 'hunga_write_timewindow_xdist_pre--5min_post-25min_envlen-30s_envtype-rms_maxlags-2mins-2.5-10.0Hz.txt')
length(sac)

plot_adjacency_matrix(sac, txtfile, tz, algo, crat, prev, los)


%% ___________________________________________________________________________ %%

function plot_adjacency_matrix(sac, txtfile, tz, algo, crat, prev, los)

[mc, lags, seglen, kstnm, orderval] = ...
    corrmat(sac, txtfile, tz, algo, crat, prev, los);

mc = triu(mc);
mc(mc<=0) = NaN;

lags = abs(lags);
lags = triu(lags);

% Remove diagonal (autocorrelations);
mc = mc + diag(NaN - diag(mc));
lags = lags + diag(NaN - diag(lags));

%% CORRELATIONS
caxc = minmaxmat(mc);

%% LAGS
caxl = [0 60];
%caxl = minmaxmat(lags);

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

[imc, axc, cbc] = plot_corr(mc, kstnm, orderval, caxc);
cbc.FontSize = axc.FontSize;

set(cbc.Label, 'String', 'Correlation', 'Interpreter', 'Tex');
axc.DataAspectRatio = [1 1 1];
latimes2
warning('you may need to manually moveh(cbc, -0.01) etc')
%keyboard
savepdf(sprintf('%s_corr', mfilename));

figure
[iml, axl, cbl] = plot_lags(lags, kstnm, orderval, caxl);
set(cbl.Label, 'String', 'Lag (s)', 'Interpreter', 'LaTex');
cbl.FontSize = axl.FontSize;
axl.DataAspectRatio = [1 1 1];
latimes2
colormap(flip(colormap))
warning('you may need to manually moveh(cbc, -0.01) etc')
%keyboard
savepdf(sprintf('%s_lags', mfilename))
close all

%% ___________________________________________________________________________ %%

function [mc, lg, sl, kstnm, val, str] = ...
    corrmat(sac, txtfile, tz, algo, crat, prev, los)

%% JOEL -- manually flip here if you want to sort based on, e.g., gcarc)
kstnm = sackstnm(sac);
%[kstnm, val] = orderkstnm_geo(kstnm, 'azimuth', 'N0002');
[kstnm, val, idx] = orderkstnm_occl(kstnm, tz, algo, crat, prev, los)
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

        % Reverse lags here -- given in "KSTNM{1} shifted X.XX s to align with KSTNM{2}
        % in textfile"
        seek = sprintf('%s-%s', kstnm{j}, kstnm{i});
        idx = cellstrfind(combo, seek);
        if idx
            mc(i, j) = maxcorr(idx);
            lg(i, j) = -lags(idx); % lags opposite sign
            sl(i, j) = seglen(idx);
            continue

        end
        warning('Combo %s-%s/%s-%s not found', kstnm{i}, kstnm{j}, kstnm{j}, kstnm{i})
        keyboard
        error()

    end
    warning('Combo %s-%s/%s-%s not found', kstnm{i}, kstnm{j}, kstnm{j}, kstnm{i})

end

%% ___________________________________________________________________________ %%

function [im, ax, cb] = plot_corr(imageval, kstnm, orderval, cax)

im = imagesc(imageval, 'AlphaData', ~isnan(imageval));
ax = gca;
cmap = bone;
colormap(cmap);
%colormap(spring(10))
%colormap(gray)
%colormap(bone(6))
%colormap(gray(8))
%colormap(cmap(10:100,:));
cb = colorbar;
cb.TickDirection = 'out';
caxis(cax)
cb.Limits = cax;

xticks([1:length(kstnm)]);
yticks([1:length(kstnm)]);

for i = 1:length(kstnm)
    lab{i} = sprintf('%s (%.2f)', kstnm{i}, log10(orderval(i)+1));

end

xticklabels(lab');
ax.XAxisLocation = 'top';
ax.XAxis.TickLabelRotation = 45;

ax.XAxis.TickLength = [0 0];
ax.YAxis.TickLength = [0 0];

%addgrid(im, lab)
addhalfgrid(im, lab)

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

%% ___________________________________________________________________________ %%

function [im, ax, cb] = plot_lags(imageval, kstnm, orderval, cax)

im = imagesc(abs(imageval), 'AlphaData', ~isnan(imageval));
ax = gca;

cmap = bone;
colormap(cmap)
%caxis([-120 120]);
cb = colorbar;
cb.TickDirection = 'out';
caxis(cax)
%cb.Limits = cax;

xticks([1:length(kstnm)]);
yticks([1:length(kstnm)]);

for i = 1:length(kstnm)
    lab{i} = sprintf('%s (%.2f)', kstnm{i}, log10(orderval(i)+1));

end

xticklabels(lab');
ax.XAxisLocation = 'top';
ax.XAxis.TickLabelRotation = 45;

ax.XAxis.TickLength = [0 0];
ax.YAxis.TickLength = [0 0];

%addgrid(im, lab)
addhalfgrid(im, lab)

%% ___________________________________________________________________________ %%

function addgrid(im, lab)

lx = length(im.CData)-1;
for i = 1:lx;
    line([0 lx+1.5], [i+0.5 i+0.5], 'Color', 'k');
    line([i+0.5 i+0.5], [0 lx+1.5], 'Color', 'k');

end
yticklabels(lab');

%% ___________________________________________________________________________ %%

function addhalfgrid(im, lab)

lx = length(im.CData);
for i = 1:lx
    line([i-0.5 lx+0.5], [i+0.5 i+0.5], 'Color', 'black'); % hor
    text(i-0.75, i+0.25, lab{i}, 'HorizontalAlignment', 'Right', ...
         'VerticalAlignment', 'Middle');
end

for i=0:lx
    line([i+0.5 i+0.5], [0 i+1.5], 'Color', 'black'); % vert

end

ax = gca;
ax.Box = 'off';
ax.YAxisLocation = 'right';
yticklabels([]);
