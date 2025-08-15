function ax = figS1
% ax = FIGS1
%
% Figure S1: Record section, normed as in Figure 2, but spaced/timed relative to
% HTHH.
%
% Developed as: hunga_recordsection3.m, then figA1.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 15-Aug-2025, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

clc
close all

mermaid_only = false;

xl = [-75 60*4.5];
if mermaid_only
    yl = [5 70];

else
    yl = [5 90];

end
ampfac = 1/20;

c = 1480; % m/s
ph = c2ph(c, 'm/s');

prepost = [15 45];
lohi = [2.5 10];
popas = [4 1];

hundir = getenv('HUNGA');
sacdir = fullfile(hundir, 'sac');
sac = globglob(sacdir, '*.sac');

if ~mermaid_only
    imsdir = fullfile(sacdir, 'ims');
    imssac = globglob(imsdir, '*sac.pa');
    sac = [sac ; imssac];

end

evtdir = fullfile(hundir, 'evt');
evt = fullfile(evtdir, '11516993.evt');
evt = load(evt, '-mat');
EQ = evt.EQ;

sac = rmbadsac(sac);
sac = rmgapsac(sac);
sac = ordersac_geo(sac, 'gcarc');
sac = flipud(sac);

sigtype = catsac;

f = figure;
ax = axes;

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

    [xw30, W30, tt30] = hunga_timewindow(x, h, 5, 25, ph);

    % Cut small local events -- only from the part we'll use for noise, just
    % so normalization all the same
    cut_gap = readginput(sac{i});
    xcut = fillgap(x, cut_gap);
    noise = hunga_timewindow2(xcut, h, -20, -15, ph);

    x = x ./ rms(noise(isfinite(noise)));
    x = x - nanmean(x);

    xw30 = xw30 ./ rms(noise(isfinite(noise)));
    xw30 = xw30 - nanmean(xw30);

    seisdate = seistime(h);
    pt0 = seconds(seisdate.B - irisstr2date(EQ.PreferredTime));

    xax = xaxis(length(x), h.DELTA, pt0) / 60;
    xax30 = xax(W30.xlsamp:W30.xrsamp);

    x = x * ampfac;
    xw30 = xw30 * ampfac;

    [~, Color] = kstnmcat(h.KSTNM);

    [~, y] = grcdist([EQ.PreferredLongitude EQ.PreferredLatitude], [h.STLO h.STLA]);

    % %% The taper bugs FJS; todo, cut mins from start/end, but will require
    % custom for IMS vs MERMAID due to taper length being ratio of data length.
    % if ~strcmp(h.KSTNM(1), 'H')
    %     x(1:efes(h)*60*5) = NaN;
    %     x(end-efes(h)*60*5:end) = NaN;

    % else
    %     x(1:efes(h)*60*10) = NaN;
    %     x(end-efes(h)*60*10:end) = NaN;

    % end

    %% Figure 2 colors.
    % pl(i) = plot(ax, xax, x + y, 'Color', [0.6 0.6 0.6], 'LineWidth', 0.25);
    % pl30(i) = plot(ax, xax30, xw30 + y, 'Color', Color, 'LineWidth', 0.25);
    % tl(i) = text(0, y, h.KSTNM);

    %% MATLAB colors.
    pl(i) = plot(ax, xax, x + y, 'LineWidth', 0.25);
    tl(i) = text(0, y, h.KSTNM, 'Color', pl(i).Color);

    if ~strcmp(tl(i).String(1), 'H')
        tl(i).Position(1) = pl(i).XData(1);
        tl(i).HorizontalAlignment = 'right';
        %tl(i).HorizontalAlignment = 'right';
        %tl(i).Position(1) = xl(2);

    else
        tl(i).Position(1) = pl(i).XData(end);
        tl(i).HorizontalAlignment = 'left';
        %tl(i).HorizontalAlignment = 'left';
        %tl(i).Position(1) = xl(1);

    end

    if xax(1) < mn
        mn = xax(1);

    end
    if xax(end) > mx;
        mx = xax(end);

    end

end

tcP = taupCurve('ak135', EQ.PreferredDepth, 'P');
tcT = taupCurve('ak135', EQ.PreferredDepth, '1.5kmps');

plP = plot(ax, tcP.time/60, tcP.distance, 'k');
plT = plot(ax, tcT.time/60, tcT.distance, 'k');

txP = text(ax, 0, 0, '{\itP} Wave', 'Interpreter', 'tex', 'FontName', 'Times', ...
           'FontSize', 12, 'Rotation', 90);
txT= text(ax, 0, 0, '{\itT} Wave', 'Interpreter', 'tex', 'FontName', 'Times', ...
          'FontSize', 12, 'Rotation', 80);

if mermaid_only
    txP.Position = [5 57];
    txT.Position = [65 57];

else
    txP.Position = [1 72.5];
    txT.Position = [80.5 72.5];

end

hold(ax, 'off');
ax.Box = 'on';
grid(ax, 'on');
longticks(ax, 3);
latimes2
fig2print(f, 'tall')
axesfs([], 10, 10);

xlim(xl);
ylim(yl);

xticks([-60:60:270])

xlabel('Time Relative To Eruption [min]')
ylabel('Epicentral Distance')
set(ax, 'YTickLabels', degrees2(ax.YTick));

%% How to save labels; adjust manually, uncomment two lines below, save,
%% comment, load...
%%pos = gettxpos(tl);
%%save('static/figA1_pos.mat', 'pos')
load('static/figA1_pos.mat')
for i = 1:length(pos)
    tl(i).Position = pos(i,:);

end

% for i = 1:length(tl)
%     if any(strcmp(tl(i).String, {'H03N2', 'H03S1', 'H03S2', 'H03S3'}))
%         delete(tl(i))
%         continue

%     end
%     if any(strcmp(tl(i).String, {'H11N2', 'H11N3'}))
%         delete(tl(i))
%        continue

%     end
%     if any(strcmp(tl(i).String, {'H11S2', 'H11S3'}))
%         delete(tl(i))
%         continue

%     end
%     if strcmp(tl(i).String, 'H03N1')
%         tl(i).String = 'H03N1-H03N2, H03S1-H03S3';

%     end
%     if strcmp(tl(i).String, 'H11N1')
%         tl(i).String = 'H11N1-H11N3';

%     end
%     if strcmp(tl(i).String, 'H11S1')
%         tl(i).String = 'H11S1-H11S3';

%     end
% end

ax.XLabel.FontSize = 13;
ax.YLabel.FontSize = 13;
ax.XAxis.FontSize = 13;
ax.YAxis.FontSize = 13;
savepdf(mfilename)
