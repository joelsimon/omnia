function figS3(ref_phase, lohi)
% FIGS3(ref_phase, lohi)
%
% Figure 3: Vespagram
%
% To generate figS3a: FIGS3('1.48kmps', [2.5 10])
% To generate figS3b: FIGS3('P', [1 2.5])
%
% Input:
% ref_phase   MatTaup reference phase (def: '1.48kmps')
% lohi        Bandpass corners (def: [2.5 10])
%
% Developed as: hunga_vespagram.m then fig3.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 03-Mar-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

clc
close all

cut_local_events = true;
longORshort = 'lengthen';

% Default reference phase, corner frequencies, and time window.
defval('ref_phase', '1.48kmps')
defval('lohi', [2.5 10])

test = false;
plt = false;
env = true;
env_len_secs = 30;
env_type = 'rms';

if test
    ref_phase = '1.48kmps';
    test_phase = '2kmps';

end

hundir = getenv('HUNGA');
sacdir = fullfile(hundir, 'sac');
evtdir = fullfile(getenv('HUNGA'), 'evt');
imsdir = fullfile(sacdir, 'ims');
imssac = globglob(imsdir, '*sac.pa');
staticdir = fullfile(hundir, 'code', 'static');

sac = globglob(sacdir, '*.sac');
imssac = ordersac_geo(imssac, 'gcarc');

% Let's actually just keep one station from each IMS triad (so that we don't
% stack small local events/overweight the IMS stations (really two, not 12 or
% whatever).
[~, imssac] = cellstrfind(imssac, {'H11S1' 'H03S1'});

sac = [sac ; imssac];
sac = rmbadsac(sac);
sac = rmgapsac(sac);

evtdir = fullfile(hundir, 'evt');
evt = fullfile(evtdir, '11516993.evt');
evt = load(evt, '-mat');
EQ = evt.EQ;
evt_date = irisstr2date(EQ.PreferredTime);
evt_dep = EQ.PreferredDepth;
evt_stla = EQ.PreferredLatitude;
evt_stlo = EQ.PreferredLongitude;

% Bandpass poles/passes.
popas = [4 1];

% This is the pre/post time I used in writeginput to cut local events; didn't
% look outside this time window; don't adjust here unless adjusted there.
ginput_prepost = [30 60];

% Read MERMAID data, remove instrument response, bandpass filter.
for i = 1:length(sac)
    % Read SAC file.
    [xf{i}, h(i)] = readsac_filter(sac{i}, lohi, popas);

    % Envelope waveforms.
    if env
        xf{i} = envelope(xf{i}, (env_len_secs * efes(h(i), true) + 1), env_type);

    end

    if cut_local_events
        % Cut small local events -- set gap to average of envelope pre/post 1 min of gap.
        cut_gap = readginput(sac{i});
        xf{i} = fillgap(xf{i}, cut_gap, -12345, 0, efes(h(i), true));

        % In writeginput.m I used 30/60 min pre/post; could set all values before/after
        % that to 0 so we compare equal-length segments in all (in some longer
        % segments there are large local events I didn't cut whose energy I don't
        % want bleeding in here).
        %[~, W] = hunga_timewindow(xf{i}, h(i), ginput_prepost(1), ginput_prepost(2));
        % xf{i}(1:W.xlsamp-1) = 0;
        % xf{i}(W.xrsamp+1:end) = 0;

    end

    % I figure it's okay to now downsample (as opposed to resample) to lower, common
    % frequency for correlation analysis becuase we've already computed the 30-s
    % long envelope on the properly bandpass trace above.
    [xf{i}, h(i)] = decimatesac(xf{i}, h(i), 10, false);
    fs(i) = efes(h(i), true);
    if iscolumn(xf{i})
        xf{i} = transpose(xf{i});

    end
    seisdate(i) = seistime(h(i));

    % Compute the theoertical travel time of the reference phase from event to
    % station.
    tt = taupTime('ak135', evt_dep, ref_phase, 'sta', [h(i).STLA h(i).STLO], ...
                  'evt', [evt_stla evt_stlo]);

    % Keep only first-arriving phase, in cases of multiple arrivals.
    tt = tt(1);

    % Keep track of observation distance for subsquent time shifts.
    obs_dist(i) = tt.distance;

    % Generate an x-xaxis which places the theoretical arrival time of the
    % reference phase at 0 s.
    arrival_date = evt_date + seconds(tt.time);
    arrival_secs = seconds(arrival_date - seisdate(i).B);
    arrival_samp = round(arrival_secs / h(i).DELTA) + 1;
    xax_ref{i} = xaxis(h(i).NPTS, h(i).DELTA, -arrival_secs);

    % Replace real trace, `xf`, with sythetic with two peaks; one at
    % `ref_phase` and a second at `test_phase`
    if test
        tt_test = taupTime('ak135', evt_dep, test_phase, 'sta', [h(i).STLA h(i).STLO], ...
                           'evt', [evt_stla evt_stlo]);
        tt_test = tt_test(1);
        arrival_date_test = evt_date + seconds(tt_test.time);
        arrival_secs_test = seconds(arrival_date_test - seisdate(i).B);
        arrival_samp_test = round(arrival_secs_test / h(i).DELTA) + 1;
        xf{i} = test_signal(xf{i}, arrival_samp, arrival_samp_test, 300, 'hann');

    end
