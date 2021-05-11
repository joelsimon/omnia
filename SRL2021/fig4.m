function fig4
% FIG4
%
% Plots a T wave.
%
% Developed as: simon2021_twave
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 06-May-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

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

% T wave.
s = fullsac('20200215T093807.08_5E4808BE.MER.DET.WLT5.sac', procdir)

lohi = [5 10];
popas = [4 1];

ha = axes;
fig2print([], 'flandscape')
shrink(ha, 1, 2.5);

% Compute theoretical arrival time of surface waves.
EQ = getevt(s, evtdir);
[x, h] = readsac(s);

evtdate = irisstr2date(EQ.PreferredTime);
evla = EQ.PreferredLatitude;
evlo = EQ.PreferredLongitude;
evdp = EQ.PreferredDepth;
tt = arrivaltime(h, evtdate, [evla evlo], 'ak135', evdp, '1.5kmps', h.B);
clc % clear taupTime warning

x = detrend(x, 'constant');
x = detrend(x, 'linear');
x = bandpass(x, efes(h), lohi(1), lohi(2), popas(1), popas(2), 'butter');

xax = xaxis(h.NPTS, h.DELTA, h.B);
pl = plot(xax, x, 'k', 'LineWidth', 1);
ylim([-1.2e7 1.2e7])
xlim([0 xax(end)])

% This time is w.r.t. the reference time in the SAC header, NOT
% seisdate.B. 'xax' has the time of the first sample (input: pt0) assigned to
% h.B, meaning it is an offset from some reference (in this case, the reference
% time in the SAC header).  The time would be relative to seisdate.B if I had
% input pt0 = 0, because seisdate.B is EXACTLY the time at the first sample,
% i.e., we start counting from 0 at that time.
[~, ~, ~, refdate] = seistime(h);
xl = xlabel(sprintf('Time relative to %s UTC (s)', datestr(refdate)));
yl = ylabel('Counts')

% Add event info to title.
evttime = EQ.PreferredTime;
magtype = EQ.PreferredMagnitudeType;
if ~strcmpi(magtype(1:2), 'mb')
    magstr = sprintf('\\textit{%s}$_{\\mathrm{%s}}$ %2.1f', upper(magtype(1)), ...
                     lower(magtype(2)), EQ.PreferredMagnitudeValue);

else
    magstr = sprintf('\\textit{%s}$_{\\mathrm{%s}}$ %2.1f', lower(magtype(1)), ...
                     lower(magtype(2:end)), EQ.PreferredMagnitudeValue);

end
depthstr = sprintf('%2.1f km depth', EQ.PreferredDepth);
locstr = titlecase(EQ.FlinnEngdahlRegionName, {'of'});
diststr = sprintf('%.1f$^{\\circ}$', EQ.TaupTimes(1).distance);
F.tl = title([magstr ' ' locstr ' at ' depthstr ' and ' diststr]);

hold on
vl1 = plot(repmat(EQ.TaupTimes(1).truearsecs, 2, 1), ylim, 'k', 'LineWidth', 1);  % P
vl2 = plot(repmat(tt(1).truearsecs, 2, 1), ylim, 'r', 'LineWidth', 1); % T

lg = legend([vl1 vl2], '\textit{P} wave', '\textit{T} wave (1.5 km/s)', 'Location', 'NorthWest')
numticks(ha, 'y', 5);

latimes
[lgtx, tx] = textpatch(ha, 'SouthWest', sprintf('%i--%i Hz\n(MERMAID: 08)', lohi(1), lohi(2)));
lgtx.Box = 'off';
longticks(ha, 3)

axesfs([], 18, 18)
lgtx.FontSize = 16;
tx.FontSize = 16;

ha.XTick = [0:20:xax(end)];
savepdf(mfilename)
EQ

% Print the catalog this event metadata was culled from
fprintf('\n')
[~, contrib_author, ~] = eventid(EQ)
