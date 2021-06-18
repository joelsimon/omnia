function fig6_fig7
% FIG6_FIG7
%
% Plots distance and magnitude histograms, plus SNR as a function to magntidue
% and distance scatter plot; AND raypaths for ALL identified events; no
% winnowing.
%
% Developed as: $SIMON2020_CODE/simon2020_distmagsnr_rays
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 15-Mar-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

% Define paths.
merdir = getenv('MERMAID');
procdir = fullfile(merdir, 'processed');
evtdir = fullfile(merdir, 'events');
nearbydir = fullfile(evtdir, 'nearbystations');

% Ensure in GJI21 git branch.
startdir = pwd;
cd(procdir)
system('git checkout GJI21');
cd(evtdir)
system('git checkout GJI21');
cd(startdir)

% Parameters.
wlen = 30;
lohi = [1 5];
wlen2 = [1.75];

%%______________________________________________________________________________________%%
%% Data preprocessing: cull relevant files and parse only for DET through 2019 --
%% NO WINNOWING HERE; this is the complete, identified dataset.
% Filenames.
datadir = fullfile(getenv('GJI21_CODE'), 'data');
mer_det_txt1 = fullfile(datadir, 'mer.firstarr.all.txt');
mer_det_txt2 = fullfile(datadir, 'mer.firstarrpress.all.txt');

%% This is for the "preferred" event values (Mw magnitude, etc.)
filename1 = fullfile(evtdir, 'reviewed', 'identified', 'txt', 'identified.txt');
endtime = datetime('31-Dec-2019 23:59:59.999', 'TimeZone', 'UTC');
[s1, ~, eqlat, eqlon, ~, eqdepth, eqdist, eqmag, ~, eqid] = readidentified(filename1, [], endtime, 'SAC', 'DET');

% Remove any 'prelim.sac' files.
rm_idx = cellstrfind(s1, 'prelim.sac');
s1(rm_idx) = [];
eqlat(rm_idx) = [];
eqlon(rm_idx) = [];
eqdepth(rm_idx) = [];
eqdist(rm_idx) = [];
eqmag(rm_idx) = [];
eqid(rm_idx) = [];

%% This is for the SNR of the event
[s2, ~, ~, ~, ~, ~, ~, ~, ~, SNR] = readfirstarrival(mer_det_txt1);

% Save only the data corresponding to DET SAC files sent through the end of 2019.
[~, idx] = intersect(s2, s1);
SNR = SNR(idx);

%% This is for the event/MERMAID latitude and lonitude at the time of the event.
[s3, ~, ~, ~, ~, ~, ~, ~, merlat, merlon, evtlat, evtlon] = readfirstarrivalpressure(mer_det_txt2);

% Save only the data corresponding to DET SAC files sent through the end of 2019.
[~, idx] = intersect(s3, s1);
merlat = merlat(idx);
merlon = merlon(idx);
evtlat = evtlat(idx);
evtlon = evtlon(idx);

%%______________________________________________________________________________________%%

fs = 32;
lbfs = 47;

%% Distance and magnitude histograms; SNR as s function of magnitude and distance scatter plot.

% Distance.
h = histogram(eqdist, 'BinLimits', [0 180]);
ha = gca;
h.FaceColor = 'k';
xlim([0 180])
xticks([0:60:180])
ylim([0 160])
yticks([0:40:160])
h.BinWidth = 60/8;
ha = gca;
xlabel('Epicentral distance (degrees)')
ylabel('Count')

longticks(ha, 2)
axesfs(gcf, fs, fs)
latimes

[~, th] = labelaxes(gca, 'ul', true, 'FontSize', lbfs, 'Interpreter', 'LaTeX', 'FontName', 'Times');
th.String = strrep(th.String, 'a', 'b');
movev(th, 56);
moveh(th, -120);

[lg, tx] = textpatch(ha, 'NorthEast', sprintf('[N: %i]', sum(h.Values)), fs)
lg.Box = 'off';
ha.XTickLabel = cellfun(@(xx) [xx '$^{\circ}$'], ha.XTickLabels, 'UniformOutput', false)

savepdf('fig6b')
close

% Magnitude.
h = histogram(eqmag);
ha = gca;
xlim([4 8.5])
h.NumBins = 20;
h.FaceColor = 'k';

xlim([4 8.5])
xticks([4:8.5])
ylim([0 160])
yticks([0:40:160])