end

% Plot all aligned on reference phase (sanity check).
figure
hold on
for i = 1:length(sac)
    plot(xax_ref{i}, 10*norm2max(xf{i}) + obs_dist(i));

end

% lengthen to plot P and 1.5 kmps on same vespagram.
% BUT, not all traces will have energy at all delays, e.g., maybe only two
% traces have T-wave +60 minutes, so you only end up summing 2 of 26 envelopes.
% shorten to highlight one phase and potentially chop others off.
% BUT, chopping XX mins after P wave may cut off T wave for distant stations.
switch longORshort
  case 'lengthen'
    minx = min(cellfun(@min, xax_ref));
    maxx = max(cellfun(@max, xax_ref));
    vertline([minx 0 maxx]);
    vertline(0);

    figure
    hold on
    xax_align = [minx:h(1).DELTA:maxx];
    for i = 1:length(sac)
        align_beg = zeros(1, round((xax_ref{i}(1) - minx) / h(i).DELTA));
        align_end = zeros(1, round((maxx - xax_ref{i}(end)) / h(i).DELTA));
        xf_align{i} = [align_beg xf{i} align_end];

        % Rounding may have extended/shrunk the aligned trace; cut/zero at end pad to
        % match `xax_align`
        if length(xf_align{i}) > length(xax_align)
            xf_align{i} = xf_align{i}(1:length(xax_align));

        elseif length(xf_align{i}) < length(xax_align)
            xf_align{i} = [xf_align{i} zeros(1, length(xax_align)-length(xf_align{i}))];;

        end
        plot(xax_align, 10*norm2max(xf_align{i}) + obs_dist(i));

    end

  case 'shorten'
    minx = max(cellfun(@min, xax_ref));
    maxx = min(cellfun(@max, xax_ref));
    vertline([minx 0 maxx]);
    vertline(0);

    figure
    hold on
    xax_align = [minx:h(1).DELTA:maxx];
    for i = 1:length(sac)
        cut_start = nearestidx(xax_ref{i}, minx);
        cut_end = nearestidx(xax_ref{i}, maxx);
        xf_align{i} = xf{i}(cut_start:cut_end);

        % Rounding may have extended/shrunk the aligned trace; cut/zero at end pad to
        % match `xax_align`
        if length(xf_align{i}) > length(xax_align)
            xf_align{i} = xf_align{i}(1:length(xax_align));

        elseif length(xf_align{i}) < length(xax_align)
            xf_align{i} = [xf_align{i} zeros(1, length(xax_align)-length(xf_align{i}))];;

        end
        plot(xax_align, 10*norm2max(xf_align{i}) + obs_dist(i));

    end

  otherwise
    error()

end
vertline(0);

% This num_zeros is just a wild guess (way too many) zeros to pad so that all
% shifts can be done; could be more clever by finding max shift and
% determining number of samples to pad...
num_zeros = 1e5;
for i = 1:length(sac)
    xf_pad{i} = [zeros(1, num_zeros) xf_align{i} zeros(1, num_zeros)];

end
pad_pt0 = xax_align(1) - (num_zeros*h(1).DELTA);
xax_pad = xaxis(length(xf_pad{1}), h(1).DELTA, pad_pt0);

figure
hold on
for i = 1:length(sac)
    plot(xax_pad, 10*norm2max(xf_pad{i}) + obs_dist(i));

end
vertline(0);

% Get reference distance (mean of array distance) and base reference beam
% length on maximum seismogram length with zero padding left and right
% (negative and positive).
ref_dist = mean(obs_dist);
ref_len = length(xf_pad{1});

