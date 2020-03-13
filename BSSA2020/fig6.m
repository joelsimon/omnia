% Figure 6
%
% Cite: Simon, J. D. et al., (2020), BSSA, doi: 10.1785/0120190173
%
% A 3 panel subplot of (1) modeled data, (2) AIC function; (3) AIC
% weights for both a high- and low-SNR case example.
%
% Defaults to use biased estimate of variance. Change internally for
% unbiased estimate.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 22-May-2018, Version 2017b

clear
close all

% This probably shouldn't be changed from true, but just so we know
% it's here; we are using the BIASED the sample variance, normalized
% by N, not N-1, because that's what falls out of the math.
bias = true;

% Time series length and changepoint.
lx = 1000;
bp = 500;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Either comment this
% % I load the high and low-SNR time series below, but this is how you
% % generate.  Low- and high-SNR standard deviations (not variances!).
% std_hi = sqrt(25);
% std_lo = sqrt(2);

% % Make high SNR time series.
% hi_x = cpgen(lx, bp, 'norm', {0 1}, 'norm', {0 std_hi});

% % Make low SNR time series.
% lo_x = cpgen(lx, bp, 'norm', {0 1}, 'norm', {0 std_lo});

% % To verify the SNR with an unbiased estimate of variance.
% hiub_snr = var(hi_x(bp+1:end), 0) / var(hi_x(1:bp), 0)
% loub_snr = var(lo_x(bp+1:end), 0) / var(lo_x(1:bp), 0)

