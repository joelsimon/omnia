function [ax, f] = fig3_4l_S4(sac)
% [ax, f] = FIG3_4l_S4(sac)
%
% Figures (or parts of): 3, 4 (left column), S4, S10--S44.
%
% Pretty func name, huh?
%
% Generically plots 4 panels: time domain, spectral domain, bathymetric cross
% section, Fresnel-zone bathymetry map view.
%
% See internal instructions to generate specific figures/parts.
%
% Developed as: hunga_timspecprofbath2.m then fig4_5_A2.m
%
% Author: Joel D. Simon <jdsimon@bathymetrix.com>
% Last modified: 27-Jan-2026, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

% Figures 3 and 4: set timspec_only to true
% Figure 3: additional annotation added in post
% Figure 4, S4: uncomment "For small font P0045 --> ... <--- For small font P0045" block
% For Figures S10--44: set timspec_only to false and comment these individual `sac` files
sac = '20220115T034444.0045_62AAD314.MER.REQ.merged.sac';
%sac = '20220115T040400.0053_630C0CF0.MER.REQ.merged.sac'; % color = [0 .33  1]
%sac = 'H03S1.EDH.202201150400_4hr.sac.pa'; % color = [0 .67  1]
%sac = 'H11S1.EDH.202201150300_5hr.sac.pa'; % color = [0 1 1]
%sac = '20220115T040540.0026_631CC068.MER.REQ.merged.sac';
%sac = '20220115T034444.0049_62AD8DA4.MER.REQ.merged.sac';

clc
timspec_only = true;

% Defaults.
prepost = [-15 45]; % minutes
p2t_m = -1350; % p-to-t conversion depther, meters (elevation)
tz_m = -1350; % test elevation, meters
tz_km = tz_m/1e3;

freq = 2.5; % Hz, for Fresnel width
plt_env = false;
travtimeadj = false;
c = 1480; % m/s
ph = c2ph(c, 'm/s');
lohi = [5 10];
popas = [4 1];
cn_lw = 0.5;

sac = hunga_fullsac(sac);
h = sachdr(sac);
kstnm = h.KSTNM;
stdp = h.STDP;

equaleyes = false;

% Vertical exaggeration.
ve = 300;

%% Pull in Crameri's colormaps so that I can use crameri.m
cmap1 = '-managua';
cmap2 = 'acton';
cpath = fullfile(getenv('PROGRAMS'), 'crameri');
addpath(cpath);
%cmap2 = crameri(cmap2);
%% Pull in Crameri's colormaps so that I can use crameri.m

[~, ax] = krijetem(subnum(3, 1));
f = gcf;
f.InnerPosition(4) = f.InnerPosition(3);
shrink(ax, 1.1, 2);

if ~isimssac(sac)
    [x_filtered, h_filtered] = hunga_transfer_bandpass(sac, lohi, popas);
    [x_unfiltered, h_unfiltered] = hunga_transfer_bandpass(sac, NaN);
    if length(x_filtered) ~= length(x_unfiltered) || ~isequaln(h_filtered, h_unfiltered)
        keyboard
        error()

    else
        h = h_filtered; % or, equally, `h = h_unfiltered`

    end
else
    [x_unfiltered, h] = readsac(sac);
    x_filtered = bandpass(x_unfiltered, efes(h), lohi(1), lohi(2), popas(1), popas(2));

end

% Cut small local events.
cut_gap = readginput(sac);
x_filtered = fillgap(x_filtered, cut_gap, NaN);
x_unfiltered = fillgap(x_unfiltered, cut_gap, NaN);

% Window will be the same for both traces; unfiltered required for spectrogram
if travtimeadj
    [xw_filtered, W, tt, EQ] = ...
        hunga_timewindow2_travtimeadj(x_filtered, h, prepost(1), prepost(2), kstnm, c, p2t_m);
    [xw30, W30, tt30] = ...
        hunga_timewindow2_travtimeadj(x_filtered, h, -5, +25, kstnm, c, p2t_m);
    xw_unfiltered = ...
        hunga_timewindow2_travtimeadj(x_unfiltered, h, prepost(1), prepost(2), kstnm, c, p2t_m);

else
    [xw_filtered, W, tt, EQ] = hunga_timewindow(x_filtered, h, abs(prepost(1)), prepost(2), ph);
    [xw30, W30, tt30] = hunga_timewindow(x_filtered, h, 5, 25, ph);
    xw_unfiltered = hunga_timewindow(x_unfiltered, h, abs(prepost(1)), prepost(2), ph);

