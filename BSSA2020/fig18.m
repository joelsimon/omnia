% Figure 18
%
% Cite: Simon, J. D. et al., (2020), BSSA, doi: 10.1785/0120190173
%
% Travel time histograms, broken down per resolution, of the complete
% data set analyzed.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 31-Mar-2019, Version 2017b

% TRESHIST_MERAZUR.m
%
% Histograms of travel time residuals, assuming the true phase against
% which to measure the residual is that which has the minimum travel
% time residual compared to the changepoint arrival-time estimate.
%
% Loads file written with compile_merazur.m

clear
close all

% Text and axes fontsize.
axfs = 8;
txfs = 9;

% Written with compile_merzur.m
load(fullfile(getenv('MERAZUR'), 'rematch', 'compile_merazur.mat'))

% Plot a gatres histogram.
figure
ha = krijetem(subnum(1, 6));
fig2print(gcf, 'fportrait')

% Thresholds to allow pick (in seconds):
%
% find(abs(tres) <= tmax & twostd < umax)
%
% tmax = less than or equal to maximum-allowed time residual
% umax = less than 2\sigma uncertainty from CP.ci.M1.twosigma

tmax = 6;
umax = 1;

n_avail = [repmat(339, 1, 2) repmat(445, 1, 4)];
locfac = 339 / 445;

for j = 1:6
    [hh(j), n_plotted(j), mn(j), md(j), sd(j), dc1(j), ph_plotted{j}, ...
     idx{j}, dc2(j)] = hist_local(ha(j), tres_time(:, j), tmax, ...
                                  n_avail(j), tres_phase(:, j), ...
                                  twostd(:, j), umax, snrj(:, j));

end
set(ha, 'XLim', [-tmax tmax])
xticks(ha, [-tmax:2:tmax])
foo = xticklabels(ha(1));
foo(1:2:end) = {''};
set(ha, 'xticklabels', foo);

axis(ha, 'square')
shrink(ha, 0.75, 0.75)

set(ha(1:2), 'YTick', [0:15:60])
set(ha(1:2), 'YLim', [0  60])
set(ha(2), 'YLabel', []);
set(ha(2), 'YTickLabel', [])

set(ha(3:end), 'YLim', [0 80])
set(ha(3:end), 'YTick', [0:20:80])
set(ha(3:end), 'YLabel', [])
set(ha(4:end), 'YTickLabel', [])

longticks(ha, 0.75);
axesfs(gcf, axfs, txfs)

% Scale labels.
scal = {'$x_1$ if $f_s=20$', ...
        '$x_2$ if $f_s=20$', ...
        '$x_1$ if $f_s=5$,\n$x_3$ if $f_s=20$', ...
        '$x_2$ if $f_s=5$,\n$x_4$ if $f_s=20$', ...
        '$x_3$ if $f_s=5$,\n$x_5$ if $f_s=20$', ...
        '$\\overline{x}_3$ if $f_s=5$,\n$\\overline{x}_5$ if $f_s=20$'};

freq = {'$\\approx[10.0-5.0]$ Hz', ...
        '$\\approx[5.0-2.5]$ Hz', ...
        '$\\approx[2.5-1.2]$ Hz', ...
        '$\\approx[1.2-0.6]$ Hz', ...
        '$\\approx[0.6-0.3]$ Hz', ...
        '$\\approx[0.3-0.1]$ Hz'};

for j = 1:6
    % Outside bottom: scale number and sampling frequency,
    tx_scal(j) = text(ha(j), 0, 0, sprintf(scal{j}));
    tx_freq(j) = text(ha(j), 0, 0, sprintf(freq{j}));

    % Top left: mean
    % Top right: standard error.
    meanstr = sprintf('%4.1f', mn(j));
    if strcmp(meanstr, '-0.0')
        meanstr = '0.0';

    end

    stdstr = sprintf('%4.1f', sd(j));
    if strcmp(stdstr, '-0.0')
        stdstr = '0.0';

    end

    ms(j) = text(ha(j), 0, 0, sprintf('$\\mathrm{M}=%s$', meanstr));
    ses(j) = text(ha(j), 0, 0, sprintf('$\\mathrm{SD}=%s$', stdstr));

    % Title: number data in each histogram.
    tn(j) = title(ha(j), sprintf('$\\mathrm{N}=%i~[%3.1f$%s]', ...
                                 n_plotted(j), dc2(j), '\%'));

end
tscal = text(ha(1), -8, -32, 'scale:');
set(tx_scal(1:2), 'Position', [0 -32])
set(tx_scal(3:end), 'Position', [0 -32*(4/3)])

tfreq = text(ha(1), -8, -47, 'freq.:');
set(tx_freq(1:2), 'Position', [0 -47])
set(tx_freq(3:end), 'Position', [0 -47*(4/3)])

set(ms(1:2), 'Position', [-5.5 54.5])
set(ms(3:end), 'Position', [-5.5 54.5*(4/3)])

