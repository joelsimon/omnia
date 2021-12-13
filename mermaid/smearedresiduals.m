function smearedresiduals
% SMEAREDRESIDUALS
%
% Plot 1-D smeared MERMAID residuals, adjusted for bathymetry and cruising
% depth ("1-D star") in South Pacific.
%
% Updates Fig. 11(c,d) in Simon et al. (2021), doi: 10.1093/gji/ggab271
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 13-Dec-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

% Define paths.
merdir = getenv('MERMAID');
procdir = fullfile(merdir, 'processed');
evtdir = fullfile(merdir, 'events');

defval('col_sat', 6) % seconds

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

% Remove any 'prelim.sac' files.
prelim_idx = cellstrfind(MER.s, 'prelim.sac');
MER = rmstructindex(MER, prelim_idx);

% Remove the indices (all arrays are indexed the same) corresponding to 2STD_ERR
% estimates beyond the allowable 0.15 s.  NB, the uncertainty is the same for
% all residual types.
max_twosd = 0.15; % s
high_twosd = find(MER.twosd > max_twosd);
MER = rmstructindex(MER, high_twosd);

% Keep only first arriving P waves.
non_p = find(~ismember(MER.ph, {'p' 'P'}));
MER = rmstructindex(MER, non_p);

% Remove NaN tres.
nan_tres = find(isnan(MER.tres));
MER = rmstructindex(MER, nan_tres);

% Compute great circle tracks between source/reciver.
[trla, trlo] = track2('gc', MER.evtlat, MER.evtlon, MER.merlat, MER.merlon);

skip_map = false;
%skip_map = true;

% "Nearby" box, 0:360 longitudes
maxlat = +04;  %  4 N ("top")
minlat = -33;  % 33 S ("bottom")

maxlon = +251; % 109 W or -109 ("right")
minlon = +176; % 176 E or +176 ("left")

fs = 20;

max_tres = 10;

high_tres = find(abs(MER.tres) > max_tres);
trla(:, high_tres) = [];
trlo(:, high_tres) = [];

MER = rmstructindex(MER, high_tres);

fprintf('\n%i positive residuals\n%i negative residuals',  sum(MER.tres > 0), ...
        sum(MER.tres < 0))

% % Uncomment this block to see some statistics, quoted in the paper.
% if any(strcmp(ct, 'e'))
%     [a, b] = min(MER.travtime_3D_adj);
%     fprintf('\nThe minimum 3D-1D travel-time correction plotted is %.2f seconds for %s\n',  a, MER.filename{b})

%     [a, b] = max(MER.travtime_3D_adj);
%     fprintf('The maximum 3D-1D travel-time correction plotted is %.2f seconds for %s\n',  a, MER.filename{b})

%     [a, b] = min(MER.tres);
%     fprintf('The minimum 3D smeared residual plotted is %.2f seconds for %s\n',  a, MER.filename{b})

%     [a, b] = max(MER.tres);
%     fprintf('The maximum 3D smeared residual plotted is %.2f seconds for %s\n',  a, MER.filename{b})

%     % Inspec event corresponding to max. 3D residual.
%     EQ = getevt(MER.filename{b}, [], true);

% end

%%______________________________________________________________________________________%%


% Set up map axes.
close all ; f = figure;
ax = gca;
fig2print(f, 'flandscape')

% MarkerSize and LineWidth.
S = 20;
lw = 0.5;

% Generate base map.
% https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/cf617d3d-d614-4b83-82f2-66f8e63b9e52/0c0b2edd-5aff-40d9-b921-d8a9163274ab/previews/plotEarthquakes/html/plotEarthquakes.html#14
maplatlimit = [-80.9 80.9];
maplonlimit = [79.5 180+163.701];
fprintf('\nThe map is centered on %.1f degrees longitude\n', mean(maplonlimit))
axm = axesm('MapProjection', 'Hammer', 'MapLatLimit', maplatlimit, ...
            'MapLonLimit', maplonlimit);
framem('on')
geoshow(axm, 'landareas.shp', 'FaceColor', [1 1 1]);
FFaceColor = [0.85 0.85 0.85];
setm(gca, 'FFaceColor', FFaceColor)

% Plot plate boundaries.
[~, ~, plat, plon] = plateboundaries;
plp = plotm(plat, plon, 'k', 'LineWidth', lw);

% These are the min/max saturation levels.
xmin = -col_sat;
xmax = col_sat;

% Use an odd-length colormap so that pure white (0% perurbation) is directly in the middle.
len_cmap = 12001;
cmap = colormap(bluewhiteredcmap(len_cmap));

% Place the ticklabels inside, rather than inbetween, color intervals
% so that there is 0 directly in the middle.
[col, cbticks, cbticklabels] = x2color(MER.tres, xmin, xmax, cmap, true);