end

%% ___________________________________________________________________________ %%
%% PLOT 1: FILTERED TRACE
%% ___________________________________________________________________________ %%
% Generate X-xaxis with theoretical T-wave arrival at 0 seconds.
xax_t0_secs = W.xax - tt.truearsecs;
xax_t0_mins = xax_t0_secs / 60;

xax30_t0_secs = W30.xax - tt30.truearsecs;
xax30_t0_mins = xax30_t0_secs / 60;

sigtype = catsac;
if strcmp(sigtype.(kstnm), 'A')
    Color = 'blue';

elseif strcmp(sigtype.(kstnm), 'B')
    Color = 'black';

elseif strcmp(sigtype.(kstnm), 'C')
    Color = [0.6 0.6 0.6];

else
    error('unexpected signal type')

end

% Plot filtered trace.
hold(ax(1), 'on')
pl_full = plot(ax(1), xax_t0_mins, xw_filtered, 'Color', [0.6 0.6 0.6]);
pl_30 = plot(ax(1), xax30_t0_mins, xw30, 'Color', Color);
hold(ax(1), 'off')

if strcmp(kstnm, 'P0045')
    % Export an audio file for an animation -- set for 30 sec animation
    audiowrite('P0045.wav', norm2max(xw_filtered), round(length(xw_filtered)/30))

end


if plt_env
    env_len_secs = 30;
    env_type = 'rms';
    foo = xw_filtered;
    foo(~isfinite(foo)) = 0;
    xw_env = envelope(foo, (env_len_secs * efes(h, true) + 1), env_type);
    xw_env(xw_env == 0) = NaN;
    xw_env = norm2ab(xw_env, 0, max(xw_filtered));
    hold(ax(1), 'on')
    pl_30 = plot(ax(1), xax_t0_mins, xw_env, 'k', 'LineWidth', 1.5);
    hold(ax(1), 'off')

end

if ~any(isnan(prepost))
    ax(1).XLim = [prepost(1) prepost(2)];

else
    ax(1).XLim = [xax_t0_mins(1) xax_t0_mins(end)];

end
ax(1).XTick = [-15:5:45];

if equaleyes
    ax(1).YLim = [-2.5 2.5];

else
    xw_max = max(abs(xw_filtered));
    ax(1).YLim = [-1.2*xw_max 1.2*xw_max];

end
ax(1).XTickLabel = [];
ylabel(ax(1),  'Pa');

% Vertlical line at zero.
hold(ax(1), 'on')
plot(ax(1), [0 0], ax(1).YLim, 'k-', 'LineWidth', 1);
hold(ax(1), 'off')

%% ___________________________________________________________________________ %%
%% PLOT 2: SPECTGORAM
%% ___________________________________________________________________________ %%
% Lower limit of Y-axis on spectrogram; set higher than 0 to clip persistent and
% loud lower frequency sound in ocean.
spec_lowerlim = 2.5;
spec_upperlim = 10;

% Window length and number of FFT points
fs = efes(h);
wlen = 6*fs;
wolap = 0.7;
nfft = wlen;

[~, spec_freqs, ~, spec_energy] = spectrogram2(xw_unfiltered, nfft, fs, wlen, ceil(wolap*wlen), 's');
spec_pt0 = wlen / fs / 2;
spec_xax_t0_mins = (xax_t0_secs + spec_pt0) / 60;

% Winnow spectral energy matrix to only contain data at frequencies equal to and
% above the requested lower limit. This is so that we can control the color
% limit of the axes.  Note that pl(2).CData does NOT change even with the axis
% adjusted, so if we want to control color based on some metric of what is
% actually plotted we need to only plot the relevant spectrum.
spec_loweridx = nearestidx(spec_freqs, spec_lowerlim);
if spec_freqs(spec_loweridx) > spec_lowerlim
    spec_loweridx = spec_loweridx - 1;

end
spec_upperidx = nearestidx(spec_freqs, spec_upperlim);
if spec_freqs(spec_upperidx) > spec_upperlim
    spec_upperidx = spec_upperidx + 1;

end
spec_cutfreqs = spec_freqs(spec_loweridx:spec_upperidx);
spec_cutenergy = spec_energy(spec_loweridx:spec_upperidx, :);

% Remove mean from spctrum and normalize by std.
% ms = nanmean(spec_cutenergy(:));
% ss = nanstd(spec_cutenergy(:));

