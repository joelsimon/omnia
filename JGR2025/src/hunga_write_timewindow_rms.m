function hunga_write_timewindow_rms
% HUNGA_WRITE_TIMEWINDOW_RMS
%
% Write signal ("30-minute T wave") and noise* (10 mins prior) RMS values.
%
% *as explained in paper, really, only Category C signals have noise in earlier
% window (the eruption was bubblin' for a while).
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 23-Jun-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

travtimeadj = false;

clc
close all

c = 1480; % m/s
p2t_m = -1350; % m
ph = c2ph(c, 'm/s');

hundir = getenv('HUNGA');
sacdir = fullfile(hundir, 'sac');
imsdir = fullfile(sacdir, 'ims');
imssac = globglob(imsdir, '*sac.pa');
staticdir = fullfile(hundir, 'code', 'static');

sac = globglob(sacdir, '*.sac');
imssac = ordersac_geo(imssac, 'gcarc');

sac = [sac ; imssac];

sac = rmbadsac(sac);
sac = rmgapsac(sac);

popas = [4 1];
lohi = [2.5 10];
env_len_secs = 30;
env_type = 'rms';

pre_mins_sig = -5;
post_mins_sig = +25;

pre_mins_noi = -15;
post_mins_noi = -5;

fmt = '%5s  |  %9.6f\n';
% fstr = sprintf('%s_pre-%imin_post-%imin_envlen-%is_envtype-%s_%.1f-%.1fHz', ...
%                mfilename, pre_mins_sig, post_mins_sig, env_len_secs, env_type, lohi(1), lohi(2));
fstr = 'rms';
fname_sig = fullfile(staticdir, [fstr '_signal.txt']);
fname_noi = fullfile(staticdir, [fstr '_noise.txt']);

writeaccess('unlock', fname_sig, false)
writeaccess('unlock', fname_noi, false)

fid_sig = fopen(fname_sig, 'w');
fid_noi = fopen(fname_noi, 'w');

for i = 1:length(sac)
    % Load and filter MERMAID and IMS traces.
    if startsWith(strippath(sac{i}), 'H11') || startsWith(strippath(sac{i}), 'H03')
        [foo, h] = readsac(sac{i});
        xb = bandpass(foo, efes(h), lohi(1), lohi(2), popas(1), popas(2));

    else
        [xb, h] = hunga_transfer_bandpass(sac{i}, lohi, popas);

    end
    kstnm = h.KSTNM;

    % Cut local events
    cut_gap = readginput(sac{i});
    xb = fillgap(xb, cut_gap, NaN, 0);

    %% Signal
    if ~travtimeadj
        [xbw_sig, W_sig, tt_sig] = ...
            hunga_timewindow2(xb, h, pre_mins_sig, post_mins_sig, ph);

    else
        [xbw_sig, W_sig, tt_sig] = ...
            hunga_timewindow2_travtimeadj(xb, h, pre_mins_sig, post_mins_sig, kstnm, c, p2t_m);

    end
    xaxw_mins_sig = (W_sig.xax - tt_sig.truearsecs) / 60;

    rms_val_sig = rms(xbw_sig(~isnan(xbw_sig)));
    fprintf(fid_sig, fmt, h.KSTNM, rms_val_sig);
    %% Signal

    %% Noise
    if ~travtimeadj
        [xbw_noi, W_noi, tt_noi] = ...
            hunga_timewindow2(xb, h, pre_mins_noi, post_mins_noi, ph);

    else
        [xbw_noi, W_noi, tt_noi] = ...
            hunga_timewindow2_travtimeadj(xb, h, pre_mins_noi, post_mins_noi, kstnm, c, p2t_m);
    end
    xaxw_mins_noi = (W_noi.xax - tt_noi.truearsecs) / 60;

    rms_val_noi = rms(xbw_noi(~isnan(xbw_noi)));
    fprintf(fid_noi, fmt, h.KSTNM, rms_val_noi);
    %% Noise

    % Cutout longer time segement around T wave, for plotting.
    if ~travtimeadj
        [xb0, W0, tt0] = hunga_timewindow2(xb, h, -15, 45, ph);

    else
        [xb0, W0, tt0] = hunga_timewindow2_travtimeadj(xb, h, -15, 45, kstnm, c, p2t_m);

    end
    xax0_mins = (W0.xax - tt0.truearsecs) / 60;

    % Plot both full segment and windowed segment relative to T-wave timing.
    figure
    ax = gca;
    plot(ax, xax0_mins, xb0, 'Color', [0.6 0.6 0.6], 'LineWidth', 1);
    hold(ax, 'on')
    plot(ax, xaxw_mins_sig, xbw_sig, 'Color', 'k', 'LineWidth', 2);
    symaxes(ax, 'y');

    ax.XLim = [-15 45];
    plot(ax, [0 0], ax.YLim, 'k--')
    plot(ax, ax.XLim, [-rms_val_sig -rms_val_sig], 'r')
    plot(ax, ax.XLim, [+rms_val_sig +rms_val_sig], 'r')
    xlabel(ax, 'Time (min)')
    ylabel(ax, 'Amplitude (Pa)')
    title(h.KSTNM)
    textpatch(ax, 'NorthEast', sprintf('RMS = %9.6f', rms_val_sig));
    latimes2
    longticks(ax, 2)
    savepdf(sprintf('%s_rms_sig.pdf', h.KSTNM));
    close

end
fclose(fid_sig);
fclose(fid_noi);

writeaccess('lock', fname_sig, false)
writeaccess('lock', fname_noi, false)

fprintf('Wrote: %s\n', fname_sig)
fprintf('Wrote: %s\n', fname_noi)
