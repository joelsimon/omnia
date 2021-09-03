function fig11
% FIG11
%
% Plot smeared residuals vs. ak135, ak135 adjusted, and LLNL-G3Dv3.
%
% Developed as: simon2020_smearedres3D.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 03-Sep-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

defval('commonID', false)

% Define paths.
merdir = getenv('MERMAID');
procdir = fullfile(merdir, 'processed');
evtdir = fullfile(merdir, 'events');

% Ensure in GJI21 git branch.
startdir = pwd;
cd(procdir)
system('git checkout GJI21');
cd(evtdir)
system('git checkout GJI21');
cd(startdir)

defval('col_sat', 6) % seconds

% Paths to the relevant ID file and other necessary directories.
datadir = fullfile(getenv('GJI21_CODE'), 'data');

% Get data from supplementary text file.
supplement_directory = fullfile(getenv('GJI21_CODE'), 'data', 'supplement');
residuals_filename = fullfile(supplement_directory, 'simon2021gji_supplement_residuals.txt');
MER = read_simon2021gji_supplement_residuals(residuals_filename);

% Remove the indices (all arrays are indexed the same) corresponding to 2STD_ERR
% estimates beyond the allowable 0.15 s.  NB, the uncertainty is the same for
% all residual types.
max_twosd = 0.15; % s
high_twosd = find(MER.twosd > max_twosd);
MER = rmstructindex(MER, high_twosd);

% Compute great circle tracks between source/reciver.
[trla, trlo] = track2('gc', MER.evla, MER.evlo, MER.stla, MER.stlo);

if max_twosd ~= realmax


else
    str = 'all';

end

% Make the map.
makemap(MER, 'tres_1D', col_sat, trla, trlo, '$t_\mathrm{res}$', {'a' 'b'}, datadir)
makemap(MER, 'tres_1Dstar',  col_sat, trla, trlo, '$t^\star_\mathrm{res}$', {'c' 'd'}, datadir)
makemap(MER, 'tres_3D', col_sat, trla, trlo, '$t^\oplus_\mathrm{res}$', {'e' 'f'}, datadir)

%_________________________________________________________________%

function makemap(MER, res_type, col_sat, trla, trlo, res_str, ct, datadir)
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

high_tres = find(abs(MER.(res_type) > max_tres));
trla(:, high_tres) = [];
trlo(:, high_tres) = [];

MER = rmstructindex(MER, high_tres);

fprintf('\n\n!!!!!! For map: %s\n', ct{1})
fprintf('\n%i positive residuals\n%i negative residuals',  sum(MER.(res_type) > 0), ...
        sum(MER.(res_type) < 0))

% % Uncomment this block to see some statistics, quoted in the paper.
% if any(strcmp(ct, 'e'))
%     [a, b] = min(MER.travtime_3D_adj);
%     fprintf('\nThe minimum 3D-1D travel-time correction plotted is %.2f seconds for %s\n',  a, MER.filename{b})

%     [a, b] = max(MER.travtime_3D_adj);
%     fprintf('The maximum 3D-1D travel-time correction plotted is %.2f seconds for %s\n',  a, MER.filename{b})

%     [a, b] = min(MER.(res_type));
%     fprintf('The minimum 3D smeared residual plotted is %.2f seconds for %s\n',  a, MER.filename{b})

%     [a, b] = max(MER.(res_type));
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

% Label.
text(-2.25, 1.2, sprintf('(%s)', ct{1}), 'FontSize', 30, 'Interpreter', ...
     'LaTeX', 'FontName', 'Times');

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
ylim([0 90])

tl = title(sprintf('%s', res_str));
xlabel('Travel-time residual (s)')
xticks([-10:2:10])
yticks([0:30:90])
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

text(-7.5, 82, sprintf('Mean = %.2f', M));
text(-7.5, 76, sprintf('St. Dev. = %.2f', S));
text(-7.5, 70, sprintf('Skewness = %.2f', skewness(MER.(res_type))));
text(+7.5, 82, sprintf('[N: %i  / %i]', num_hist, num_smeared), 'HorizontalAlignment', 'Right');
plv = plot([M M], ylim, 'k--',  'LineWidth', 1);
%plot([0 0], ylim, 'k-', 'LineWidth', 0.5);