fin_spec = spec_cutenergy(isfinite(spec_cutenergy));
ms = mean(fin_spec);
ss = std(fin_spec);
spec_cutenergy = spec_cutenergy - ms;
spec_cutenergy = spec_cutenergy ./ ss;
spec_cutenergy(~isfinite(spec_cutenergy)) = NaN;

% Set all beyond energy +/-2 std to +/-2std
min_std = -2;
max_std = +2;
spec_cutenergy(spec_cutenergy < min_std) = min_std;
spec_cutenergy(spec_cutenergy > max_std) = max_std;

axes(ax(2))
pl(2) = imagesc(ax(2), spec_xax_t0_mins, spec_cutfreqs, spec_cutenergy, 'AlphaData', ~isnan(spec_cutenergy));
axis xy
ax(2).XLim = ax(1).XLim;
ax(2).XTick = ax(1).XTick;
xticklabels(ax(2), {'-15' '' '' '0' '' '' '15' '' '' '30'  '' '' '45'})

ax(2).YLim = [spec_lowerlim spec_upperlim];
ax(2).YTick = [spec_lowerlim:2.5:spec_upperlim];
colormap(crameri(cmap1));

pos = axpos(ax(2));
cbpos = [pos.lr(1)+0.0125 pos.lr(2) 0.025 pos.ur(2)-pos.lr(2)];
cb2 = colorbar('Position', cbpos);

set(cb2, 'TickDirection', 'out', 'TickLength', 0.05);
if timspec_only
    set(cb2.Label, 'FontName', 'Times', 'String', 'Standard Deviation From Mean [dB Pa^2/Hz]', 'Interpreter', 'tex');

else
    set(cb2.Label, 'FontName', 'Times', 'String', 'Std. From Mean [dB Pa^2/Hz]', 'Interpreter', 'tex');

end


xlabel(ax(2), 'Time Relative To Predicted {\it{T}}-Wave Arrival [min]');
ylabel(ax(2), 'Hz')

hold(ax(2), 'on')
plot(ax(2), [0 0], ax(2).YLim, 'k-', 'LineWidth', 1);
hold(ax(2), 'off')

%% ___________________________________________________________________________ %%
%% PLOT 3: BATHYMETRIC PROFILE (CROSS SECTION)
%% ___________________________________________________________________________ %%
axes(ax(3))
hold(ax(3), 'on')

% Get max(3) distance MERMAID for aspect ratio.
% Technically H03N3 is more distant (barely) than H03N1, but we don't keep
max_dist_kstnm = 'H03N1';
gc = hunga_read_great_circle_gebco;
max_dist_km = gc.(max_dist_kstnm).tot_distkm(end);
gc = gc.(kstnm);

% Get Fresnel zone lat/lon, depth, and cumulative distance
fg = hunga_read_fresnelgrid_gebco(kstnm, freq);

% Along each Fresnel-radii compute the min/max elevation to bracket GEBCO
% great-circle elevation track.  Take min/max along rows of Fresnel-zone
% elevation matrix (each lat/lon point).
min_bathy_km = min(fg.depth_m, [], 2) / 1e3;
gc_bathy_km = fg.depth_m(:, fg.gcidx) /1e3;
max_bathy_km = max(fg.depth_m, [], 2) / 1e3;
dist_km = fg.gcdist_m / 1e3;

hold(ax(3), 'on')
pp = patch(ax(3), [dist_km ; flip(dist_km)], [min_bathy_km ; flip(max_bathy_km)], [0.6 0.6 0.6]);
pp.EdgeColor = 'none';
pp.LineWidth = 0.25;
plot(ax(3), dist_km, gc_bathy_km, '-', 'Color', 'r', 'LineWidth', 1);
pltz = plot(ax(3), ax(3).XLim, [tz_km tz_km], 'k');

ax(3).XLim = [0 max_dist_km(end)];
ax(3).YLim = [-6 0.5];
ylabel('Elevation [km]')
ax(3).XTickLabel = [];

% Adjust vertical exaggeration, holding width constant.
vertexag(ax(3), ve, 'height');
%ve_tx = text(ax(3), 50, -5.5, sprintf('%ix Vertical Exaggeration', ve));
uistack(pltz, 'bottom');
hold(ax(3), 'off')

%% ___________________________________________________________________________ %%
%% PLOT 4: BATHYMETRIC MAP (COLOR)
%% ___________________________________________________________________________ %%
%% Axes 4: Fresnel-grid bathymetric map view
ax(4) = axes('Position', ax(3).Position, 'Box', 'on')
hold(ax(4), 'on')

