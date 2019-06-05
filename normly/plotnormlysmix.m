function f = plotnormlysmix(nkorsk,nglog,ha)
% f = PLOTNORMLYSMIX(nkorsk,nglog,ha)
%
% Plots normlysmix.m log-likelihood curves. See there for I/O
% information.  No defaulted inputs.
%
% Unlike normlystest.m, normlysmix.m has the potential for 4 output
% plots because there is both a 'noise' and 'signal' output, for both
% a late and early changepoint estimation.  To be extremely concrete
% this function then must be called twice to plot the likelihood
% curves associated with both segments; don't pass in an entire MLE
% structure. This decision was made so that full and obvious control
% over separate figures, or the same figure with assigned axes, was
% maintained.
%
% Suggests generic title and ylabels that will need to be updated with
% information about percentage of mixture (input to normlysmix.m);
% time series segment ('n(k)','s(k)') etc.  See plot2normlysmix.m.
%
% In keeping with notation of simon+2019.pdf, standard deviation and
% variance statistics are returned in their biased forms: 
%
%                       1/N; not 1/(N-1)
%
% Output:
% f                Struct with relevant axis handles
%
% Ex: (normlysmix with defaults)
%    [enk,esk,lnk,lsk] = normlysmix;
%    f1 = PLOTNORMLYSMIX(enk);
%    title('Changepoint early: noise')
%    f2 = PLOTNORMLYSMIX(esk);
%    title('Changepoint early: signal');
%    f3 = PLOTNORMLYSMIX(lnk); 
%    title('Changepoint late: noise');
%    f4 = PLOTNORMLYSMIX(lsk);
%    title('Changepoint late: signal');
%
% Citation: ??
%
% See also: normlysmix.m, plot2normlysmix.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 04-Aug-2017, Version 2017b

% Defaults.
defval('nglog',false)
defval('ha',[]);

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
grid(ax,'on')
grid(ax,'minor')

% Pull out normalized X-Axis.
xax = nkorsk.xaxis;
axlim = [xax(1) xax(end)];
ntests = length(nkorsk.lys);

% Switch for negative log-likelihood.
if nglog
    neg = -1;
    bpos = 'um';
else
    neg = 1;
    bpos = 'lm';
end

% For every test: plot entire likelihood curve for all sigmas
% tested. Highlight (normalized) MLE point on curve.
hold(ax,'on')
for i = 1:ntests
    % The actual likelihood plot.
    f.ly(i) = plot(ax,xax,neg*nkorsk.lys{i},'k');

    % Highlight the likelihood value at that normalized sigma^2.
    f.MLE(i) = plot(ax,xax(nkorsk.lys_maxidx(i)),neg*nkorsk.lys_maxval(i), ...
                    'ro', 'MarkerFaceColor','r', 'MarkerSize',3);
end
hold(ax,'off')
axis(ax,'tight')
box(ax,'on')
ax.TickDir = defs.tickDir;
ax.TickLength = defs.tickLength;

% Statistics.
% x-axis statistics normalized by (true sigma)^2; I realize I hold onto
% mean in nkorsk.avesigma but to be very clear I recompute here.
%
% These are biased estimates of statistics in keeping with simons+2019.
f.meanx = mean(nkorsk.MLEsigmas.^2 / nkorsk.trusigma^2);
f.stdx = std(nkorsk.MLEsigmas.^2 / nkorsk.trusigma^2, 1);
f.varx = var(nkorsk.MLEsigmas.^2 / nkorsk.trusigma^2, 1);

f.meany = mean(neg * nkorsk.lys_maxval);
f.stdy = std(neg * nkorsk.lys_maxval, 1);
f.vary = var(neg * nkorsk.lys_maxval, 1);

[f.xhair,f.xhairhg] = crosshair(ha, f.meanx, f.meany, 2*f.stdx, 2*f.stdy);

% latex-formatted text before the interpreter is set.
% Annotated box with sample statistics; mean, std., var. of MLE.
meanstr = sprintf(['mean($\\hat{\\sigma}^2/\\sigma_{\\circ}^2$) = ' ...
                   '%.3f'], f.meanx);
varstr = sprintf(['~~~var($\\hat{\\sigma}^2/\\sigma_{\\circ}^2$) = ' ...
                  '%.3f'], f.varx);
[f.bh, f.th] = boxtex(bpos, ax, sprintf('%s\n%s', meanstr, varstr));
f.th.Interpreter = 'Latex';

f.th.FontName = defs.font.name;
f.th.FontSize = defs.font.sizeBox;
f.bh.Visible = 'off';

% X & Y labels.
f.xl = xlabel(ax,'$\tilde{\sigma}^2/\sigma^2$');
f.xl.Interpreter = 'latex';
f.xl.FontName = defs.font.name;
f.xl.FontSize = defs.font.sizeLabel;
f.xl.FontWeight = defs.font.weight;

f.yl = ylabel(ax,'$l(\mu=0,\tilde{\sigma}^2|f(x))$');
f.yl.Interpreter = 'latex';
f.yl.FontName = defs.font.name;
f.yl.FontSize = defs.font.sizeLabel;
f.yl.FontWeight = defs.font.weight;

% Switch formatspec for title if true variance is an integer.
titstr = normstr(0,nkorsk.trusigma,1,true);
f.tl = title(ax,sprintf('$f(x)\\sim%s$',titstr));
f.tl.Interpreter = 'latex';
f.tl.FontName = defs.font.name;
f.tl.FontSize = defs.font.sizeTitle;
f.tl.FontWeight = defs.font.weight;

% Bring highlighted MLE points to front.
set(f.MLE,'ZData',1)

% Return ordered structure.
f = orderfields(f);
