function f = plotnormlysmixsum(nk, sk, nglog, ha, meth);
% f = PLOTNORMLYSMIXSUM(nk,sk,nglog,ha,meth);
%
% Called in plot2normlysmix.m it looks like this, populating
% SUBPLOTS 1 AND 4:
% f.f1 = plotnormlysmixsum(lnk,lsk,nglog,f.ha1);
% f.f4 = plotnormlysmixsum(enk,esk,nglog,f.ha4);
%
% Plots the summation of two log-likelihood pots given noise (nk) and
% signal (sk) structures with some mixing.  The convention is early
% goes with early, late with late, when calculating the likelihood
% given noise and signal mixing (the changepoint is incorrect).  See
% normlysmix.m for naming convention.
%
% The color of the summed log-likelihood curves is determined by the
% length of each segment; i.e. a time series assumed to be completely
% noise is blue, and one assumed to be completely signal is red.  If
% there are equal numbers of samples in the noise and signal segments
% the time series is magenta.
%
% % In keeping with notation of simon+2019.pdf, standard deviation and
% variance statistics are returned in their biased forms:
%
%                       1/N; not 1/(N-1)
% Input:
% nk          Early or late noise structure from normlysmix.m
% sk          Early or late signal structure from normlysmix.m
% nglog       true to plot negative log-likelihoods (def: false)
% ha          Axes handle to place plot
% meth        1: Sum log-likelihoods same normalized variance
%             2: Sum log-likelihoods using single value of correctly
%                mixed section: its maximum log-likelihood (def)
%             3: Sum log-likelihoods using single value of correctly
%                mixed section: its log-likelihood at the sigma tested
%                which is nearest the trusigma of generating
%                distribution
%
% Output:
% f           Structure with figure handle bits
%
% Ex:
%    [enk,esk,lnk,lsk] = normlysmix(25, [1 4], [0.5 25]); figure
%    f_early = PLOTNORMLYSMIXSUM(enk, esk, false, gca, 1); figure
%    f_late  = PLOTNORMLYSMIXSUM(lnk, lsk, false, gca, 1)
%
% See also: plot2normlysmix.m, normlysmix.m (particularly nk/sk naming convention)
%
% Cite: Simon, J. D. et al., (2020), BSSA, doi: 10.1785/0120190173
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 10-Jan-2020, Version 2017b on GLNXA64

% Defaults.
defval('nglog',false)
defval('ha',[]);

% First, ensure the proper nk and sk structures were supplied: early
% with early (enk, esk) and late with late (lnk, lsk).  Inspect their
% info strings to be sure.
experiment = [nk.info ' & ' sk.info];
acceptable_experiment = {'changepoint early: noise & changepoint early: signal', ...
                         'changepoint late: noise & changepoint late: signal'};
if ~sum(contains(acceptable_experiment, experiment))
    error(['Incorrect nk, sk structures supplied: enk goes with esk; ' ...
           'lnk goes with lsk'])

end

% Load defaults I like.
defs = stdplt;
defs.lineWidth = .5;
defs.font.Interpreter = 'latex';
defs.font.sizeTitle = 12;
defs.font.sizeLabel = 10;
defs.font.sizeBox = 10;

% See if axes handle passed as input; otherwise generate figure.
f = newax(ha);
ax = f.ha;

% Set up normalized x-axis of test sigmas^2 / true sigma^2.
xax = nk.xaxis;
ntests = length(nk.lys);

% Switch for negative log-likelihood.
if nglog
    neg = -1;
    func = @min;
    bpos = 'ur';
else
    neg = 1;
    func = @max;
    bpos = 'lr';
end

% Determine color based how much of the total time series is
% considered "noise" or "signal" (color is not based on the amount of
% incorrect mixing).  A time series that is assumed to be completely
% noise is blue; signal is red.  For example: if the true changepoint
% is in the middle (ergo, the true time series is a perfect 50/50
% mixture of blue and red [magenta]), and the percent mixing is 49.9%,
% the lnk + lsk summed plot would be nearly completely blue, and the
% enk + esk would be nearly completely red.
col = [1 0 1];

% N.B.: Could use > or >= here; the multiplication factor at the
% bottom when nk.lx == sk.lx is the same (fac = 1) and thus the color
% is the same.
nk_is_longer = nk.lx > sk.lx;
if nk_is_longer
    if sk.lx == 0;
        % No signal; all blue.
        col = [0 0 1]
    else
        % Multiplicative factor: if noise is twice as long as
        % signal, there should be twice the blue.
        fac = nk.lx/sk.lx;
        col(1) = col(1)/fac;
    end
