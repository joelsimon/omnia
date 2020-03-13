% Figures 10 & 11
%
% Cite: Simon, J. D. et al., (2020), BSSA, doi: 10.1785/0120190173
%
% plotcpm2s.m (a local version), both as a function of alpha-level and
% sample span, with some formatting.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 22-May-2018, Version 2017b

clear
close all

lw = 1;
bias = true;

if bias == true
    bias_str = 'biased';
else
    bias_Str = 'unbiased';
end

%% How generate --
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Comment this...
% alphas = [0:0.1:100];
% iters = 1000;
% lx =  1000;
% bp =  500;
% dist1 = 'norm';
% p1 = {0 1};
% dist2 = 'norm';
% p2 = {0 sqrt(2)};
% abso = false;
% dtrnd = false;

% [km_countr, ~, km_ranger] = ...
%     cpm2_local(alphas, iters, lx, bp, dist1, p1, dist2, p2, abso, ...
%                dtrnd, true, [], [], bias);

% [km_countur, ~, km_rangeur] = ...
%     cpm2_local(alphas, iters, lx, bp, dist1, p1, dist2, p2, abso, ...
%                dtrnd, false, [], [], bias);

% [~, kw_countr, ~, kw_ranger] = ...
%     cpm2_local(alphas, iters, lx, bp, dist1, p1, dist2, p2, abso, ...
%                dtrnd, true, [], [], bias);

% [~, kw_countur, ~, kw_rangeur] = ...
%     cpm2_local(alphas, iters, lx, bp, dist1, p1, dist2, p2, abso, ...
%                dtrnd, false, [], [], bias);

% warning(['hardcoded the vertical lines in alphasummary_samp.pdf based ' ...
%        'on precomputed results loaded in Static/. If rerun, inspect ' ...
%        'those lines.'])

% save(sprintf('alphasummary_%s', bias_str))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Comment this...

%% How to load precomputed results --
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -OR- Comment this...
if bias == true
    load 'Static/alphasummary_biased.mat';
else
    load 'Static/alphasummary_unbiased.mat';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% -OR- Comment this...

f = figure;
ha = gca;

prob_kmr = km_countr/iters;
prob_kmur = km_countur/iters;

prob_kwr = kw_countr/iters;
prob_kwur = kw_countur/iters;


hold(ha, 'on')

pl_kmr = plot(alphas, prob_kmr, 'b', 'LineStyle', '-', 'LineWidth',lw);
pl_kwr = plot(alphas, prob_kwr, 'r', 'LineStyle', '-', 'LineWidth', lw);
pl_kmur = plot(alphas, prob_kmur, 'b', 'LineStyle', '--', 'LineWidth', lw);
pl_kwur = plot(alphas, prob_kwur, 'r', 'LineStyle', '--', 'LineWidth', lw);

hold(ha, 'off')
xlim([0 20])
ylim([0 1])

lg_entries = [pl_kmr, pl_kwr, pl_kmur, pl_kwur];
lg_str = {'$k_\mathrm{m}$ restricted', '$k_\mathrm{w}$ restricted', ...
          '$k_\mathrm{m}$ unrestricted', '$k_\mathrm{w}$ unrestricted'};
lg = legend(lg_entries, lg_str, 'Location', 'SouthEast', 'Interpreter', ...
            'Latex', 'AutoUpdate', 'off');

ylabel('Probability of rejecting $\mathrm{H}_{0}$', 'Interpreter', 'Latex');
xlabel('$\alpha~(\%)$', 'Interpreter', 'Latex');

numticks(ha,'x',11);
box on
grid on
ha.TickDir = 'out';
latimes
axesfs(f,9,13)
lg.FontSize = 10;

th.Position(1) = 7;

if bias == true
    savepdf('fig10')
else
    savepdf(['fig10_unbiased'])
end

%%%%%%%%%%%%%%%%%%%%

% Figure 2

% This is to find sample spans the relate to 68%, 95% (~1,2sigma)
% rejection of null hypothesis.