xlabel('Magnitude');
yl = ylabel('Count');

longticks(ha, 2)
axesfs(gcf, fs, fs)
latimes

[~, th] = labelaxes(gca, 'ul', true, 'FontSize', lbfs, 'Interpreter', 'LaTeX', 'FontName', 'Times');
movev(th, 56);
moveh(th, -120);
[lg, tx] = textpatch(ha, 'NorthEast', sprintf('[N: %i]', sum(h.Values)), fs)
lg.Box = 'off';

savepdf('fig6a')
close

% SNR as a function of magnitude and distance.
%_______________________________________________________________________________________%

snr_cutoff = 1024;
size_multiplier = 20;

facecolor = [0.9 0.9 0.9];
edgecolor = 'black';

SNR(SNR >= snr_cutoff) = snr_cutoff;
normsnr = norm2max(SNR);

% Note that MarkerSize in 'scatter' is points^2, while MarkerSize in
% 'plot' is points.
%
% Scatter: https://www.mathworks.com/help/matlab/ref/scatter.html?searchHighlight=scatter&s_tid=doc_srchtitle#btrj9jn-1-sz
% Plot: https://www.mathworks.com/help/matlab/ref/plot.html#btzitot_sep_shared-MarkerSize

ax = gca;
sc = scatter(ax, eqdist, eqmag, normsnr*size_multiplier^2);
sc.MarkerEdgeColor = edgecolor;
sc.MarkerFaceColor = facecolor;

xlim([0 180])
hold(ax, 'on')

% Plot reference SNRs for legend.
refsnr  = [snr_cutoff 512 256 128 64 32];
norm_refsnr = norm2max(refsnr);

for i = 1:length(refsnr)
    % Don't have to square the marker size here as you do in 'scatter'.
    refpl(i) = plot(ax, NaN, NaN, 'bo', 'MarkerSize', norm_refsnr(i)*size_multiplier);

end
set(refpl, 'MarkerEdgeColor', edgecolor);
set(refpl, 'MarkerFaceColor', facecolor);

lg = legend(ax, refpl),
lg.String = {'$\mathrm{SNR}\geq1024$', ...
             '$\mathrm{SNR}=512$',      ...
             '$\mathrm{SNR}=256$',      ...
             '$\mathrm{SNR}=128$',      ...
             '$\mathrm{SNR}=64$',       ...
             '$\mathrm{SNR}=32$'}
lg.Location = 'SouthEast';
lg.Interpreter = 'LaTeX';
lg.FontName = 'Times';
lg.Box = 'on';

ax.Box = 'on';
longticks([], 2)
axesfs(gcf, fs/2,  fs/2)

xlabel('Epicentral distance (degrees)')
xticks([0:20:180])
ax.XTickLabels = cellfun(@(xx) [xx '$^{\circ}$'], ax.XTickLabels, 'UniformOutput', false)

ylabel('Magnitude')

latimes

%lg.FontSize = (fs - 4) / 2;
grid(ax, 'on')
tack2corner(ax, lg, 'lr')

warning('requires adjustment of SNR box, likely')

[~, th] = labelaxes(gca, 'ul', true, 'FontSize', lbfs/2, 'Interpreter', 'LaTeX', 'FontName', 'Times');
th.String = strrep(th.String, 'a', 'c');
movev(th, 25);
moveh(th, -55);

[lg2, tx] = textpatch(ax, 'NorthEast', sprintf('[N: %i]', length(sc.SizeData)), fs/2);
lg2.Box = 'off'

lg.FontSize = 14;
tack2corner(ax, lg, 'lr')
savepdf('fig6c')

close

%% Helfpul printouts.
clc

[a,b] = min(eqmag);
EQ = getevt(s1{b});
% Ensure indexing is correct.
if ~isequal(a, EQ(1).PreferredMagnitudeValue); error('indexing to find min. screwed up'); end
fprintf('\n\n!!!!! Minimum magnitdue %.1f in %s at distance %.1f km !!!!!\n\n', a, EQ(1).FlinnEngdahlRegionName, EQ(1).TaupTimes(1).distance);
EQ

[a,b] = max(eqmag);
EQ = getevt(s1{b});
if ~isequal(a, EQ(1).PreferredMagnitudeValue); error('indexing to find max. screwed up'); end
fprintf('\n\n!!!!! Maxmimum magnitdue %.1f in %s at a distance of %.1f km !!!!!\n\n', a, EQ(1).FlinnEngdahlRegionName, EQ(1).TaupTimes(1).distance);
EQ

