function [f1, f2, f3, maxly, nMLE, sMLE] = image2normlysmix(perc, trusigmas,  lx, cp, axlim, npts, ntests, tinc, cmap)
% [f1, f2, f3. maxly, nMLE, sMLE] = IMAGE2NORMLYSMIX(perc, trusigmas, lx, cp, axlim, npts, ntests, cmap)
%
% IMAGE2NORMLYSMIX plots the summed log-likelihood surface in two
% variance coordinates.  It identifies the MLE variances and the
% associated summed log-likelihood considering the entire surface.  It
% repeats this process for three changepoint cases: early, correct,
% and late, with the percentage of mixing in the two segmentations
% defined by the input.
%
% Input:
% perc        Percentage of lx mixed between noise, signal (def: 10)
% trusigmas   2 standard deviations of noise, signal segments
%                 (def: [1 sqrt(2)])
% lx          Length random time series generated here (def: 1000)
% cp          Sample index of changepoint that separates noise, signal
%                 (def: 500)
% axlim       x-axis limits of likelihood plots,
%                ('normvars' in normlysmix.m) (def: [.5 1.5])
% npts        Number of x-axis points (e.g., number of likelihood
%                 calculations per time series tested) (def: 100)
% ntests      Number of likelihood curves plotted (def: 100)
% tinc        Tick increment: X and YTick intervals in normalized
%                 variance coordinates [axlim(1):tinc:axlim(2)] (def: 0.25)
% cmp         String specifying colormap (e.g., 'jet(5)') (def: 'jet')
%
% Output:
% f1          Structs with relevant figure handles
%             f1: changepoint early (unmixed noise ; mixed "signal")
%             f2: changepoint correct (no mixing of signal and noise)
%             f3: changepoint late (mixed "noise"; unmixed signal)
% maxly       Max. summed log-likelihood considering all combinations
% nMLE        MLE of the normalized variance of the noise segment
% sMLE        MLE of the normalized variance of the signal segment
%
% Ex:
%    IMAGE2NORMLYSMIX(25, [1 sqrt(2)], 1000, 500, [0.5 1.5], 1000, 100, 0.25, 'jet')
%
% See also: plot2normlysmix.m
%
% Cite: Simon, J. D. et al., (2020), BSSA, doi: 10.1785/0120190173
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 09-Jan-2020, Version 2017b on GLNXA64

% Defaults.
defval('perc', 10)
defval('trusigmas', [1 sqrt(2)])
defval('lx', 1000)
defval('cp', 500)
defval('axlim', [0.5 1.5])
defval('npts', 100)
defval('ntests', 100)
defval('tinc', 0.25)
defval('cmap', 'jet')

% Compute MIXED likelihoods and their MLEs.
[enk, esk, lnk, lsk, ~, cnk, csk] = normlysmix(perc, trusigmas, ...
                                               axlim, npts, lx, cp, ntests);

% Make image for changepoint early and changepoint late cases.
[f1, maxly, nMLE, sMLE] = makeimage(enk, esk, axlim, tinc, cmap);
[f2, maxly, nMLE, sMLE] = makeimage(cnk, csk, axlim, tinc, cmap);
[f3, maxly, nMLE, sMLE] = makeimage(lnk, lsk, axlim, tinc, cmap);


% Add the changepoint reference (early, correct, late) string.
f1.tx3 = text(f1.ax1, 0.05*npts, 0.05*npts, '$k<k_{\circ}$', 'Color', ...
              'w', 'FontSize', f1.ax1.FontSize, 'FontWeight', 'Bold');

f2.tx3 = text(f2.ax1, 0.05*npts, 0.05*npts, '$k=k_{\circ}$', 'Color', ...
              'w', 'FontSize', f2.ax1.FontSize, 'FontWeight', 'Bold');

f3.tx3 = text(f3.ax1, 0.05*npts, 0.05*npts, '$k>k_{\circ}$', 'Color', ...
              'w', 'FontSize', f3.ax1.FontSize, 'FontWeight', 'Bold');


latimes

f1.ax2.Position = f1.ax1.Position;
f2.ax2.Position = f2.ax1.Position;
f3.ax2.Position = f3.ax1.Position;