%% Figure max fresnel-radii and great-circle distance width to set up max x/ylim.
max_dist_kstnm = 'H03N1';
max_fg = hunga_read_fresnelgrid_gebco(max_dist_kstnm, freq);
[max_im_xlim, max_im_ylim] = get_fresnel_xylim(max_fg);

% Image x/y specify pixel centers...so there is some overrun (numCols+0.5;
% numRows+0.5) where the pixel edges actually lie -- so round up/down the
% max_ylim so the Fresnel zones of the most distant stations aren't truncated
% top/bottom.
max_im_ylim(1) = floor(max_im_ylim(1));
max_im_ylim(2) = ceil(max_im_ylim(2));

%% Figure max fresnel-radii width to set up max x/ylim.
fg = hunga_read_fresnelgrid_gebco(kstnm, freq);
[im_xlim, im_ylim] = get_fresnel_xylim(fg);

% Chop off first/last handful of pixels at source/receiver of bathymetric image
% so that image doesn't override edge of axes and make line seem thinner; don't
% have to worry about y axis because can just expand limits beyond max Fresnel
% zone (don't want to extend x limits, though).
im_xl = dist_km;
im_yl = linspace(-max(fg.radius_m)/1e3, max(fg.radius_m)/1e3, size(fg.depth_m,2));
im_xl(1:10) = [];
im_xl(end-10:end) = [];
bathy = fg.depth_m';
bathy(:, 1:10) = [];
bathy(:, end-10:end) = [];

% Make image, overlay contour.
im = imagesc(ax(4), im_xl, im_yl, bathy/1e3, 'AlphaData', ~isnan(bathy));
[cn_x, cn_y] = im2mesh(im);
[~, cn] = contour(ax(4), cn_x, cn_y, bathy, [tz_m tz_m]);
cn.EdgeColor = 'g';
cn.LineWidth = cn_lw;

ax(4).XLim = max_im_xlim;
ax(4).YLim = max_im_ylim;
numticks(ax(4), 'y', 5)
yticklabels(ax(4), abs(yticks))
ylabel(ax(4), 'Fresnel Radius [km]')
xlabel(ax(4), 'Epicentral Distance [km]')

cax = [-6 0];
pos = axpos(ax(4));
cb4pos = [pos.lr(1)+0.0125 pos.lr(2) 0.025 pos.ur(2)-pos.lr(2)];
cb4 = colorbar(ax(4), 'Position', cb4pos);
cb4.Ticks = [-6:2:-2 tz_km 0];

caxis(ax(4), cax);
cb4.Label.String = 'Elevation [km]';
set(cb4, 'TickDirection', 'out', 'TickLength', 0.05);
cb4.Label.Interpreter = 'tex';
cb4.Label.FontName = 'times';

colormap(ax(4), crameri(cmap2))
%colormap(ax(4), crameri(cmap2, 'pivot', tz_km));

%% ___________________________________________________________________________ %%
%% COSMETICS
%% ___________________________________________________________________________ %%
ax(3).XTickLabels = [];

% Rejigger axes
ax(1).Position(4) = ax(3).Position(4);
ax(2).Position(4) = ax(3).Position(4);

% Colorbar for axes 2.
cb2.Position(4) = ax(4).Position(4);

% After moving (expanding vertically) colorbar the labels opened up; more
% ticks but hardcoded labels. Must redo.
cb2.TickLabels = num2cell(cb2.Ticks);
cb2.TickLabels{1} = sprintf('<%s', cb2.TickLabels{1});
cb2.TickLabels{end} = sprintf('>+%s', cb2.TickLabels{end});

% Station name
yval = 0.9*max(ax(1).YLim);
tx_kstnm = text(ax(1), -14.5, +0.65*yval, kstnm, ...
                'HorizontalAlignment', 'Left', 'VerticalAlignment', 'Bottom');

% Station depth
%% MASK H03
if startsWith(kstnm, 'H03')
    stdp = 800;

end
tx_stdp = text(ax(1), -14.5, -yval, sprintf('STDP = %i m', stdp), ...
               'HorizontalAlignment', 'Left', 'VerticalAlignment', 'Bottom');

% Epicentral distance in degrees
tx_dist = text(ax(1), 44.5, +0.65*yval, sprintf('DIST = %.1f^%s', tt.distance, '\circ'), ...
               'HorizontalAlignment', 'Right', 'VerticalAlignment', 'Bottom');

% Azitmuth in degrees
%% MASH H03
if startsWith(kstnm, 'H03')
    az = 124;

else
    az = azimuth(EQ.PreferredLatitude, EQ.PreferredLongitude, h.STLA, h.STLO);

end
tx_az = text(ax(1), 44.5, -yval, sprintf('AZ = %.1f^%s', az, '\circ'), ...
              'HorizontalAlignment', 'Right', 'VerticalAlignment', 'Bottom');

movev([ax(2) cb2], 0.13)
cb2.XTick = [-2 0 2];
cb2.TickLabels = {'<-2' '0' '>+2'};
movev(ax(3), .185);
movev([ax(4) cb4], .015)

box(ax, 'on')
longticks(ax, 2);
latimes2
axesfs([], 12, 12);
ax(1).YLabel.Position(1) = ax(2).YLabel.Position(1);

if timspec_only
    if strcmp(kstnm, 'P0053')
        pl_30.Color = [0 0.33 1];

    end
    if strcmp(kstnm, 'H03S1')
        pl_30.Color = [0 0.67 1];

    end
    if strcmp(kstnm, 'H11S1')
        pl_30.Color = [0 1 1];

    end

    delete([ax(3)  ax(4) cb4])
    cb2.Location = 'SouthOutside';
    ax(2).Position(3) = ax(1).Position(3);
    ax(2).Position(4) = ax(1).Position(4);
    movev(cb2, -0.01);
    cb2.XTick = [-2:2];
    cb2.TickLabels = {'<-2' '-1' '0' '+1' '>+2'};
    cb2.TickLength = 0.01;
    cb2.FontSize = 12;

    % %% For small font P0045 --> (comment block to kill gray annotation)
    % % Thurin+2023 "best set of force paramters" (Table 4) subevent timing in
    % % minutes relative to USGS 2022-01-15 04:14:45 UTC (0 time here is T-wave
    % % arrival time, so it's the same as saying 0 is HTHH origin time)
    % s1_4 = [50.85 256.09 293.51 321.1] ./ 60;
    % hold(ax([1 2]), 'on')
    % for i = 1:length(s1_4);
    %     ps = plot(ax(1), [s1_4(i) s1_4(i)], ax(1).YLim, '-', 'Color', [0.6 0.6 0.6], 'LineWidth', 1);

    % end
    % hold(ax([1 2]), 'off')
    % ts1 = text(ax(1), s1_4(1)+0.25, -2.5, 'S1', 'Color', [0.6 0.6 0.6]);
    % ts2_4 = text(ax(1), s1_4(4)+0.25, -2.5, 'S2 - S4 (Thurin & Tape, 2023)', 'Color', [0.6 0.6 0.6]);
    % %% <<-- For small font P0045 (comment block to kill gray annotation)

    latimes2

    shrink(ax(1:2), 1,1.5)
    movev(ax(2), .05);
    movev(cb2, .09)
    axesfs([], 8, 8);
    % ts1.FontSize = 5;
    % ts2_4.FontSize = 5;
    cb2.FontSize = 8;
    ax(1).YLabel.Position(1) = ax(2).YLabel.Position(1);
    %% For glide rectangle
    %rec = rectangle(ax(2), 'Position', [-6 2 3 9], 'LineWidth', 1, 'EdgeColor', 'black');
    %% For glide rectangle
    savepdf('timspecP0045_smallfont.pdf');

    delete(ax(1))
    %% For glide rectangle
    %delete(rec)
    %% For glide rectangle

    xlim(ax(2), [-6 0]);
    xticks(ax(2), [-6:0]);
    xticklabels({'-6' '-5' '-4' '-3' '-2' '-1' '0'});

    %% travtimeadj
    % xlim(ax(2), [-5 0]);
    % xticks(ax(2), [-5:0]);
    % xticklabels({'-5' '-4' '-3' '-2' '-1' '0'});
    %% travtimeadj

    axesfs([], 15, 15)
    cb2.FontSize = 15
    shrink(ax(2), 1, 1/2)
    movev(cb2, -0.075);
    savepdf('glide')

    %% <--- For small font P0045
end

% Remove external path to Crameri's colormaps
rmpath(cpath);

%% ___________________________________________________________________________ %%
% Subfuncs
function [xl, yl] = get_fresnel_xylim(fg)
% X/YLims in km

xl = [0 fg.gcdist_m(end)/1000];
yl = [-max(fg.radius_m)/1000 +max(fg.radius_m)/1000];