fprintf('\n\nMean magnitdue: %.1f\n\n', mean(eqmag))

% Find unique event identifications (ignoring leading asterisks which
% signal possible multi-event traces).
star_idx = cellstrfind(eqid, '*');
for i = 1:length(star_idx)
    eqid{star_idx(i)}(1) = [];

end
fprintf('\n\nIn all there were %i SAC files reported corresponding to %i unique events\n\n', length(s1), length(unique(eqid)));

[a,b] = min(eqdepth);
EQ = getevt(s1{b});
if ~isequal(a, EQ(1).PreferredDepth); error('indexing to find min. screwed up'); end
fprintf('\n\n!!!!! Minimum depth %.1f km in %s !!!!!\n\n', a, EQ(1).FlinnEngdahlRegionName);
EQ

[a,b] = max(eqdepth);
EQ = getevt(s1{b});
if ~isequal(a, EQ(1).PreferredDepth); error('indexing to find max. screwed up'); end
fprintf('\n\n!!!!! Maxmimum depth %.1f km in %s !!!!!\n\n', a, EQ(1).FlinnEngdahlRegionName);
EQ

%%______________________________________________________________________________________%%

% Compute great circle between them.
for i = length(s1):-1:1
        [trla{i}, trlo{i}] = track2(merlat(i), merlon(i), evtlat(i), evtlon(i));

end

makemap([realmin 70], eqdepth, trla, trlo, merlat, merlon, evtlat, evtlon, 'shallow')
makemap([70 300],  eqdepth, trla, trlo, merlat, merlon, evtlat, evtlon, 'intermediate')
makemap([300 realmax], eqdepth, trla, trlo, merlat, merlon, evtlat, evtlon, 'deep')

%%______________________________________________________________________________________%%
function makemap(minmaxdepth, eqdepth, trla, trlo, merlat, merlon, evtlat, ...
                 evtlon, dtype)

mindepth = minmaxdepth(1);
maxdepth = minmaxdepth(2);

fs = 22;
lbfs = 30;

% Set up map axes.
f = figure;
ax = gca;
fig2print(f, 'flandscape')
lw = 0.5;

% Generate base map.
origin = [0 211.6];
warning('Ensure map is centered on same longitude as smeared residuals')
axm = axesm('MapProjection', 'Hammer', 'Origin', origin);
geoshow(axm, 'landareas.shp', 'FaceColor', [1 1 1]);
setm(gca, 'FFaceColor', [0.85 0.85 0.85]);
framem('on')
hold(gca, 'on')

% Plot the plate boundaries.  Use 0:360 degrees because: (1) that's allowed, and
% (2) I don't have to average NaNs around the wrap at 180 degrees.
[~, ~, plat, plon] = plateboundaries;
plp = plotm(plat, plon, 'k', 'LineWidth', lw);

% Plot great-circle ray paths.
count = 0;
for i = 1:length(eqdepth)
    if  eqdepth(i) <= maxdepth && eqdepth(i) > mindepth
        pltr = plotm(trla{i}, trlo{i}, 'Color', 'k', 'LineWidth', lw);
        plevt = plotm(evtlat(i), evtlon(i), 'pr', 'MarkerFaceColor', 'r', 'MarkerSize', 12);
        plmer = plotm(merlat(i), merlon(i), 'v', 'MarkerFaceColor', porange, ...
                      'MarkerEdgeColor', porange, 'MarkerSize', 10);
        count = count + 1;

    end
end
hold(gca, 'off')
shg

switch lower(dtype)
  case 'shallow'
    tl = title(gca, sprintf('event depth $\\leq$ 70 km [N: %i]', count), 'FontSize', fs)
    labstr = 'a';

  case 'intermediate'
    tl = title(gca, sprintf('70 km $<$ event depth $\\leq$ 300 km [N: %i]', count), 'FontSize', fs)
    labstr = 'b';

  case 'deep'
    tl = title(gca, sprintf('event depth $>$ 300 km [N: %i]', count), 'FontSize', fs)
    labstr = 'c';

end
movev(tl, 0.0075);

tightmap
latimes
axis off

% Label.
text(-2.75, 1.5, ['(' labstr ')'], 'FontSize', lbfs, 'FontName', 'Time', 'Interpreter', 'LaTeX');

savepdf(['fig7' labstr])
close
