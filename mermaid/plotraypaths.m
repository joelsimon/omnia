function plotraypaths(idfile, fafile, fapfile, starttime, endtime, bindepth, returntype)
% PLOTRAYPATHS(idfile, fafile, fapfile, starttime, endtime, bindepth, returntype)
%
% Inspired by Fig. 8 in paper??
%
% Input:
% idfile       Textfile name, output by evt2txt.m
%                  (def: $MERMAID/events/reviewed/identified/txt/identified.txt)
% fafile       Textfile name, output by writefirstarrival.m
%                  (def: $MERMAID/events/reviewed/identified/txt/firstarrival.txt)
% fapfile      Textfile name, output by writefirstarrivalpressure.m
%                  (def: $MERMAID/events/reviewed/identified/txt/firstarrivalpressure.txt)
% starttime    Inclusive start time (earliest SAC file time to consider), as datetime
%                  (def: start at first SAC file in catalog)
% endtime      Inclusive end time (latest SAC file time to consider), as datetime
%                  (def: end current datetime)
% bindepth     false: plot rapyaths from all EQs on single map (def)
%              true: bin raypaths by EQ depth (shallow, intermediate, deep)
% returntype   'ALL': both triggered and user-requested SAC files (def)
%              'DET': triggered SAC files as determined by onboard algorithm
%              'REQ': user-requested SAC file
%
% Author: Dr. Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 02-Sep-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

% Default filenames
defval('idfile', fullfile(getenv('MERMAID'), 'events', 'reviewed', 'identified', 'txt', 'identified.txt'))
defval('fafile', fullfile(getenv('MERMAID'), 'events', 'reviewed', 'identified', 'txt', 'firstarrival.txt'))
defval('fapfile', fullfile(getenv('MERMAID'), 'events', 'reviewed', 'identified', 'txt', 'firstarrivalpressure.txt'))
defval('starttime', []) % [] = first SAC file
defval('endtime', []) % [] = last SAC file
defval('bindepth', false)
defval('returntype', 'ALL')

%% This is for the "preferred" event values (Mw magnitude, etc.)
[s1, ~, eqlat, eqlon, ~, eqdepth, eqdist, eqmag, ~, eqid] = ...
    readidentified(idfile, starttime, endtime, 'SAC', returntype);

%% This is for the SNR of the event
[s2, ~, ~, ~, ~, ~, ~, ~, ~, SNR] = readfirstarrival(fafile);

% Kepp only SAC files corresponding to input paramters.
[~, idx] = intersect(s2, s1);
SNR = SNR(idx);

%% This is for the event/MERMAID latitude and lonitude at the time of the event.
[s3, ~, ~, ~, ~, ~, ~, ~, merlat, merlon, evtlat, evtlon] = readfirstarrivalpressure(fapfile);

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
h = histogram(eqdist);
ha = gca;
h.FaceColor = 'k';
xlim([0 180])
xticks([0:60:180])
%ylim([0 160])
%yticks([0:40:160])
h.NumBins = 23;
ha = gca;
xlabel('Epicentral distance (degrees)')
ylabel('Count')

longticks(ha, 2)
axesfs(gcf, fs, fs)
latimes

% [~, th] = labelaxes(gca, 'ul', true, 'FontSize', lbfs, 'Interpreter', 'LaTeX', 'FontName', 'Times');
% th.String = strrep(th.String, 'a', 'b');
% movev(th, 56);
% moveh(th, -100);

[lg, tx] = textpatch(ha, 'NorthEast', sprintf('[N: %i]', sum(h.Values)), fs)
lg.Box = 'off';
ha.XTickLabel = cellfun(@(xx) [xx '$^{\circ}$'], ha.XTickLabels, 'UniformOutput', false)

savepdf('disthist')
close

% Magnitude.
h = histogram(eqmag);
ha = gca;
xlim([4 8.5])
h.NumBins = 20;
h.FaceColor = 'k';

xlim([4 8.5])
xticks([4:8.5])
%ylim([0 100])
%yticks([0:25:100])

