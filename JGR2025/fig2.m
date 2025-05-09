function ax = fig2(travtimeadj)
% ax = FIG2(travtimeadj)
%
% Figure 2: Record section, equally spaced, individually normed, aligned on T wave.
%
% Developed as: hunga_recordsection2.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 05-Dec-2024, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

clc
close all

defval('travtimeadj', false)

c = 1480; % km/s
ph = c2ph(c, 'm/s');
p2t_m = -1350; % p-t conversion elevation (on slope)

prepost = [15 45];
lohi = [2.5 10];
popas = [4 1];

hundir = getenv('HUNGA');
sacdir = fullfile(hundir, 'sac');
sac = globglob(sacdir, '*.sac');

evtdir = fullfile(hundir, 'evt');
evt = fullfile(evtdir, '11516993.evt');
evt = load(evt, '-mat');
EQ = evt.EQ;

imsdir = fullfile(sacdir, 'ims');
imssac = globglob(imsdir, '*sac.pa');
sac = [sac ; imssac];

sac = rmbadsac(sac);
sac = rmgapsac(sac);
sac = ordersac_geo(sac, 'gcarc');
sac = flipud(sac);

sigtype = catsac;

f = figure;
ax = axes;

y = 0;
mn = 0;
mx = 0;
hold(ax, 'on');
for i = 1:length(sac)
   if ~isimssac(sac{i})
        [x, h] = hunga_transfer_bandpass(sac{i}, lohi, popas);

    else
        [x, h] = readsac(sac{i});
        if ~isnan(lohi)
            x = bandpass(x, efes(h), lohi(1), lohi(2), popas(1), popas(2));

        end
    end

    % Cut small local events.
    cut_gap = readginput(sac{i});
    x = fillgap(x, cut_gap);

    if travtimeadj
        [xw, W, tt] = hunga_timewindow2_travtimeadj(x, h, -prepost(1), +prepost(2), h.KSTNM, c, p2t_m);
        [xw30, W30, tt30] = hunga_timewindow2_travtimeadj(x, h, -5, +25, h.KSTNM, c, p2t_m);
        noise = hunga_timewindow2_travtimeadj(x, h, -20, -15, h.KSTNM, c, p2t_m);
        % xlab = sprintf('Minutes Relative To Adjusted %s Phase Arrival', ...
        %                 strrep(ph, 'kmps', ' km/s'));

    else
        [xw, W, tt] = hunga_timewindow(x, h, prepost(1), prepost(2), ph);
        [xw30, W30, tt30] = hunga_timewindow(x, h, 5, 25, ph);
        noise = hunga_timewindow2(x, h, -20, -15, ph);
        % xlab = sprintf('Minutes Relative To %s Phase Arrival', ...
        %                 strrep(ph, 'kmps', ' km/s'));

    end
    xlab = 'Time Relative To Predicted {\it{T}}-Wave Arrival [min]';
    
    xw = xw ./ rms(noise(isfinite(noise)));
    xw = xw - nanmean(xw);

    xw30 = xw30 ./ rms(noise(isfinite(noise)));
    xw30 = xw30 - nanmean(xw30);

    xax = (W.xax - tt.truearsecs) / 60;
    xax30 = (W30.xax - tt30.truearsecs) / 60;

    [~, Color] = kstnmcat(h.KSTNM);

    pl(i) = plot(ax, xax, xw + y, 'Color', [0.6 0.6 0.6], 'LineWidth', 0.25);
    pl30(i) = plot(ax, xax30, xw30 + y, 'Color', Color, 'LineWidth', 0.25);
    tl(i) = text(xax(end), xw(end) + y, h.KSTNM);

    if xax(1) < mn
        mn = xax(1);

    end
    if xax(end) > mx;
        mx = xax(end);

    end
    y = y + 30; % 2.5-10 Hz

end
vl = plot(ax, [0 0], ax.YLim, 'Color', 'k');
uistack(vl, 'bottom')

xlabel(xlab)

hold(ax, 'off');
ax.Box = 'on';
longticks(ax, 3);
grid on
ax.YTick = [];
ax.XLim = [-prepost(1) prepost(2)];
xticks([-30:5:60])
ylim([-40 1060])
latimes2

for i = 1:length(tl)
    % Name MERMAID stations at left, IMS at right
    if ~strcmp(tl(i).String(1), 'H')
        tl(i).Position(1) = -prepost(1)-0.005*(sum(prepost));
        tl(i).HorizontalAlignment = 'right';

    else
        tl(i).Position(1) = +prepost(2)+0.005*(sum(prepost));
        tl(i).HorizontalAlignment = 'left';

    end
end
axesfs([], 8, 8)
savepdf(mfilename)