else
    % More signal == more red (less blue).
    if nk.lx == 0;
        % Not noise; all red.
        col = [1 0 0]
    else
        fac = (sk.lx/nk.lx);
        col(3) = col(3)/fac;
    end
end

%% Main.
hold(f.ha,'on')
grid(f.ha,'on')
grid(f.ha,'minor')
ntests = length(nk.lys);

% Decide the static variable for cases 1 and 2 below:
% changepoint early: noise value is static (no incorrect mixing of the signal)
% changepoint late: signal value is static (no incorrect mixing of the noise)
if contains(experiment, 'early')
    static = nk;
    varies = sk;

else
    static = sk;
    varies = nk;

end

% Sum the two (mixed) likelihoods.
for i = 1:ntests;
    switch meth
      case 1
        % Sum at indices of same normalized test variance.
        summed = neg * (nk.lys{i} + sk.lys{i});
        %disp('meth 1: sum at normalized variances')

      case 2

        % The static value is the maximum log-likelihood value obtained after
        % testing all sigmas.
        summed = neg * (varies.lys{i} + static.lys_maxval(i));
        %disp('meth 2: sum at static value = maximum likelihood of unmixed section')

      case 3
        % The static value is the log-likelihood value obtained at the tested
        % sigma NEAREST to the true sigma.
        trusigma_idx = nearestidx(static.sigmastested, static.trusigma);
        if ~trusigma_idx
            error(['Cannot compute summed mixture using meth = 2 ' ...
                   'because the true sigma of the generating ' ...
                   'distribution is not within the range of sigmas tested'])
        end
        summed = neg * (varies.lys{i} + static.lys{i}(trusigma_idx));
        %disp('meth 3: sum at static value = maximum likelihood at trusigma of unmixed section')

      otherwise
        error('Specify 1 2 or 3 for input: ''meth''')

    end
    f.ly(i) = plot(f.ha, xax, summed, 'Color', col);
    [lysval,idx] = func(summed);
    f.MLE(i) = plot(f.ha,xax(idx),lysval,'ko','MarkerFaceColor', ...
                    'k','MarkerSize',3);
end
hold(f.ha,'off')
axis(f.ha,'tight')
box(f.ha,'on')

% Add a crosshair for the DATA -- use biased statistical estimates in keeping with
% the definitions of Simon, J. D. et al., (2020), BSSA, doi: 10.1785/0120190173.
f.meanx = mean([f.MLE.XData]);
f.stdx = std([f.MLE.XData], 1);
f.varx = var([f.MLE.XData], 1);

f.meany = mean([f.MLE.YData]);
f.stdy = std([f.MLE.YData], 1);
f.vary = var([f.MLE.YData], 1);

[f.xhair,f.xhairhg] = crosshair(ha, f.meanx, f.meany, 2*f.stdx, 2*f.stdy);

% Cosmetics and labels.
set(f.MLE,'ZData',f.xhair.c.ZData);
set(f.ly,'LineWidth',defs.lineWidth);

f.xl = xlabel('foo');
f.xl.Interpreter = 'latex';
f.xl = xlabel(ax,'$\tilde{\sigma}^2/\sigma^2$');
f.xl.FontName = defs.font.name;
f.xl.FontSize = defs.font.sizeLabel;
f.xl.FontWeight = defs.font.weight;

f.yl = ylabel('foo');
f.yl.Interpreter = 'latex';
f.yl = ylabel(ax,'$l^{\prime}\big(\mu=0,\tilde{\sigma}^2~|~x_(k))$');
f.yl.FontName = defs.font.name;
f.yl.FontSize = defs.font.sizeLabel;
f.yl.FontWeight = defs.font.weight;

f.tl = title(ax,'Summed Log-Likelihood');
f.tl.Interpreter = 'latex';
f.tl.FontName = defs.font.name;
f.tl.FontSize = defs.font.sizeTitle;
f.tl.FontWeight = defs.font.weight;

% Annotated box.
meanstr = sprintf('Mean($\\hat{\\sigma}^2/\\sigma_\\circ^2$) = %.3f', f.meanx);
varstr = sprintf('~~~Var($\\hat{\\sigma}^2/\\sigma_\\circ^2$) = %.3f', f.varx);
f.bxstr = sprintf('%s\n%s', meanstr, varstr);
[f.bh,f.th] = boxtex(bpos,ax,'foo');
f.th.String = f.bxstr;
f.th.Interpreter = defs.font.Interpreter;
f.th.FontName = defs.font.name;
f.th.FontSize = defs.font.sizeBox;
f.bh.Visible = 'off';

% Return ordered field.
f = orderfields(f);
