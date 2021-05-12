function fig10
% FIG10
%
% Plots a single MERMAID seismogram showing two unidentified local events.
%
% Developed as: simon2021_local.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 29-Apr-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

% Define paths.
merdir = getenv('MERMAID');
evtdir = fullfile(merdir, 'events');
procdir = fullfile(merdir, 'processed');

% Ensure in GJI21 git branch -- complimentary paper w/ same data set.
startdir = pwd;
cd(evtdir)
system('git checkout GJI21');
cd(procdir)
system('git checkout GJI21');
cd(startdir)

% Unidentified local(s)
% (re-reverified 03-May-2021 that there are no matching events)
s = '20190705T091235.08_5D1F627A.MER.DET.WLT5.sac';

lohi = [3 5];
popas = [4 1];

ha = axes;
fig2print([], 'flandscape');
shrink(ha, 1, 2.5);

[x, h] = readsac(fullsac(s, procdir));

x = detrend(x, 'constant');
x = detrend(x, 'linear');
x = bandpass(x, efes(h), lohi(1), lohi(2), popas(1), popas(2), 'butter');

xax = xaxis(h.NPTS, h.DELTA, h.B);
pl = plot(xax, x, 'k', 'LineWidth', 0.25);
ylim([-8e5 8e5])
numticks(ha, 'y', 5);
xlim([0 xax(end)])

% This time is w.r.t. the reference time in the SAC header, NOT
% seisdate.B. 'xax' has the time of the first sample (input: pt0) assigned to
% h.B, meaning it is an offset from some reference (in this case, the reference
% time in the SAC header).  The time would be relative to seisdate.B if I had
% input pt0 = 0, because seisdate.B is EXACTLY the time at the first sample,
% i.e., we start counting from 0 at that time.
[~, ~, ~, refdate] = seistime(h);
xl = xlabel(sprintf('Time relative to %s UTC (s)', datestr(refdate)));
yl = ylabel('Counts');

% Add AIC arrival times using 30 s windows centered on 80 and 140 s.
arrival1 = makepick(x, 80, h);
arrival2 = makepick(x, 140, h);

hold(ha, 'on')
plar1 = plot(ha, [arrival1 arrival1], ha.YLim, 'r--');
plar2 = plot(ha, [arrival2 arrival2], ha.YLim, 'r');
hold(ha, 'off')

botz([plar1 plar2])

lg = legend([plar1 plar2], '\textit{p} wave: 1$^\mathrm{st}$ event', ['\textit{p} ' ...
                    'wave: 2$^\mathrm{nd}$ event'], 'Location', 'NorthWest');

axesfs([], 18, 18)
latimes
[lgtx, tx] = textpatch(ha, 'SouthWest', sprintf('%i--%i Hz\n(MERMAID: 08)', lohi(1), lohi(2)));
lgtx.Box = 'off';
tx.FontSize = 16;
lgtx.FontSize = 16;

ha.XTick = [0:20:xax(end)];
longticks(ha, 3)
savepdf(mfilename)

%%______________________________________________________________________________________%%

function arrival_time = makepick(x, pivot, h)
% NB by my definition the arrival time is the offest when pt0 = 0 s; technically
% h.B s 5.6600e-04, which is 0 for all intents and purposes so I'm calling it
% the arrival time.
[xw, W] = timewindow(x, 30, pivot, 'middle', h.DELTA, h.B);

% Changepoint time in samples in windowed portion.
cp = cpest(xw, 'fast', false, true);

% Arrival sample is the changepoint sample plus one index.
arrival_samp = cp + 1;

% Arrival time.
arrival_time = W.xax(arrival_samp);