longticks(gca, 3)

axesfs([], fs, fs)
set(tl, 'FontSize', 30, 'FontWeight', 'bold')
latimes

% Label.
tx2 = text(-9.5, 100, sprintf('(%s)', ct{2}), 'FontSize', 30, 'Interpreter', ...
           'LaTeX', 'FontName', 'Times');

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

% Make axes box the same aspect ratio as the "nearby" box in the South Pacific
pbaspect([(range([minlon maxlon]) / range([minlat maxlat])) 1 1])

savepdf(['fig11' ct{2}]);
close

%%______________________________________________________________________________________%%
%%______________________________________________________________________________________%%

% Zoomed-in box, for LLNL residuals only.
if strcmp(res_type, 'tres_3D')
    bf = figure;
    fig2print(bf, 'flandscape')
    bax = gca;
    xlim([minlon maxlon])
    ylim([minlat maxlat])
    set(bax, 'DataAspectRatio', [1 1 1], 'Color', FFaceColor, 'Box', 'on')

    hold(bax, 'on')

    box_plates = plot(plon, plat, 'k', 'LineWidth', lw);

    % Retain only the ray paths wholly contained within the box (easier to do
    % comparisions on 0:360 than -180:180).
    box_trla = trla;
    box_trlo = trlo;
    box_trlo_360 = trlo;
    box_trlo_360(box_trlo_360<0) = box_trlo_360(box_trlo_360<0) + 360;

    box_trla_idx = intersect(find(min(box_trla)>=minlat), find(max(box_trla)<=maxlat));
    box_trlo_360_idx = intersect(find(min(box_trlo_360)>=minlon), find(max(box_trlo_360)<=maxlon));
    box_idx = intersect(box_trla_idx, box_trlo_360_idx);

    box_trla = box_trla(:,box_idx);
    box_trlo = box_trlo(:,box_idx);
    box_trlo_360 = box_trlo_360(:, box_idx);
    box_col = col(box_idx,:);

    outside_box = setdiff(1:length(MER.filename), box_idx);
    box_MER = rmstructindex(MER, outside_box);

    % Generate base map.
    hold(bax, 'on')
    maxdepth = nan(size(box_idx));
    for i = 1:length(box_idx)
        % % Compute turning (or maximum; the hypocenter) depth for the first phase.
        % tp = taupPath('ak135', ...
        %               box_MER.evdp(i)/1000, ... % km
        %               'p,P', ...
        %               'sta', ....
        %               [box_MER.stla(i) box_MER.stlo(i)], ...
        %               'evt', ...
        %               [box_MER.evla(i) box_MER.evlo(i)], ....
        %               'plot', false);

        % max_depth(i) = max(tp(1).path.depth);

        % Use `box_trlo_360` in keeping with convention of FJS's map.
        plot(bax, box_trlo_360(:,i), box_trla(:,i), 'Color', box_col(i,:), 'LineWidth', lw); % lon first!

    end
    % fprintf('The mean turning (or maximum) depth of rays within the box is: %i\n', round(mean(max_depth)))

    box_XTick = [180:10:250];
    box_XLabel_String = 'Longitude';
    box_XTickLabel = {'-180$^{\circ}$'  ...
                     '-170$^{\circ}$' ...
                     '-160$^{\circ}$' ...
                     '-150$^{\circ}$' ...
                     '-140$^{\circ}$' ...
                     '-130$^{\circ}$' ...
                     '-120$^{\circ}$' ...
                     '-110$^{\circ}$'};

    box_YTick = [-30:10:0];
    box_YLabel_String = 'Latitude';
    box_YTickLabel = flip({'0$^{\circ}$' ...
                        '-10$^{\circ}$' ...
                        '-20$^{\circ}$' ...
                        '-30$^{\circ}$'});

    bax.XTick = box_XTick;
    bax.XLabel.String = box_XLabel_String;
    bax.XTickLabel = box_XTickLabel;

    bax.YTick = box_YTick;
    bax.YLabel.String = box_YLabel_String;
    bax.YTickLabel = box_YTickLabel;

    % Add colorbar and tick labels.
    bcb = colorbar;
    cmap = colormap(bluewhiteredcmap(len_cmap));
    bcb.Ticks = cbticks(1:2000:end);
    bcb.TickLabels = cbticklabels(1:2000:end);
    bcb.TickLabels = cellfun(@(xx) xx, bcb.TickLabels, 'UniformOutput', false);

    % Fudge the ticklabels every so slightly; the actual values are in the
    % middle of the colors but we want them to be at the edges; the
    % difference won't be noticed.
    bcb.Ticks(1) = 0;   % vs. 0.0005 when len_cmap = 1001;
    bcb.Ticks(end) = 1; % vs. 0.9995 when len_cmap = 1001;
    bcb.TickLabels{4} = '0';

    bcb.TickDirection = 'out';
    bcb.Location = 'SouthOutside';
    bcb.FontSize = fs;
    bcb.Position(2) = 0.1071;

    title(bcb, 'Travel-time residual (s)')
    bcb.Title.Interpreter = 'LaTeX';
    movev(bcb.Title, -90)

    a1_loc = [0.14 0.18 0 0];
    ba1 = annotation('textbox', a1_loc, 'String', 'Fast', 'Interpreter', 'LaTeX', ...
                    'FontName', 'Times', 'FontSize', fs, 'FontWeight', ...
                    'Normal');
    a2_loc = [0.83 0.18 0 0];
    ba2 = annotation('textbox', a2_loc, 'String', 'Slow', 'Interpreter', 'LaTeX', ...
                    'FontName', 'Times', 'FontSize', fs, 'FontWeight', ...
                    'Normal');

    axesfs(bf, fs, fs)

    %% Add histogram within nearby box
    bax2 = axes;
    bax2.Position = [0.7 0.58 0.16 0.16];

    bh = histogram(box_MER.(res_type), 'BinWidth', 0.5, 'BinLimits', [-max_tres ...
                        max_tres], 'FaceColor', 'k', 'Normalization', 'Count');
    xlim([-8 8])
    ylim([0 50])

    %btl = title(sprintf('%s', res_str));
    %xlabel('Travel-time residual (s)')
    xlabel(sprintf('%s (s)', res_str));
    xticks([-8:4:8])
    yticks([0:25:50])
    ylabel('Count')
    hold on

    bM = mean(box_MER.(res_type));
    bS = std(box_MER.(res_type));

    % The histogram includes mass beyond the xlims.
    bnum_smeared = length(box_MER.(res_type));
    bnum_hist = length(find(abs(box_MER.(res_type) <= max(xlim))));

    if ~isequal(bnum_smeared, sum(bh.BinCounts))
        error(['Did not include all smeared residuals in histogram statistics ' ...
               '(though some MER.(res_type) may extend beyond histogram xlimits'])

    end

    fprintf('Nearby box: number smeared = %i\n', bnum_smeared)
    fprintf('Nearby box: number hisogram = %i\n', bnum_hist)
    fprintf('Nearby box: mean = %.2f\n', bM)
    fprintf('Nearby box: std = %.2f\n', bS)

    plot([bM bM], ylim, 'k--',  'LineWidth', 1);

    bax2.FontSize = 16;

    latimes(bf, true)
    longticks(bax, 3)
    longticks(bax2, 0.75)

    btx = text(bax, 167, 8, '(g)', 'FontSize', 30, 'Interpreter', 'LaTeX', 'FontName', ...
               'Times');

    set(gcf, 'InvertHardCopy', 'off', 'Color',[1 1 1])
    savepdf('fig11g')

    %% ___________________________________________________________________________ %%
    %% Seahorse map at 500 km depth (using LLNL-G3Dv3 data compiled by Alex Burky) %%
    close

    % A blind load like this is pretty sketchy but it works...
    % Loaded variables: V, lat, lon, z
    % Note this file was originally named (by Alex): "LLNL_500km_Slice.mat"
    load(fullfile(datadir, 'llnl_tomography', 'LLNL.mat'))

    sf = figure;
    fig2print(sf, 'flandscape')
    sax = gca;

    slice_depth = 500 %km

    % Interpolate a horizontal plane at 500 km depth from Alex's volume.
    seahorse_XData = linspace(minlon, maxlon, 1e4);
    seahorse_YData = linspace(minlat, maxlat, length(seahorse_XData));
    seahorse_CData = interp3(lon, lat, z, V, seahorse_XData, seahorse_YData, slice_depth);

    % The lon vector Alex provided maxes out at 250.7839.  I need to get it
    % to 251 -- copy all final non-NaN column.
    nan_column = find(isnan(seahorse_CData(1,:)));
    copy_column = seahorse_CData(:, nan_column(1)-1);
    seahorse_CData(:, nan_column) = repmat(copy_column, 1, length(nan_column));
    im = imagesc(seahorse_XData, seahorse_YData, seahorse_CData);

    xlim([minlon maxlon])
    ylim([minlat maxlat])
    colormap(flip(jet(len_cmap)))

    sax.YDir = 'normal';
    caxis([-2 2])
    set(sax, 'DataAspectRatio', [1 1 1])

    sax.XTick = box_XTick;
    sax.XLabel.String = box_XLabel_String;
    sax.XTickLabel = box_XTickLabel;

    sax.YTick = box_YTick;
    sax.YLabel.String = box_YLabel_String;
    sax.YTickLabel = box_YTickLabel;

    scb = colorbar;
    scb.Ticks = [-2:.5:2];
    scb.TickDirection = 'out';
    scb.Location = 'SouthOutside';
    scb.FontSize = fs;
    scb.Position(2) = 0.1071;

    scb.Title.String = '$\delta\mathrm{V}\hspace{-.25em}_\textit{P}$ (\%)';
    scb.Title.Interpreter = 'LaTeX';
    movev(scb.Title, -90)

    sa1 = annotation('textbox', a1_loc, 'String', 'Slow', 'Interpreter', ...
                     'LaTeX', 'FontName', 'Times', 'FontSize', fs, 'FontWeight', ...
                     'Normal');

    sa2 = annotation('textbox', a2_loc, 'String', 'Fast', 'Interpreter', ...
                     'LaTeX', 'FontName', 'Times', 'FontSize', fs, 'FontWeight', ...
                     'Normal');

    axesfs(sf, fs, fs)
    latimes(sf, true)
    longticks(sax, 3)

    btx = text(sax, 167, 8, '(h)', 'FontSize', 30, 'Interpreter', 'LaTeX', 'FontName', ...
               'Times');

    savepdf('fig11h')

    % %% Alex Burky's seahorse map  original code
    % %% ___________________________________________________________________________ %%
    % p1 = slice(lon,lat,z,V,[],[],500);
    % set(p1,'EdgeColor','none')
    % grid on
    % xlim([min(lon) max(lon)])
    % ylim([min(lat) max(lat)])
    % zlim([499 501])
    % c = colorbar;
    % c.Label.String = '$\delta\mathrm{V}\hspace{-.25em}_{P}$ (\%)';
    % c.Label.Interpreter = 'latex';
    % c.TickLabelInterpreter = 'latex';
    % c.Label.FontSize = 11;
    % c.Location = 'southoutside';
    % set(c,'TickDir','out')
    % colormap(flipud(jet))
    % caxis([-2 2])
    % box on
    % view(0,90)
    % ax = gca;
    % ax.FontSize = 12;
    % ax.TickDir = 'out';
    % ax.ZDir = 'reverse';
    % ax.DataAspectRatio = [1 1 7];
    % ax.YTick = [-30 -20 -10 0];
    % ax.YTickLabel = {'-30$^{\circ}$','-20$^{\circ}$',...
    %                  '-10$^{\circ}$','0$^{\circ}$'};
    % ax.XTick = [180 190 200 210 220 230 240 250];
    % ax.XTickLabel = {'-180$^{\circ}$','-170$^{\circ}$','-160$^{\circ}$',...
    %                  '-150$^{\circ}$','-140$^{\circ}$','-130$^{\circ}$',...
    %                  '-120$^{\circ}$','-110$^{\circ}$'};
    % xlabel('Longitude')
    % ylabel('Latitude')
    % zlabel('Depth (km)')
    % set(gcf,'Position',[0 0 600 400]);
    % title(sprintf('LLNL South Pacific Slice: %i km',500))
    % latimes
    % %% ___________________________________________________________________________ %%

end