% Percentages.
km_percr = (km_countr/iters)*100;
km_percur = (km_countur/iters)*100;

kw_percr = (kw_countr/iters)*100;
kw_percur = (kw_countur/iters)*100;


f2 = figure;
ha2 = gca;

hold(ha2, 'on')
pl_kmspanr = plot(km_ranger, prob_kmr, 'b', 'LineStyle', '-', 'LineWidth', lw);
pl_kwspanr = plot(kw_ranger, prob_kwr, 'r', 'LineStyle', '-', 'LineWidth', lw);
pl_kmspanur = plot(km_rangeur, prob_kmur, 'b', 'LineStyle', '--', 'LineWidth', lw);
pl_kwspanur = plot(kw_rangeur, prob_kwur, 'r', 'LineStyle', '--', 'LineWidth', lw);
xlim([1 100]);
ylim([0 1])
hold(ha2, 'off')

% 1sigma,2sigma patches.  Nearest index finds the index where the
% probability is 0.68, 0.95.  Putting that index into the range
% (sample span averages) converts that probability to its associated
% sample span.
left68_idx = nearestidx(prob_kmr, 0.68);
left68_samp = km_ranger(left68_idx);

right68_idx = nearestidx(prob_kwur, 0.68);
right68_samp = kw_rangeur(right68_idx);

left95_idx = nearestidx(prob_kmur, 0.95);
left95_samp = km_rangeur(left95_idx);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% VERTICAL LINES
%% HARDCODED FOR SIMPLITICY. May need to change if rerun.
% Now the right is either km restricted, or kw_unrestricted.  Use the
% larger of these two numbers to determine rhs edge of 95th
% percentile.
kmr_right = km_ranger(nearestidx(prob_kmr, 0.95));
kwur_right = kw_rangeur(nearestidx(prob_kwur, 0.95));

if bias == true
    % kw unrestricted is larger
    right95_idx = nearestidx(prob_kwur, 0.95);
    right95_samp = kw_rangeur(right95_idx);
else
    % km restricted is larger Note: this is odd if you zoom in because at
    % .95 the interpolated kwur line looks further to the right, but
    % the kmr value nearest 95 (there isn't one exactly there, its at
    % .949) is larger than the closet kwur value.
    right95_idx = nearestidx(prob_kmr, 0.95);
    right95_samp = km_ranger(right95_idx);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% VERTICAL LINES

hold(ha2, 'on')
hl68 = plot(ha2, [0 right68_samp], [0.68 0.68], 'k--');
hl95 = plot(ha2, [0 right95_samp], [0.95 0.95], 'k--');

vl68_left = plot(ha2, [left68_samp left68_samp], [0 0.68], 'k-');
vl68_right = plot(ha2, [right68_samp right68_samp], [0 0.68], 'k-');

vl95_left = plot(ha2, [left95_samp left95_samp], [0 0.95], 'k-');
vl95_right = plot(ha2, [right95_samp right95_samp], [0 0.95], 'k-');
hold(ha2, 'off')

lg_entries = ([pl_kmspanr pl_kwspanr pl_kmspanur pl_kwspanur]);
lg2 = legend(lg_entries, lg_str, 'Location', 'SouthEast', 'Interpreter', ...
             'Latex', 'AutoUpdate', 'off');

xlabel('Average sample span per $\beta$-test', 'Interpreter', 'Latex');
yl2 = ylabel('Probability of rejecting $\mathrm{H}_{0}$', 'Interpreter', 'Latex');

box on
grid on
ha2.TickDir = 'out';
xticks([1 10:10:100])

latimes
axesfs(f2, 9, 13)
lg2.FontSize = 10;

if bias == true
    savepdf('fig11')
else
    savepdf(['fig11_unbiased'])
end

if bias == true
    left68_samp    % km restricted
    right68_samp   % kw unrestricted
    left95_samp    % km unrestricted
    right95_samp   % kw unrestricted
end

