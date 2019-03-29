close all
clear all

% Text and axes fontsize.
axfs = 8;
txfs = 9;

load(fullfile(getenv('MERAZUR'), 'rematch', 'tres.mat'))

% Plot a gatres histogram.
figure
ha = krijetem(subnum(1, 6));
fig2print(gcf, 'fportrait')

lim = 6.5;
n_avail = [repmat(339, 1, 2) repmat(445, 1, 4)];
locfac = 339 / 445;

for j = 1:6
    [hh(j), n_tot(j), n_plotted(j), mn(j), md(j), sd(j), dc(j), ...
     ph_plotted{j}, idx{j}] = hist_local(ha(j), tres_time(:, j), ...
                                         lim, n_avail(j), tres_phase(:, j));

end
set(ha, 'XLim', [-lim lim])
xticks(ha, [-lim:2:lim])

axis(ha, 'square')
shrink(ha, 0.75, 0.75)

set(ha(1:2), 'YTick', [0:25:75])
set(ha(1:2), 'YLim', [0  115*locfac])
set(ha(2), 'YLabel', []);
set(ha(2), 'YTickLabel', [])

set(ha(3:end), 'YLim', [0 115])
set(ha(3:end), 'YTick', [0:25:100])
set(ha(3:end), 'YLabel', [])
set(ha(4:end), 'YTickLabel', [])

longticks(ha, 0.75);
axesfs(gcf, axfs, txfs)

% Scale labels.
scal = {'$x_1$ if $f_s=20$', ...
        '$x_2$ if $f_s=20$', ...
        '$x_1$ if $f_s=5$\n$x_3$ if $f_s=20$', ...
        '$x_2$ if $f_s=5$\n$x_4$ if $f_s=20$', ...
        '$x_3$ if $f_s=5$\n$x_5$ if $f_s=20$', ...
        '$\\overline{x}_3$ if $f_s=5$\n$\\overline{x}_5$ if $f_s=20$'};

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
    
    % Top right: mean and standard deviation 
    ms(j) = text(ha(j), 0, 0, sprintf(['$\\hat{\\mu}=%4.1f$\n$\\' ...
                        'hat{\\sigma}=%4.1f$'], mn(j), sd(j)));

    % Title: number data in each histogram.
    tn(j) = title(ha(j), sprintf('$\\mathrm{n}=%i~[%3.1f$%s]', n_plotted(j), dc(j), '\%'));

end
set(tx_scal(1:2), 'Position', [0 -47])
set(tx_scal(3:end), 'Position', [0 -47/locfac])
set(tx_freq(1:2), 'Position', [0 -70])
set(tx_freq(3:end), 'Position', [0 -70/locfac])


set(ms(1:2), 'Position', [-5.5 72])
set(ms(3:end), 'Position', [-5.5 72/locfac])

%tscal = text(ha(1), -11.5, -47, 'scalection:');
%tfreq = text(ha(1), -11.5, -70, 'freq. band:');

tscal = text(ha(1), -9, -47, 'scale:');
tfreq = text(ha(1), -9, -70, 'freq.:');

set(ha, 'XTick', [-6:2:6])
movefac = linspace(-0.05, 0.05, 6);
for j = 1:6
    % Vertical line.
    hold(ha(j), 'on')
    plot(ha(j), [0 0], ylim(ha(j)), '-k');
    hold(ha(j), 'off')

    % Space the axes out.
     moveh(ha(j), movefac(j))
    % Remove every other XTickLabel.
    %    ha(j).XTickLabel([2:2:end]) = {''};

end
 set([tx_scal tscal tx_freq tfreq tn], 'Interpreter', 'Latex', ...
                   'FontName', 'Times', 'FontSize', txfs, ...
                   'HorizontalAlignment', 'Center')
set([tx_scal tx_freq tn], 'Interpreter', 'Latex', ...
                  'FontName', 'Times', 'FontSize', txfs, ...
                  'HorizontalAlignment', 'Center')

set(ms, 'Interpreter', 'Latex', 'FontName', 'Times', ...
        'HorizontalAlignment', 'Left', 'FontSize', axfs)

moveh(ha(1:2), -0.01);
moveh(ha(3:end), 0.01);

latimes
[lax, lth] = labelaxes(ha, 'ul', true, 'FontName', 'Helvetica', ...
                       'Interpreter', 'Tex', 'FontSize', 12);
movev(lax, -0.472)
moveh(lax, -0.014)

savepdf('treshist')

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


% Sort based on scale with most arrivals.
% [~, mostph] = max(n_plotted);
% [~, sorder] = sort(ph_count(:, mostph), 'descend');  % 3rd column currently
% unique_ph = unique_ph(sorder);
% ph_count = ph_count(sorder, :);

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

fid = fopen('tresphase.txt', 'w');
for i = 1:length(lyne)
    fprintf(fid, '%s', lyne{i});

end
fclose(fid)

%_________________________%
function [hh, n_tot, n_plotted, mn, md, sd, dc, ph_plotted, idx] = ...
        hist_local(ha, tr, lim, n_avail, ph)
    
    idx = find(abs(tr) <= max(lim));
    tr_plotted = tr(idx);
    ph_plotted = ph(idx);
    
    % Histogram travel time residual data.
    hh = histogram(ha, tr_plotted, 'BinMethod', 'Integer', ...
                   'Normalization', 'Count', 'FaceColor', 'k', ...
                   'EdgeColor', 'k');

    % This is the number actually plotted.
    n_plotted = sum(hh.BinCounts);
    
    % This is the 'data completeness' considering all seismograms with
    % sensitivity at this frequency band (requirements: tres within +-
    % lim, arrival exists (is not NaN due to SNR<=1), and has
    % sensitivity at this frequency.
    dc = (n_plotted / n_avail) * 100;

    % This is the total number of residuals at this frequency band,
    % excluding NaNs, either due to no arrival (SNR <= 1) or no data
    % at that frequency band (fs = 5 Hz has no sensitivity at 8, 4
    % Hz).
    n_tot = sum(~isnan(tr));

    % The "data completeness" is thus the total number of residuals
    % plotted over the number that could be plotted.
    %    dc = (n_plotted / n_tot) * 100;

    % Do statistics only on those values within the specified limits (say
    % outside limits obviously reject).
    mn = nanmean(tr_plotted);
    md = nanmedian(tr_plotted);
    sd = nanstd(tr_plotted, 1);

    % NOTE I mimicked \textsc with a double superscript to string GA.
    %xlabel(ha, '$t_{\mathrm{res}}^{{}^\mathrm{GA}}$ (s)');
    xlabel(ha, '$t_{\mathrm{res}} \mathrm{(s)}$');
    ylabel(ha, 'count');
    set(ha, 'TickDir', 'out');

end