% Delay and stack.
if test
    delP = [-18.533*2:18.533/2:18.533*2];  % 2 kmps test with 1.48 km/s reference phase

else
    switch ref_phase
      case 'P'
        delP = [-20:.1:100]; % 8.8 s/deg

      case {'1.48kmps' '1.5kmps'}
        delP = [-100:100]; % 75 s/deg at 1.48 km/s; 74.1 s/deg @ 1.5 km/s

      otherwise
        error('Rework for diff phases')

    end
end

stack = zeros(length(delP), ref_len);
xax_stack = xaxis(ref_len, h(1).DELTA, xax_align(1));
for j = 1:length(delP)
    if plt
        figure
        hold on
    end

    for i = 1:length(sac)
        % Sample shift due to slowness delta.
        del_dist = obs_dist(i) - ref_dist;      % [deg]
        time_shift = delP(j) * del_dist;        % [s/deg] * [deg] = [s]
        samp_shift = round(time_shift * fs(i)); % [s] * [samp/s] = [samp]

        % Pull the relevant part of the shift seismogram.
        xf_shift = xf_pad{i}(num_zeros+samp_shift:end);

        % Zero pad the seismogram on the right (end) to match reference length (so that
        % num indicies match for summing in main `stack` array)
        zero_pad = zeros(1, (ref_len-length(xf_shift)));
        xf_shift = [xf_shift  zero_pad];

        % M (rows) => slowness index (i.e., y-axis)
        % N (cols) => beam (shift + sum) at that slowness (i.e., time array, x-axis)
        stack(j, :) = stack(j, :) + xf_shift;

        if plt
            plot(xax_stack, 10*norm2max(xf_shift) + obs_dist(i));

       end
    end

    if plt
        xlim([xax_align(1) xax_align(end)])
        ylim([0 60]);
        horzline(ref_dist, [], 'black', 'LineStyle', '--');
        title(sprintf('$\\delta p = %.2f$ s/deg', delP(j)));
        if ~contains(ref_phase, 'kmps')
            xlabel(sprintf('Time relative to theoretical \\textit{%s}-phase arrival (s)', ref_phase))

        else
            vel = fx(strsplit(ref_phase, 'kmps'), 1);
            xlabel(sprintf('Time relative to theoretical %s km/s phase arrival (s)', vel))

        end
        ylabel('Epicentral distance (reference=dashed line)')
        box on
        longticks([], 2)
        latimes2
        savepdf(sprintf('vespa_%02i',j))
        close

    end
end

% Truncate stack for area of interest before normalizing.
xl = [];
yl = [];
% xl = [-15*60 45*60];
% yl = [-100 100];
%xl = [-5*60 15*60];
%yl = [-10 30];
if xl
    xl_idx = nearestidx(xax_stack, xl);
    stack(:, 1:xl_idx(1)-1) = NaN;
    stack(:, xl_idx(2)+1:end) = NaN;

end

if yl
    yl_idx = nearestidx(delP, yl);
    stack(1:yl_idx(1)-1, :) = NaN;
    stack(yl_idx(2)+1:end, :) = NaN;

end

% Normalize amplitudes.
stack = stack / maxmat(stack);

% From `>> help contour`
%
% "contour(Z) draws a contour plot of matrix Z in the x-y plane, with the
%  x-coordinates of the vertices corresponding to column indices of Z and the
%  y-coordinates corresponding to row indices of Z"
%
% From definition of `stack`, above --
%
% M (rows) => slowness index (i.e., y-axis)
% N (cols) => beam (shift + sum) at that slowness (i.e., time array, x-axis)
figure
cn = imagesc(xax_stack, delP, stack, 'AlphaData', ~isnan(stack));
%cn = contourf(xax_stack, delP, stack);
ax = gca;
ax.YDir = 'Normal';

%% Pull in Crameri's colormaps so that I can use crameri.m
cpath = fullfile(getenv('PROGRAMS'), 'crameri');
addpath(cpath);
colormap(crameri('-devon'))
rmpath(cpath);
%% Pull in Crameri's colormaps so that I can use crameri.m

xlim([xax_align(1) xax_align(end)])
ylim([delP(1) delP(end)])
cb = colorbar;
cb.TickDirection = 'out';
cb.Label.String = 'Normalized Envelope Amplitude';
cb.Label.FontName = 'Times';
cb.Label.Interpreter = 'TeX'
cb.Location = 'SouthOutside';

