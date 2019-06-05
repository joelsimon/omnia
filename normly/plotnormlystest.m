function f = plotnormlystest(MLE, lys, ha, nglog);
% f = plotnormlystest(MLE, lys, ha, nglog);
%
% Plots normlystest.m log-likelihood curves with two-standard
% deviation whiskers.
%
% In keeping with notation of simon+2019.pdf, standard deviation and
% variance statistics are returned in their biased forms: 
%
%                       1/N; not 1/(N-1)
%
% Input:      Input of normlystest.m
%
% Output:
% f           Struct with relevant figure handles
%
%
% Ex1: (plot positive log-likelihood; XLim = [.5 1.5]; 25 tests)
%    [lys,MLE] = normlystest(sqrt(2),[.5 1.5],100,1000,25,true,false)
%    f = PLOTNORMLYSTEST(MLE,lys)
%
% Citation: ??
%
% See also: normlystest.m, plot2normlystest.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 15-Jan-2018, Version 2017b

% Defaults.
defval('ha', []);
defval('nglog', false)

% See if axes handle passed as input; otherwise generate figure.
f = newax(ha);
ax = f.ha;
grid(ax,'On')
grid(ax,'Minor')

% Decide if plotting pos or neg likelihood curves.
if nglog
    neg = -1;
    bpos = 'um';
else
    neg = 1;
    bpos = 'lm';
end

% Plot entire likelihood line for all sigmas tested. Highlight MLE.
hold(ax,'on')
ntests = length(lys.curve);
for i = 1:ntests
    % Likelihood curve on normalized (by trusigma^2) x-axis.
    f.ly(i) = plot(ax, MLE.xaxis, neg*lys.curve{i}, 'Color', 'k');

    % Likelihood value corresponding to MLE of sigma^2 from normlys.m.
    f.MLE(i) = plot(ax, MLE.xaxis(lys.maxidx(i)), neg*lys.maxval(i), 'ro', ...
                    'MarkerFaceColor', 'r', 'MarkerSize',3);

    % Ensure dot plotted above line.
    f.MLE(i).ZData = 1;
end
hold(ax,'off')
axis(ax,'tight')
box(ax,'on')
ax.TickDir = 'out';

% Statistics normalized by (true sigma)^2; I realize I hold onto
% mean in MLE.avesigma but to be very clear I recompute here.
f.meanx = mean(MLE.sigma2 / MLE.trusigma^2);
f.stdx = std(MLE.sigma2 / MLE.trusigma^2, 1);
f.varx = var(MLE.sigma2 / MLE.trusigma^2, 1);

f.meany = mean(neg * lys.maxval);
f.stdy = std(neg * lys.maxval, 1);
f.vary = var(neg * lys.maxval, 1);

% Annotated box with sample statistics; mean, std., var. of MLE.
meanstr = sprintf(['mean($\\hat{\\sigma}^2/\\sigma_{\\circ}^2$) = ' ...
                   '%.3f'], f.meanx);
varstr = sprintf(['~~~var($\\hat{\\sigma}^2/\\sigma_{\\circ}^2$) = ' ...
                  '%.3f'], f.varx);

% latex-formatted text before the interpreter is set.
[f.bh, f.th] = boxtex(bpos, ax, sprintf('%s\n%s', meanstr, varstr));
f.th.Interpreter = 'Latex';

% Put a crosshair of TWO TIMES THE STANDARD DEVIATION at the center of
% likelihood curves; move later if necessary.
[f.xhair,f.xhairhg] = crosshair(ax, f.meanx, f.meany, 2*f.stdx, 2*f.stdy);

% X & Y labels.
xlabel(ax, 'variance $\sigma^2/\sigma_{\circ}^2$', 'Interpreter', ' Latex');
ylabel(ax, '$l(\mu=0,\sigma^2|f(x))$', 'Interpreter', ...
              'Latex');

% Return ordered handle structure.
f = orderfields(f);