%__________________________________________________________
function varargout = cpm2_local(alphas, iters, lx, bp, dist1, p1, ...
                                dist2, p2, abso, dtrnd, restrikt, ...
                                plt, x, bias)
%
%
% Parallel version of cpm2.m, specifically, the waterlvls.m tests.
% See the cpm2.m for I/O.  Copied locally here (and Parallelized) so
% this script works in perpetuity.
%
% Last modified in Ver. 2017b by jdsimon@princeton.edu, 27-Apr-2018.

% Defaults --  commented out because I don't want to accidentally
% use defaults without being aware.
% Possible inputs.
% defval('alphas', [0:0.1:100])
% defval('iters', 1)
% defval('lx', 1000)
% defval('bp', 500)
% defval('dist1', 'norm')
% defval('p1', {0 1})
% defval('dist2', 'norm')
% defval('p2', {0 2})
% defval('abso', false)
% defval('dtrnd', false)
% defval('restrikt', false)
% defval('plt', false)
% defval('x', [])
% defval('bias', true)

% Possible outputs.
defval('f1', [])
defval('f2', [])
defval('f3', [])

% Use supplied x for plots?
if ~isempty(x)
    warning(['Using supplied x for plotting; ensure fits same model ' ...
             'parameters as that which is being tested'])
    xend = x;
end

% Fair warning.
if dtrnd
    warning(sprintf(['dtrnd option makes this crawl because it ' ...
                     'defaults cpest.m to use ''slow'' algo;\n''fast'' ' ...
                     'algo uses cumstats.m which doesn''t currently ' ...
                     'support indexed detrending.']))
end

% Initialize outputs.
km_count = zeros(1,length(alphas));
kw_count = km_count;
km_range = km_count;
kw_range = km_count;

% For each iteration test all alphas. Keep of number of times
% estimate within range of waterlvl/bar by summing.
for i = 1:iters
    % Generate time series and calculate AIC function.  Here's the switch
    % in case x is supplied; maybe use a supplied time series for last

    if exist('xend') && i == iters(end)
        x = xend;
    else
        x = cpgen(lx,bp,dist1,p1,dist2,p2);
    end

    % Use absolute values, if requested.
    if abso
        x = abs(x);
    end

    % Estimate the changepoint.
    [kw, km, aicx] = cpest(x, 'fast', dtrnd, bias);
    ykw = aicx(kw);
    ykm = aicx(km);

    % Question: is bp (truth) within spread below the waterlvl?
    % --have since written waterlvlsalpha which does both concurrently.
    parfor j = 1:length(alphas)
        [xl_km(j),xr_km(j)] = waterlvlalpha(aicx,alphas(j),km,restrikt);
        [xl_kw(j),xr_kw(j)] = waterlvlalpha(aicx,alphas(j),kw,restrikt);
    end

    % Keep track of the spread; I want to know how an alpha corresponds to
    % a sample spread. Sum them all up and then divide by iters for an
    % average of the spread at each alpha. Add 1 to x(right) - x(left)
    % because if they are the same sample the test sees 1 sample, not
    % zero samples.
    km_range = km_range + (xr_km - xl_km + 1);
    kw_range = kw_range + (xr_kw - xl_kw + 1);

    % If truth within range returned by waterlvl/bar, add +1 to
    % the total count (rhs after '+' will be 1 if true).
    km_count = km_count + (xl_km <= bp & bp <= xr_km);
    kw_count = kw_count + (xl_kw <= bp & bp <= xr_kw);
end

% Average range of samples spanned by each test.
km_range = km_range ./ iters;
kw_range = kw_range ./ iters;

% Plot it, maybe.
if plt
    f1 = plotcpm2(alphas,bp,aicx,km,ykm,kw,ykw,restrikt);
    [f2,f3] = plotcpm2s(alphas,km_count,kw_count,iters,km_range,kw_range);
end

% Collect output.
varns = {km_count,kw_count,km_range,kw_range,f1,f2,f3};
varargout = varns(1:nargout);

end
