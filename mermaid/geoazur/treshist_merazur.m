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
    [hh(j), n_tot(j), n_plotted(j), mn(j), md(j), sd(j), dc(j)] = ...
        hist_local(ha(j), tres_time(:, j), lim, n_avail(j));

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
scal = {'$x_1$ at $20$ Hz', ...
        '$x_2$ at $20$ Hz', ...
        '$x_3$ at $20$ Hz\n$x_1$ at $5$ Hz', ...
        '$x_4$ at $20$ Hz\n$x_2$ at $5$ Hz', ...
        '$x_5$ at $20$Hz\n$x_3$ at $5$ Hz', ...
        '$\\overline{x}_5$ at $20$ Hz\n$\\overline{x}_3$ at $5$ Hz'};


for j = 1:6
    % Outside bottom: scale number and sampling frequency,
    tx(j) = text(ha(j), 0, 0, sprintf(scal{j}));

    % Top right: mean and standard deviation 
    ms(j) = text(ha(j), 0, 0, sprintf(['$\\hat{\\mu}=%4.1f$\n$\\' ...
                        'hat{\\sigma}=%4.1f$'], mn(j), sd(j)));

    % Title: number data in each histogram.
    tn(j) = title(ha(j), sprintf('$\\mathrm{n}=%i~[%3.1f$%s]', n_plotted(j), dc(j), '\%'));

end
set(tx(1:2), 'Position', [0 -47])
set(tx(3:end), 'Position', [0 -62])
set(ms(1:2), 'Position', [-5.5 72])
set(ms(3:end), 'Position', [-5.5 72*(1/locfac)])

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
set(tx, 'Interpreter', 'Latex', 'FontName', 'Times', ...
        'HorizontalAlignment', 'Right', 'FontSize', txfs, ...
        'HorizontalAlignment', 'Center')
set(ms, 'Interpreter', 'Latex', 'FontName', 'Times', ...
        'HorizontalAlignment', 'Left', 'FontSize', axfs)
set(tn, 'Interpreter', 'Latex', 'FontName','Times', 'FontSize', txfs)

moveh(ha(1:2), -0.01);
moveh(ha(3:end), 0.01);

latimes


% [lax, lth] = labelaxes(ha, 'ul', true, 'FontName', 'Helvetica', ...
%                        'Interpreter', 'Tex', 'FontSize', 12);

% movev(lax, -0.505)
% moveh(lax, -0.01)

% savepdf(mfilename)


%_________________________%
function [hh, n_tot, n_plotted, mn, md, sd, dc] = hist_local(ha, tr, lim, n_avail)
    tr_within_lims = tr(abs(tr) <= max(lim));
    
    % Histogram travel time residual data.
    % hh = histogram(ha, tr, 'BinLimits', [-lim lim], 'NumBins', 17, ...
    %                'Normalization', 'Count', 'FaceColor', 'k', ...
    %                'EdgeColor', 'k');


    hh = histogram(ha, tr, 'BinLimits', [-lim lim], 'BinMethod', ...
                   'Integer', 'Normalization', 'Count', 'FaceColor', ...
                   'k', 'EdgeColor', 'k');

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
    mn = nanmean(tr_within_lims);
    md = nanmedian(tr_within_lims);
    sd = nanstd(tr_within_lims, 1);

    % NOTE I mimicked \textsc with a double superscript to string GA.
    %xlabel(ha, '$t_{\mathrm{res}}^{{}^\mathrm{GA}}$ (s)');
    xlabel(ha, '$t_{\mathrm{res}} \mathrm{(s)}$');
    ylabel(ha, 'count');
    set(ha, 'TickDir', 'out');

end