set(ses(1:2), 'Position', [+5.5 54.5])
set(ses(3:end), 'Position', [+5.5 54.5*(4/3)])


set(ha, 'XTick', [-6:2:6])
movefac = linspace(-0.05, 0.05, 6);
for j = 1:6
    % Vertical line.
    hold(ha(j), 'on')
    plot(ha(j), [0 0], ylim(ha(j)), '-k');
    hold(ha(j), 'off')

    % Space the axes out.
     moveh(ha(j), movefac(j))


end
set([tx_scal tscal tx_freq tfreq tn], 'Interpreter', 'Latex', ...
                   'FontName', 'Times', 'FontSize', txfs, ...
                   'HorizontalAlignment', 'Center')

set(ms, 'Interpreter', 'Latex', 'FontName', 'Times', ...
        'HorizontalAlignment', 'Left', 'FontSize', axfs)

set(ses, 'Interpreter', 'Latex', 'FontName', 'Times', ...
         'HorizontalAlignment', 'Right', 'FontSize', axfs)


moveh(ha(1:2), -0.01);
moveh(ha(3:end), 0.01);

latimes
[lax, lth] = labelaxes(ha, 'ul', true, 'FontName', 'Helvetica', ...
                       'Interpreter', 'Tex', 'FontSize', 12);
movev(lax, -0.472)
moveh(lax, -0.014)

savepdf(mfilename)

%______________________________________________________________%
%% Collect phase information.

% 1st: Find unique phases considering ALL scales.
ph2consider = {};
for j = 1:6
    ph2consider = [ph2consider; unique(ph_plotted{j})];

end
unique_ph = unique(ph2consider);


for j = 1:6
    for i = 1:length(unique_ph)
        ph_count(i, j) = sum(strcmp(ph_plotted{j}, unique_ph(i)));

    end

end

% Sort based overall counts per phase, across all scales.
sum_scal = sum(ph_count, 1);
sum_ph = sum(ph_count, 2);

[sum_ph, sorder] = sort(sum_ph, 'descend');
unique_ph = unique_ph(sorder);
ph_count = ph_count(sorder, :);

sz = size(ph_count);
ph_count(sz(1)+1,:) = sum_scal;
ph_count(:,sz(2)+1) = [sum_ph; NaN];

% Concatenate into a matrix and write to text file.
for i = 1:sz(1)
    lyne{i} = sprintf('%5s:%s\n', unique_ph{i}, sprintf(repmat(' %3i', 1, sz(1)), ph_count(i,:)));

end
lyne{end+1} = sprintf('      %s\n', sprintf(repmat(' %3i', 1, sz(2)), ph_count(end,:)));

fid = fopen(fullfile(getenv('PDF'), [mfilename '.txt']), 'w');
for i = 1:length(lyne)
    fprintf(fid, '%s', lyne{i});

end
fprintf(fid, '%s', sprintf('\ntmax = %.1f s, umax = %.1f \n', tmax, umax));
fclose(fid);

%_________________________%
function [hh, n_plotted, mn, md, sd, dc1, ph_plotted, idx, dc2] = ...
        hist_local(ha, tr, tmax, n_avail, ph, twostd, umax, snrj)

    idx = (find(abs(tr) <= tmax & twostd < umax));
    tr_plotted = tr(idx);
    ph_plotted = ph(idx);

    % Residual histogram with one-second bins.
    hh = histogram(ha, tr_plotted, 'BinLimit', [-tmax tmax], ...
                   'BinWidth', 1, 'Normalization', 'Count', ...
                   'FaceColor', 'k', 'EdgeColor', 'k');

    % This is the number actually plotted.
    n_plotted = sum(hh.BinCounts);

    % This is the 'data completeness' considering all seismograms with
    % sensitivity at this frequency band (requirements: tres within +-
    % lim, arrival exists (is not NaN due to SNR<=1), and has
    % sensitivity at this frequency.
    dc1 = (n_plotted / n_avail) * 100;

    % This is another 'data completeness' measure which only asks what
    % percentage of all picks fall within the boundary parameters (so
    % it doesn't include all possible seismograms; just all possible
    % picks at that scale.

    % WE CANNOT DO THIS:
    % n_picks = sum(isnan(tr))
    %
    % Because NaN is written both if there is no sensitivity at that
    % scale AND if there is no pick at that scale (SNR<=1).  Therefore
    % we must use the SNR value only.
    n_picks = sum(snrj > 1);
    dc2 = (n_plotted / n_picks) * 100;

    % Do statistics only on those values within the specified limits (say
    % outside limits obviously reject).
    mn = nanmean(tr_plotted);
    md = nanmedian(tr_plotted);
    sd = nanstd(tr_plotted, 1);

    % NOTE I mimicked \textsc with a double superscript to string GA.
    xlabel(ha, '$t_{\mathrm{res}}~\mathrm{(s)}$');
    ylabel(ha, 'Count');
    set(ha, 'TickDir', 'out');

end