shg

% Compute x/y of other phases w.r.t to reference phase.
tt_ref = taupTime('ak135', 0, ref_phase, 'deg', ref_dist);
tt_ref = tt_ref(1);
p_ref = taup_rayParam2slowness(tt_ref.rayParam);

hold on
if test
    ph = {test_phase};

else
    % Thurin+2023.pdf for Love and Rayleigh speeds
    ph = {'P', 'S', '4.33kmps', '3.82kmps' '1.48kmps'};

end

for i = 1:length(ph)
    tt = taupTime('ak135', 0, ph{i}, 'deg', ref_dist);
    tt = tt(1);
    ph{i};
    p = taup_rayParam2slowness(tt.rayParam);

    % obs - ref; in this case 1.48 kmps is my reference
    xpos = tt.time - tt_ref.time;
    ypos = p - p_ref;
    plc(i) = plot(xpos, ypos, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 6);
    tlc(i) = text(xpos, ypos+3, strrep(ph{i}, 'kmps', ' km/s'), 'HorizontalAlignment', ...
                  'Center', 'Color', 'k');

end

if ~contains(ref_phase, 'kmps')
    xlabel(sprintf('Time relative to theoretical {\\it%s}-phase arrival (s)', ref_phase))
    title(sprintf('Reference: {\\itp} = %.1f s/deg ({\\it%s} phase) at %.1f deg', ...
                  p_ref, ref_phase, ref_dist));

else
    vel = fx(strsplit(ref_phase, 'kmps'), 1);
    xlabel('Seconds Relative to Theoretical {\itT}-Wave Arrival')
    title(sprintf('Reference: {\\itp} = %.1f s/deg (%s km/s phase) at %.1f deg', ...
                  p_ref, vel, ref_dist), 'FontWeight', 'Normal');

end


%% latimes
% if strcmp(contains, 'kmps')
%     xlabel(sprintf('Time relative to theoretical \\textit{%s}-phase arrival (s)', ref_phase))
%     title(sprintf('Reference: $p$ = %.1f s/deg (\\emph{%s} phase) at %.1f deg', ...
%                   p_ref, ref_phase, ref_dist));

% else
%     vel = fx(strsplit(ref_phase, 'kmps'), 1);
%     xlabel(sprintf('Time relative to theoretical %s km/s phase arrival (s)', vel))
%     title(sprintf('Reference: $p$ = %.1f s/deg (%s km/s phase) at %.1f deg', ...
%                   p_ref, vel, ref_dist));
%% latimes

ylabel('\delta Slowness [s/deg]')

% E.g., figS3B.
if strcmp(ref_phase, 'P')
    xlim([-5*60 15*60]);
    xticks([-5*60:5*60:15*60]);
    xticklabels({'-5' '0' '5' '10' '15'})
    ylim([-10 30])
    yticks([-10:10:30])
    yticklabels({'-10' '0' '10' '20' '30'})
    movev(tlc(2:end), -1)
    ax.XLabel.String = 'Time Relative To Predicted {\itP}-Wave Arrival [min]';
    ax.YLabel.String = 'Slowness Relative To Predicted {\itP}-Wave [s/deg]';
    ax.YLabel.Position(1) = -405;
    plot([0 0], [-10 -1.5], 'k')
    plot([0 0], [1.5 30], 'k')
    plot([-5*60 -2/3*60], [0 0], 'k')
    plot([2/3*60 15*60], [0 0], 'k')
    text(20, 2, '{\itP}', 'Color', 'k')
    text(11*60, -8, sprintf('%.1f - %.1f Hz', lohi(1), lohi(2)), 'Color', 'k')
    set(plc, 'Marker', '+')
    delete(ax.Title)
    delete([tlc(1) plc(1)])
    clim([0.2 1])
    lbl = text(-14/3*60, 28, 'B', 'FontName', 'Helvetica', 'FontWeight',  'Bold', 'Color', 'k');
    % % This is how you'd bracket colors to just within a window around P wave;
    % % need to have xl and yl set above.
    % clim([maxmat(stack, 'min') 1])

end

