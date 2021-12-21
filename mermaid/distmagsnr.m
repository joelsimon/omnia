function distmagsnr
% DISTMAGSNR
%
% Plots distance and magnitude histograms, plus SNR as a function to magntidue
% and distance scatter plot; AND raypaths for ALL identified events; no
% winnowing.
%
% Updates Fig. 6 & 7 of  Simon et al. (2021), doi: 10.1093/gji/ggab271
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 13-Dec-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

% Parameters.
wlen = 30;
lohi = [1 5];
wlen2 = [1.75];

% Load residual data.
FA = readfirstarrivalstruct;
FAP = readfirstarrivalpressurestruct;
if ~isequal(FA.s, FAP.s)
    error('indexing issue')

end

% Combine residual structures into megastruct.
MER = FA;
fields = fieldnames(FAP);
for i = 1:length(fields)
    if ~isfield(MER, fields{i})
        MER.(fields{i}) = FAP.(fields{i});

    end
end

% The magnitudes in FAP are the "MbMLMagnitude" value, useful for reid., and
% not the IRIS-Preferred magnitudes. Overwrite them.
[sac, ~, ~, ~, ~, ~, ~, preferred_magval] = readidentified;
[~, mer_idx] = intersect(MER.s, sac);
for i = 1:length(mer_idx)
    MER.preferred_magval = preferred_magval;

end

% Remove any 'prelim.sac' files.
prelim_idx = cellstrfind(MER.s, 'prelim.sac');
MER = rmstructindex(MER, prelim_idx);

% Keep only first arriving P waves.
non_det = find(~contains(MER.s, 'DET'));
MER = rmstructindex(MER, non_det);

% Remove NaN tres.
nan_tres = find(isnan(MER.tres));
MER = rmstructindex(MER, nan_tres);


%%______________________________________________________________________________________%%

fs = 32;
lbfs = 47;

%% Distance and magnitude histograms; SNR as s function of magnitude and distance scatter plot.

% Distance.
h = histogram(MER.dist, 'BinLimits', [0 180]);
ha = gca;
h.FaceColor = 'k';
xlim([0 180])
xticks([0:60:180])
%ylim([0 160])
%yticks([0:40:160])
h.BinWidth = 60/8;
ha = gca;
xlabel('Epicentral distance (degrees)')
ylabel('Count')

longticks(ha, 2)
axesfs(gcf, fs, fs)
latimes


[lg, tx] = textpatch(ha, 'NorthEast', sprintf('[N: %i]', sum(h.Values)), fs)
lg.Box = 'off';
ha.XTickLabel = cellfun(@(xx) [xx '$^{\circ}$'], ha.XTickLabels, 'UniformOutput', false)

savepdf('disthist')
close

% Magnitude.
h = histogram(MER.preferred_magval);
ha = gca;
xlim([4 8.5])
h.NumBins = 20;
h.FaceColor = 'k';

xlim([4 8.5])
xticks([4:8.5])
%ylim([0 160])
%yticks([0:40:160])

xlabel('Magnitude');
yl = ylabel('Count');

longticks(ha, 2)
axesfs(gcf, fs, fs)
latimes

[lg, tx] = textpatch(ha, 'NorthEast', sprintf('[N: %i]', sum(h.Values)), fs)
lg.Box = 'off';

savepdf('maghist')
close

% SNR as a function of magnitude and distance.
%_______________________________________________________________________________________%

snr_cutoff = 1024;
size_multiplier = 20;

facecolor = [0.9 0.9 0.9];
edgecolor = 'black';

MER.SNR(MER.SNR >= snr_cutoff) = snr_cutoff;
normsnr = norm2max(MER.SNR);

% Note that MarkerSize in 'scatter' is points^2, while MarkerSize in
% 'plot' is points.
%
% Scatter: https://www.mathworks.com/help/matlab/ref/scatter.html?searchHighlight=scatter&s_tid=doc_srchtitle#btrj9jn-1-sz
% Plot: https://www.mathworks.com/help/matlab/ref/plot.html#btzitot_sep_shared-MarkerSize

ax = gca;
sc = scatter(ax, MER.dist, MER.preferred_magval, normsnr*size_multiplier^2);
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

[lg2, tx] = textpatch(ax, 'NorthEast', sprintf('[N: %i]', length(sc.SizeData)), fs/2);
lg2.Box = 'off'

lg.FontSize = 14;
tack2corner(ax, lg, 'lr')
savepdf('distmagsnr')

close

%% Helfpul printouts.
clc

[a,b] = min(MER.preferred_magval);
EQ = getevt(MER.s{b});
% Ensure indexing is correct.
if ~isequal(a, EQ(1).PreferredMagnitudeValue); error('indexing to find min. screwed up'); end
fprintf('\n\n!!!!! Minimum magnitdue %.1f in %s at distance %.1f km !!!!!\n\n', a, EQ(1).FlinnEngdahlRegionName, EQ(1).TaupTimes(1).distance);
EQ

[a,b] = max(MER.preferred_magval);
EQ = getevt(MER.s{b});

if ~isequal(a, EQ(1).PreferredMagnitudeValue); error('indexing to find max. screwed up'); end
fprintf('\n\n!!!!! Maxmimum magnitdue %.1f in %s at a distance of %.1f km !!!!!\n\n', a, EQ(1).FlinnEngdahlRegionName, EQ(1).TaupTimes(1).distance);
EQ

fprintf('\n\nMean magnitdue: %.1f\n\n', mean(MER.preferred_magval))

% Find unique event identifications (ignoring leading asterisks which
% signal possible multi-event traces).
star_idx = cellstrfind(MER.ID, '*');
for i = 1:length(star_idx)
    MER.ID{star_idx(i)}(1) = [];

end
fprintf('\n\nIn all there were %i SAC files reported corresponding to %i unique events\n\n', length(MER.s), length(unique(MER.ID)));

[a,b] = min(MER.depth);
EQ = getevt(MER.s{b});
if ~isequal(a, EQ(1).PreferredDepth); error('indexing to find min. screwed up'); end
fprintf('\n\n!!!!! Minimum depth %.1f km in %s !!!!!\n\n', a, EQ(1).FlinnEngdahlRegionName);
EQ

[a,b] = max(MER.depth);
EQ = getevt(MER.s{b});
if ~isequal(a, EQ(1).PreferredDepth); error('indexing to find max. screwed up'); end
fprintf('\n\n!!!!! Maxmimum depth %.1f km in %s !!!!!\n\n', a, EQ(1).FlinnEngdahlRegionName);
EQ

%%______________________________________________________________________________________%%

% Compute great circle between them.
for i = length(MER.s):-1:1
        [trla{i}, trlo{i}] = track2(MER.merlat(i), MER.merlon(i), MER.evtlat(i), MER.evtlon(i));

end

makemap([realmin 70], MER.depth, trla, trlo, MER.merlat, MER.merlon, MER.evtlat, MER.evtlon, 'shallow')
makemap([70 300],  MER.depth, trla, trlo, MER.merlat, MER.merlon, MER.evtlat, MER.evtlon, 'intermediate')
makemap([300 realmax], MER.depth, trla, trlo, MER.merlat, MER.merlon, MER.evtlat, MER.evtlon, 'deep')

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

savepdf(dtype)
close