% % Again, with biased estimate of variance (essentially the same)
% hib_snr = var(hi_x(bp+1:end), 1) / var(hi_x(1:bp), 1)
% lob_snr = var(lo_x(bp+1:end), 1) / var(lo_x(1:bp), 1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Either comment this

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -OR- comment this
load('Static/weights.mat')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -OR- comment this

% Figure window.
figure
[~,ha] = krijetem(subnum(3, 1));
f = ha(1).Parent;
fig2print(f, 'landscape');

% Shift axes.
movev(ha(2), 0.03)
movev(ha(3), 0.03)

[hi_kw, hi_km, hi_aic, hi_weights] = cpest(hi_x, 'fast', false, bias);

[lo_kw, lo_km, lo_aic, lo_weights] = cpest(lo_x, 'fast', false, bias);

% Colors and line widths;
lo_col = 'k';
hi_col = [0.6 0.6 0.6];

hi_lw = 0.5;
lo_lw = 0.5;

%% First panel: high- and low-SNR on same plot.
ax = ha(1);
xax = [1:lx];
hold(ax, 'on')
p1_hi = plot(ax, xax, hi_x, 'Color', hi_col);
p1_lo = plot(ax, xax, lo_x, 'Color', lo_col);
k0 = text(ha(1), bp, ha(1).YLim(2), '$k_{\circ}$');
yl1 = ylabel(ax,'$x$');
hold(ax, 'off')

p1_hi.LineWidth = hi_lw;
p1_lo.LineWidth = lo_lw;

%% Second panel: signal. ax2 is the double-axes created by plotyy, NOT ha(2).
ax = ha(2);
[ax2, p2_hi, p2_lo]  = plotyy(ax, xax, hi_aic, xax, lo_aic);

p2_hi.LineWidth = hi_lw;
p2_lo.LineWidth = lo_lw;

% Line colors.
p2_lo.Color = lo_col;
p2_hi.Color = hi_col;

% And YLabel colors.
ha2_hi = ax2(1);
ha2_hi.YAxis.Color = hi_col;

ha2_lo = ax2(2);
ha2_lo.YAxis.Color = lo_col;

%% Third panel: weights.
ax = ha(3);
hold(ax, 'on');
xax3 = [460:540];
[ax3, p3_hi, p3_lo] = plotyy(ax, xax3, hi_weights(xax3), xax3, lo_weights(xax3));
hold(ax,'off')

p3_hi.LineWidth = hi_lw;
p3_lo.LineWidth = lo_lw;

% Line colors.
p3_lo.Color = lo_col;
p3_hi.Color = hi_col;

% And YLabel colors.
ha3_hi = ax3(1);
ha3_hi.YAxis.Color = hi_col;

ha3_lo = ax3(2);
ha3_lo.YAxis.Color = lo_col;

xlabel(ax, 'Sample index $k$');

% Axes limits and ticks.
ha(1).XLim = [1 1000];
ha2_lo.XLim = [1 1000];
ha2_hi.XLim = [1 1000];


ha(1).YLim = [-25 25];
ha2_lo.YLim = [250 350];
ha2_hi.YLim = [1000 3000];
ha3_lo.YLim = [0 0.1]
ha3_hi.YLim = [0 1];

numticks(ha(1), 'y', 3);

numticks(ha2_lo, 'y', 3);
numticks(ha2_hi, 'y', 3);

numticks(ha3_lo, 'y', 3);
numticks(ha3_hi, 'y', 3);
numticks(ha(3), 'x', 11);

% I want black (low-SNR) over gray (high-SNR) so I plotted then in
% that order, but I want black (low-SNR) YTick labels to be on
% left. So swap them.
ha2_lo.YAxisLocation = 'left';
ha2_lo.TickDir = 'out';
yl2 = ylabel(ha2_lo, '$\mathcal{A}$');

ha2_hi.YAxisLocation = 'right';
ha2_hi.TickDir = 'out';

ha3_lo.YAxisLocation = 'left';
ha3_lo.TickDir = 'out';
yl3 = ylabel(ha3_lo, '$w$');

ha3_hi.YAxisLocation = 'right';
ha3_hi.TickDir = 'out';

% Ensure proper x and y axes, ensure axis box, swap tick direction.
set(ha(1), 'TickDir', 'out')
set(ha([1 2]), 'XTick', [1 100:100:1000])
set(ha, 'Box', 'on')

% Delete the first and second axes tick marks.
ha(1).XTickLabel = [];

% Latex and times.
latimes(f);

% Vertlines.
vltru = vertline(bp, ha(1:3), 'k');
vlest = vertline([lo_km lo_kw], ha(2:3));

vlest{1}(1).Color = 'b';
vlest{1}(2).Color = 'b';

vlest{2}(1).Color = 'r';
vlest{2}(2).Color = 'r';

% Legend
lg_entries = [p1_lo p1_hi];
lg_str = {'$\mathrm{SNR}=2$', '$\mathrm{SNR}=25$'};
lg1 = legend(ha(1), lg_entries, lg_str, 'Location', 'NW', 'Interpreter', ...
             'Latex', 'Box', 'off');
lg1.Position(2) = 0.84;

lg_entries = [vltru{1}(3) vlest{1}(2) vlest{2}(1)];
lg_str = {'$k_{\circ}$','$k_\mathrm{m}$','$k_\mathrm{w}$'};
lg2 = legend(ha2_lo, lg_entries, lg_str, 'Location', 'SW', ...
              'Interpreter', 'Latex', 'Box', 'off');
lg2.Position(2) = 0.45;

% Label the axes.
[lax,th] = labelaxes([ha(1) ha2_lo ha3_lo],'ul', true, 'FontName', ...
                     'Helvetica', 'InterPreter', 'tex','FontWeight','normal');
movev(lax, 0.02)
moveh(lax, -0.1)

% Final cosmetics.
topz(p1_lo);
k0.Position(2) = 30;
longticks([ha(1) ha2_lo ha2_hi ha3_lo ha3_hi], 3)
yl1.Position(1) = yl2.Position(1);
yl3.Position(1) = 453;

axesfs(f, 9, 13);
lg1.FontSize = 10;
lg2.FontSize = 10;
movev(lg1,-.005)

if bias == true
    warning('bias is TRUE, normalized by 1/N')
    savepdf(mfilename)
else
    warning('bias is FALSE, normalized by 1/(N-1)')
    savepdf([mfilename '_unbiased'])
end