% E.g., figS3A
if strcmp(ref_phase, '1.48kmps')
    xlim([-60*15 60*45])
    xticks([-60*15:60*5:60*45])
    ylim([-100 100])
    yticks([-100:50:100]);
    xticklabels({'-15' '' '' '0' '' '' '15' '' '' '30' '' '' '45'})
    ax.XLabel.String = 'Time Relative To Predicted {\itT}-Wave Arrival [min]';
    ax.YLabel.String = 'Slowness Relative To Predicted {\itT}-Wave [s/deg]';
    delete([tlc plc])
    hold(ax, 'on');
    plot([0 0], [-100 -5], 'k')
    plot([0 0], [5 100], 'k')
    plot([-15*60 -2*60], [0 0], 'k')
    plot([2*60 45*60], [0 0], 'k')
    text(-200, 12.5, '{\itT}', 'Color', 'k')
    text(33*60, -90, sprintf('%.1f - %.1f Hz', lohi(1), lohi(2)), 'Color', 'k')
    delete(ax.Title)
    clim([0.2 1])
    lbl = text(-14*60, 90, 'A', 'FontName', 'Helvetica', 'FontWeight',  'Bold', 'Color', 'k');

end
axesfs([], 15, 15)
cb.FontSize = 15;
longticks([], 2);
latimes2
shrink([], 1, .9)
movev(cb, -.01)

if exist('lbl')
    lbl.FontName = 'Helvetica';

end

% %% Pull in Crameri's colormaps so that I can use crameri.m
% cpath = fullfile(getenv('PROGRAMS'), 'crameri');
% addpath(cpath);
% cycle_crameri(ax);
% cmap2 = crameri(cmap2);
% %% Pull in Crameri's colormaps so that I can use crameri.m

keyboard
%% End main.

%% ___________________________________________________________________________ %%
function [xb, h] = readsac_filter(s, lohi, popas)

if startsWith(strippath(s), 'H11') || startsWith(strippath(s), 'H03')
    [foo, h] = readsac(s);
    xb = bandpass(foo, efes(h), lohi(1), lohi(2), popas(1), popas(2));

else
    [xb, h] = hunga_transfer_bandpass(s, lohi, popas);

end


%% ___________________________________________________________________________ %%
function sac = rm_no_pwave_sac(sac, evtdir);

rm_idx = [];
for i = 1:length(sac)
    EQ = getrevevt(sac{i}, evtdir);
    if isempty(cellstrfind({EQ.TaupTimes.phaseName}, 'P'))
        rm_idx = [rm_idx ; i];

    end
    if isempty(cellstrfind({EQ.TaupTimes.phaseName}, '1.5kmps'))
        rm_idx = [rm_idx ; i];

    end
end
sac(rm_idx) = [];


%% ___________________________________________________________________________ %%
function p = kmps2p(kmps)
% Convert 'kmps' phase to slowness
% DOES NOT WORK FOR BODY WAVE (body-wave slowness varies with distance)

p = 1 / (kmps * km2deg(1));

%% ___________________________________________________________________________ %%
function xf = test_signal(xf, samp1, samp2, sig_len, sig_type)
% samp1 => index of primary pulse
% samp2 => index of secondary pulse

defval('sig_type', 'hann')
defval('sig_len', 150);

switch lower(sig_type)
  case 'boxcar'
    sig1 = ones(1, sig_len*20 + 1);

  case 'hann'
    sig1 = hanning(sig_len*20 + 1);

  otherwise
    error('please specify one of allowed signal types')

end
half_len = (length(sig1)-1)/2;

xf1 = zeros(size(xf));
xf2 = zeros(size(xf));

sig1_idx = [samp1-half_len:samp1+half_len];
sig1_start = 1;
sig1_end = length(sig1_idx);
if sig1_idx(1) < 1
    sig1_start = length(sig1_idx(1):1);
    sig1_idx = [1:sig1_idx(end)];

end
if sig1_idx(end) > length(xf2)
    sig1_idx = [sig1_idx(1):length(xf2)];
    sig1_end = length(sig1_idx);

end

sig2_idx = [samp2-half_len:samp2+half_len];
sig2_start = 1;
sig2_end = length(sig2_idx);
if sig2_idx(1) < 1
    sig2_start = length(sig2_idx(1):1);
    sig2_idx = [1:sig2_idx(end)];

end
if sig2_idx(end) > length(xf2)
    sig2_idx = [sig2_idx(1):length(xf2)];
    sig2_end = length(sig2_idx);

end

xf1(sig1_idx) = 1.0*sig1(sig1_start:sig1_end);;
xf2(sig2_idx) = 0.5*sig1(sig2_start:sig2_end);

xf = xf1 + xf2;