%____________________________________________________________________%
function [f, maxly, nMLE, sMLE] = makeimage(nk, sk, axlim, tinc, cmap)
noi = mean(cell2mat(nk.lys'));
sig = mean(cell2mat(sk.lys'));

% Image and imagesc.m have their origin in the top left of the
% axes, not the usually bottom left (0,0) of a plot.  Therefore,
% being that the signal axis will be the y-axis, we want to flip
% the signal matrix we input into meshgrid.m
[a, b] = meshgrid(noi, sig);
f.sumly = a + b;

% Compute maximum summed log-likelihood value and coordinates (test
% sigma for noise and signal).
[maxly, maxly_row, maxly_col] = maxmat(f.sumly, 'Max');

% N.B.: image. and imagesc.m have their origin in the top left (0,
% npts), not the usually bottom left (0,0), of the axis.  We will flip
% the axis direction at the end with set(ax1, 'YDir', 'normal'), which
% conveniently flips the data and their labels.
f.f = figure;
f.im = imagesc(f.sumly);

f.ax1 = gca;
axis(f.ax1, 'square')
add1XTick(f.ax1, 'x');
add1XTick(f.ax1, 'y');
colormap(eval(cmap))
f.cf = colorbar(f.ax1)
f.cf.Label.Interpreter = 'Latex';
f.cf.TickLabelInterpreter = 'Latex';
f.cf.Label.String = 'Summed log likelihood $\ell$';
f.cf.Label.FontSize = f.ax1.XLabel.FontSize;

% X and Y axes tick positions are the same.
npts = length(nk.sigmastested);  % == length(sk.sigmastested)

xlim([1 npts])
ylim([1 npts])
tickpos = [1:npts];
xticks(tickpos)
yticks(tickpos)

hold(f.ax1, 'on')
% Vertical and horizontal lines at expected normalized variance of noise (1 on both axes)
% Again, could be: correct_idx = nearestidx(sk.xaxis, 1);
correct_idx = nearestidx(nk.xaxis, 1);
if correct_idx
    f.vl = plot([correct_idx correct_idx], ylim, 'k');
    f.hl = plot(xlim, [correct_idx correct_idx], 'k');

end

% Mark the maximum summed log-likelihood value and normalized coordinates.
for i = 1:length(maxly_row)
    % Return the MLE of the variance of the noise and signal
    % segmentations, each normalized w.r.t their true population
    % parameters.
    nMLE(i) = nk.sigmastested(maxly_col(i))^2 / nk.trusigma2;
    sMLE(i) = sk.sigmastested(maxly_row(i))^2 / sk.trusigma2;

    f.maxly = plot(maxly_col(i), maxly_row(i), 'kx', 'MarkerSize', 10);
    f.tx1 = text(maxly_col(i), maxly_row(i) - (0.1*npts), ...
                 sprintf(['(%.3f, ' '%.3f)'],nMLE(i), sMLE(i)), ...
                 'Color', 'w', 'HorizontalAlignment', 'Center');
    f.tx2 = text(maxly_col(i), maxly_row(i) - (0.2*npts), sprintf('=%i', ...
                                                      round(maxly)), 'Color', ...
                 'w', 'HorizontalAlignment', 'Center');

end
topz(f.maxly);
hold(f.ax1, 'off')

% Primary x-axis = normalized variance: noise.
f.xlab1 = cellfun(@(xx) sprintf('%1.2f', xx), num2cell(nk.xaxis(tickpos)), ...
                'UniformOutput', false);
set(f.ax1, 'XTickLabels', f.xlab1);

% Primary y-axis = normalized variances: signal.
f.ylab1 = cellfun(@(xx) sprintf('%1.2f', xx), num2cell(sk.xaxis(tickpos)), ...
                'UniformOutput', false);
set(f.ax1, 'YTickLabels', f.ylab1);

% Secondary x-axis = sigmas tested: noise
f.xl1 = xlabel(f.ax1, '$\sigma_1^2\big/\sigma_{1_\circ}^2$');
f.xlab2 = cellfun(@(xx) sprintf('%1.2f', xx), ...
                  num2cell(nk.sigmastested(tickpos).^2), 'UniformOutput', ...
                  false);

% Secondary y-axis = sigmas test: signal
f.yl1 = ylabel(f.ax1, '$\sigma_2^2\big/\sigma_{2_\circ}^2$');
f.ylab2 = cellfun(@(xx) sprintf('%1.2f', xx), ...
                  num2cell(sk.sigmastested(tickpos).^2), 'UniformOutput', ...
                  false);

% Generate secondary axes.
[f.ax2, f.xl2, f.yl2] = xtraxis(f.ax1, tickpos, f.xlab2, '$\sigma_1^2$', ...
                                tickpos, f.ylab2, '$\sigma_2^2$');

%% Adjust the ticks and labels per the increment requested.

% The x and y ticks of axis 1 are the same; in terms of normalized
% variance.  This just as well could be:
% tickpos = nearestidx(sk.xaxis, [sk.xaxis(1):tinc:sk.xaxis(end)]);
tickpos = nearestidx(nk.xaxis, [nk.xaxis(1):tinc:nk.xaxis(end)]);

% Adjust the tick marks keeping only the correctly-indexed labels.
set(f.ax1, 'XTick', tickpos, 'XTickLabels', f.xlab1(tickpos));
set(f.ax1, 'YTick', tickpos, 'YTickLabels', f.ylab1(tickpos));
set(f.ax2, 'XTick', tickpos, 'XTickLabels', f.xlab2(tickpos));
set(f.ax2, 'YTick', tickpos, 'YTickLabels', f.ylab2(tickpos));

% Final cosmetics: flip axes orientation back to usual coordinates and
% align both axes.
set(f.ax1, 'YDir', 'normal')

set([f.ax1 f.ax2 f.cf], 'TickDir', 'out')