% Plot great-circle ray paths color-coded by smeared residual.
count = 0;
hold(gca, 'on')
if ~skip_map
for i = 1:length(MER.tres)
    plotm(trla(:, i), trlo(:, i), 'Color', col(i, :), 'LineWidth', lw);

end
end
hold(gca, 'off')
shg

% Add colorbar and tick labels.
cb = colorbar;

cb.Ticks = cbticks(1:2000:end);
cb.TickLabels = cbticklabels(1:2000:end);
cb.TickLabels = cellfun(@(xx) xx, cb.TickLabels, 'UniformOutput', false);

% Fudge the ticklabels every so slightly; the actual values are in the
% middle of the colors but we want them to be at the edges; the
% difference won't be noticed.
cb.Ticks(1) = 0;   % vs. 0.0005 when len_cmap = 1001;
cb.Ticks(end) = 1; % vs. 0.9995 when len_cmap = 1001;
cb.TickLabels{4} = '0';

cb.TickDirection = 'out';
cb.Location = 'SouthOutside';
cb.FontSize = fs;
movev(cb, -0.1)

title(cb, 'Travel-time residual (s)')
cb.Title.Interpreter = 'LaTeX';
movev(cb.Title, -90)
annotation('textbox', [0.14 0.18 0 0], 'String', 'Fast', ...
           'Interpreter', 'LaTeX', 'FontName', 'Times', 'FontSize', ...
           fs, 'FontWeight', 'Normal')
annotation('textbox', [0.83 0.18 0 0], 'String', 'Slow', ...
           'Interpreter', 'LaTeX', 'FontName', 'Times', 'FontSize', ...
           fs, 'FontWeight', 'Normal')

tightmap
latimes(f, true)

% Remove bounding box.
axis off

%% THIS IS REQUIRED to not change white residuals to black.
set(gcf, 'InvertHardCopy', 'off', 'Color',[1 1 1])

savepdf('smearedresiduals')
close

%%______________________________________________________________________________________%%
%%______________________________________________________________________________________%%

% Histogram of the residuals.

figure
fig2print(gcf, 'flandscape')

% Set the data aspect ratio to match tbe "nearby" box.
ax = gca;

h = histogram(MER.tres, 'BinWidth', 0.5, 'BinLimits', [-max_tres max_tres], ...
              'FaceColor', 'k', 'FaceAlpha', 0.1, 'Normalization', 'Count');
xlim([-max_tres max_tres])
%ylim([0 90])

tl = title('$t^\star_\mathrm{res}$')
xlabel('Travel-time residual (s)')
%xticks([-10:2:10])
%yticks([0:30:90])
ylabel('Count')
hold on

M = mean(MER.tres);
S = std(MER.tres);

% The histogram includes mass beyond the xlims.
num_smeared = length(MER.tres);
num_hist = length(find(abs(MER.tres <= max(xlim))));

if ~isequal(num_smeared, sum(h.BinCounts))
    error(['Did not include all smeared residuals in histogram statistics ' ...
           '(though some MER.tres may extend beyond histogram xlimits'])

end

yl = ylim;

text(-9.5, 0.95*yl(2), sprintf('Mean = %.2f', M));
text(-9.5, 0.90*yl(2), sprintf('St. Dev. = %.2f', S));
text(-9.5, 0.85*yl(2), sprintf('Skewness = %.2f', skewness(MER.tres)));
text(+9.5, 0.95*yl(2), sprintf('N: %i', num_hist), 'HorizontalAlignment', 'Right');
plv = plot([M M], ylim, 'r',  'LineWidth', 1);
plv = plot([0 0 ], ylim, 'k',  'LineWidth', 1);
%plot([0 0], ylim, 'k-', 'LineWidth', 0.5);

longticks(gca, 3)

axesfs([], fs, fs)
set(tl, 'FontSize', 30, 'FontWeight', 'bold')
latimes

% Label.
fprintf(['\nPlotted %i smeared residuals in map, of which %i where within ' ...
         'histogram limits\n'], num_smeared, num_hist);


%%______________________________________________________________________________________%%
%% Stacked histogram, winnnowed for M5.5+ and dist>30 degrees.
%%______________________________________________________________________________________%%
MER30 = MER;

rm_mag_idx = find(MER30.magval < 5.5);
MER30 = rmstructindex(MER30, rm_mag_idx);

rm_dist_idx = find(MER30.dist < 30 | MER30.dist > 100);
MER30 = rmstructindex(MER30, rm_dist_idx);

h30 = histogram(MER30.tres, 'BinEdges', h.BinEdges', 'FaceColor', 'k', ...
                'FaceAlpha', 0.75, 'Normalization', 'Count');

fprintf('\n\nConerning the winnowed, M5.5+ and > 30 degrees histogram:\n')
fprintf('%i total (not necessarily within histogram) residuals with a mean of %.2f s\n\n', ...
        length(MER30.tres), mean(MER30.tres))

topz(plv)

savepdf('smearedhist')
close

end