xlabel('Magnitude')
ylabel('Count')

longticks(ha, 2)
axesfs(gcf, fs, fs)
latimes

% [~, th] = labelaxes(gca, 'ul', true, 'FontSize', lbfs, 'Interpreter', 'LaTeX', 'FontName', 'Times');
% movev(th, 56);
% moveh(th, -100);

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

% [~, th] = labelaxes(gca, 'ul', true, 'FontSize', lbfs/2, 'Interpreter', 'LaTeX', 'FontName', 'Times');
% th.String = strrep(th.String, 'a', 'c');
% movev(th, 25);
% moveh(th, -55);

[lg2, tx] = textpatch(ax, 'NorthEast', sprintf('[N: %i]', length(sc.SizeData)), fs/2);
lg2.Box = 'off'

lg.FontSize = 14;
tack2corner(ax, lg, 'lr')
savepdf('distmagsnr')

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

if bindepth
    makemap([min(eqdepth) 70], eqdepth, trla, trlo, merlat, merlon, evtlat, evtlon, 'shallow')
    makemap([70 300],  eqdepth, trla, trlo, merlat, merlon, evtlat, evtlon, 'intermediate')
    makemap([300 max(eqdepth)], eqdepth, trla, trlo, merlat, merlon, evtlat, evtlon, 'deep')

else
    makemap([min(eqdepth)-1 max(eqdepth)+1], eqdepth, trla, trlo, merlat, merlon, evtlat, evtlon, [])

end

%%______________________________________________________________________________________%%
function makemap(minmaxdepth, eqdepth, trla, trlo, merlat, merlon, evtlat, ...
                 evtlon, dtype)

mindepth = minmaxdepth(1);
maxdepth = minmaxdepth(2);

fs = 22;
lbfs = 30;
skip_map = false;
%skip_map = true;

if ~skip_map
% Set up map axes.
f = figure;
ax = gca;
fig2print(f, 'flandscape')

% Generate base map.
%origin = [-17.6509 -149.4260];
origin = [0 -155];
axm = axesm('MapProjection', 'Hammer', 'Origin', origin);
geoshow(axm, 'landareas.shp', 'FaceColor', [1 1 1]);
setm(gca, 'FFaceColor', [0.85 0.85 0.85]);
framem('on')

% LineWidth.
lw = 0.5;

% % Plot great-circle ray paths.
count = 0;
hold(gca, 'on')
for i = length(eqdepth):-1:1
    if  eqdepth(i) <= maxdepth && eqdepth(i) > mindepth
        pltr(i) = plotm(trla{i}, trlo{i}, 'Color', 'k', 'LineWidth', lw);
        plevt(i) = plotm(evtlat(i), evtlon(i), 'pr', 'MarkerFaceColor', 'r', 'MarkerSize', 12);
        plmer(i) = plotm(merlat(i), merlon(i), 'v', 'MarkerFaceColor', porange, ...
                      'MarkerEdgeColor', porange, 'MarkerSize', 10);
        count = count + 1;

    end
end
hold(gca, 'off')
shg
if ~isempty(dtype)
    switch lower(dtype)
      case 'shallow'
        tl = title(gca, sprintf('event depth $\\leq$ 70 km [N: %i]', count), 'FontSize', fs)
        labstr = '(a)';

      case 'intermediate'
        tl = title(gca, sprintf('70 km $<$ event depth $\\leq$ 300 km [N: %i]', count), 'FontSize', fs)
        labstr = '(b)';

      case 'deep'
        tl = title(gca, sprintf('event depth $>$ 300 km [N: %i]', count), 'FontSize', fs)
        labstr = '(c)';

    end
    movev(tl, 0.0075);
end

tightmap
latimes
axis off

% Label.
if ~isempty(dtype)
    text(-2.75, 1.5, labstr, 'FontSize', lbfs, 'FontName', 'Time', 'Interpreter', 'LaTeX');
    savepdf(sprintf('rays_%s', dtype))

else
    savepdf('rays')

end
keyboard
close

end
