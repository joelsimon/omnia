function sppimres
% SPPIMRES
%
% Update Figs. 11(c--d) from Simon et al., GJI, 2022 (10.1093/gji/ggab271):
% smeared map/histogram of SPPIM residuals with bathymetric correction
% ("T-res star").
%
% Make sure to first run: write_update_simon2021gji_supplement_residuals.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 24-Apr-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

% Have to add path to function to read updated SPPIM residuals file;
% as of writing this is not something I automatically add in `startup`
updated_res_path = fullfile(getenv('OMNIA'), 'GJI2021', 'update_supplement')
addpath(updated_res_path)

% Get data from updated supplementary text file.
MER = read_update_simon2021gji_supplement_residuals;

% Remove the indices (all arrays are indexed the same) corresponding to 2STD_ERR
% estimates beyond the allowable 0.15 s.  NB, the uncertainty is the same for
% all residual types.
max_twosd = 0.15; % s
high_twosd = find(MER.twosd > max_twosd);
MER = rmstructindex(MER, high_twosd);

% Compute great circle tracks between source/reciver.
[trla, trlo] = track2('gc', MER.evla, MER.evlo, MER.stla, MER.stlo);

% Toggle smeared-residual color saturation.
defval('col_sat', 6) % seconds

% Make the map.
makemap(MER, 'tres_1Dstar',  col_sat, trla, trlo, '$t^\star_\mathrm{res}$', {'c' 'd'})

addpath(updated_res_path)

%_________________________________________________________________%

function makemap(MER, res_type, col_sat, trla, trlo, res_str, ct)
skip_map = false;
%skip_map = true;

% "Nearby" box, 0:360 longitudes
maxlat = +04;  %  4 N ("top")
minlat = -33;  % 33 S ("bottom")

maxlon = +251; % 109 W or -109 ("right")
minlon = +176; % 176 E or +176 ("left")

fs = 20;

% Winnow based on maxmimum tres AFTER converting into the proper model format.
%%______________________________________________________________________________________%%
max_tres = 10;

high_tres = find(abs(MER.(res_type)) > max_tres);
trla(:, high_tres) = [];
trlo(:, high_tres) = [];

MER = rmstructindex(MER, high_tres);

fprintf('\n\n!!!!!! For map: %s\n', ct{1})
fprintf('\n%i positive residuals\n%i negative residuals',  sum(MER.(res_type) > 0), ...
        sum(MER.(res_type) < 0))

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
[col, cbticks, cbticklabels] = x2color(MER.(res_type), xmin, xmax, cmap, true);

% Plot great-circle ray paths color-coded by smeared residual.
count = 0;
hold(gca, 'on')
if ~skip_map
    for i = 1:length(MER.(res_type))
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

savepdf(['fig11' ct{1}]);
close

%%______________________________________________________________________________________%%
%%______________________________________________________________________________________%%

% Histogram of the residuals.

figure
fig2print(gcf, 'flandscape')

% Set the data aspect ratio to match tbe "nearby" box.
ax = gca;

h = histogram(MER.(res_type), 'BinWidth', 0.5, 'BinLimits', [-max_tres max_tres], ...
              'FaceColor', 'k', 'FaceAlpha', 0.1, 'Normalization', 'Count');
xlim([-8 8])
%ylim([0 90])

tl = title(sprintf('%s', res_str));
xlabel('Travel-time residual (s)')
xticks([-8:2:8])
%yticks([0:30:90])
ylabel('Count')
hold on

M = mean(MER.(res_type));
S = std(MER.(res_type));

% The histogram includes mass beyond the xlims.
num_smeared = length(MER.(res_type));
num_hist = length(find(abs(MER.(res_type) <= max(xlim))));

if ~isequal(num_smeared, sum(h.BinCounts))
    error(['Did not include all smeared residuals in histogram statistics ' ...
           '(though some MER.(res_type) may extend beyond histogram xlimits'])

end

txstr = sprintf('Mean = %.2f\nSt. Dev. = %.2f\nSkewness = %.2f', M, S, skewness(MER.(res_type)));

plv = plot([M M], ylim, 'r-',  'LineWidth', 2);
plot([0 0], ylim, 'k', 'LineWidth', 2);

longticks(ax, 3)

axesfs([], fs, fs)
set(tl, 'FontSize', 30, 'FontWeight', 'bold')
latimes

fprintf(['\nPlotted %i smeared residuals in map, of which %i where within ' ...
         'histogram limits\n'], num_smeared, num_hist);


%%______________________________________________________________________________________%%
%% Stacked histogram, winnnowed for M5.5+ and dist>30 degrees.
%%______________________________________________________________________________________%%
MER30 = MER;

rm_mag_idx = find(MER30.mag_val < 5.5);
MER30 = rmstructindex(MER30, rm_mag_idx);

rm_dist_idx = find(MER30.gcarc_1D < 30 | MER30.gcarc_1D > 100);
MER30 = rmstructindex(MER30, rm_dist_idx);

h30 = histogram(MER30.(res_type), 'BinEdges', h.BinEdges', 'FaceColor', 'k', ...
                'FaceAlpha', 0.75, 'Normalization', 'Count');

fprintf('\n\nConerning the winnowed, M5.5+ and > 30 degrees histogram:\n')
fprintf('%i total (not necessarily within histogram) residuals with a mean of %.2f s\n\n', ...
        length(MER30.(res_type)), mean(MER30.(res_type)))

topz(plv)

% % Make axes box the same aspect ratio as the "nearby" box in the South Pacific
% pbaspect([(range([minlon maxlon]) / range([minlat maxlat])) 1 1])

textpatch(h30.Parent, 'NorthWest', txstr, fs, [], true, 'HorizontalAligment', 'left');
textpatch(h30.Parent, 'NorthEast', sprintf('[N: %i  / %i]', num_hist, num_smeared), fs);

savepdf(['fig11' ct{2}]);
close
