function fig3
% FIG3
%
% Plots a Rayleigh wave.
%
% Developed as: simon2021_surfacewave
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 07-May-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

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

ha = axes;
fig2print([], 'flandscape')
shrink(ha, 1, 2.5);

% Surface wave.
s = fullsac('20191206T130408.08_5DF32AF0.MER.DET.WLT5.sac', procdir);

% Compute theoretical arrival time of surface waves.
EQ = getevt(s, evtdir);
[x, h] = readsac(s);

% Compute the arrival time of the surface wave (note that, even though I include
% it, the event depth is not considered for a horizontal phase).
evtdate = irisstr2date(EQ.PreferredTime);
evla = EQ.PreferredLatitude;
evlo = EQ.PreferredLongitude;
evdp = EQ.PreferredDepth;
tt = arrivaltime(h, evtdate, [evla evlo], 'ak135', evdp, '3.5kmps', h.B);
clc % clear taupTime warning

x = detrend(x, 'constant');
x = detrend(x, 'linear');

xax = xaxis(h.NPTS, h.DELTA, h.B);
pl = plot(xax, x, 'k', 'LineWidth', 1);
ylim([-5e7 5e7])

% This time is w.r.t. the reference time in the SAC header, NOT
% seisdate.B. 'xax' has the time of the first sample (input: pt0) assigned to
% h.B, meaning it is an offset from some reference (in this case, the reference
% time in the SAC header).  The time would be relative to seisdate.B if I had
% input pt0 = 0, because seisdate.B is EXACTLY the time at the first sample,
% i.e., we start counting from 0 at that time.
[~, ~, ~, refdate] = seistime(h);
xl = xlabel(sprintf('Time relative to %s UTC (s)\n',  datestr(refdate)));
yl = ylabel('Counts');

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
vl2 = plot(repmat(EQ.TaupTimes(18).truearsecs, 2, 1), ylim, 'k--', 'LineWidth', 1); % S
vl3 = plot(repmat(tt(1).truearsecs, 2, 1), ylim, 'r', 'LineWidth', 1); % S

lg = legend([vl1 vl2 vl3], ...
            sprintf('\\textit{%s} wave', EQ.TaupTimes(1).phaseName), ...
            sprintf('\\textit{%s} wave', EQ.TaupTimes(18).phaseName), ...
            'Rayleigh wave (3.5 km/s)', ...
            'Location', 'NorthWest');
numticks(ha, 'y', 5);

latimes
[lgtx, tx] = textpatch(ha, 'SouthWest', sprintf('Detrended\n(MERMAID: 08)'));
lgtx.Box = 'off';
longticks(ha, 3)

axesfs([], 18, 18)
lgtx.FontSize = 16;
tx.FontSize = 16;

xticks(gca, [0:20:250])
savepdf(mfilename)
EQ

% Print the catalog these event metadata were culled from
fprintf('\n')
[~, contrib_author, ~] = eventid(EQ)
