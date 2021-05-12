function fig8b
% FIG8b
%
% Plots a record section for ID 10964158 showing the arrival of core-phases.
%
% Marks the specific arrival-times (t_AIC) found in and adjusted ak135 model via
% firstarrival.m centered on the theoretical arrival time of PKPbc (as is done
% in fig9.m; see comments here and there for further explanation).
%
% Developed as: simon2021_PKPRS
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 24-Jan-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

% Define paths.
merdir = getenv('MERMAID');
evtdir = fullfile(merdir, 'events');
procdir = fullfile(merdir, 'processed');
nearbydir = fullfile(evtdir, 'nearbystations');

% Ensure in GJI21 git branch -- complimentary paper w/ same data set.
startdir = pwd;
cd(evtdir)
system('git checkout GJI21');
cd(procdir)
system('git checkout GJI21');
cd(startdir)

% `firstarrival` and `recordsection` inputs.
wlen = 30;
lohi = [1 2];
ci = true;
bathy = true;
wlen2 = 1.75;
fs = [];
popas = [4 1];

alignon = 'etime';
ampfac = 2;
normlize = true;
returntype = 'DET';
popas = [4 1];
taper = 2;

% Plot the baseline record section, to be edited and annotated.
id = 10964158;
[F, EQ, sac] = recordsection(id,  lohi, alignon, ampfac, evtdir, procdir, ...
                             normlize, returntype, [], popas, taper);

axesfs(F.f, 15, 15);
F.txhz.String = sprintf('%.0f--%.0f Hz', lohi);
F.txhz.FontSize = 18;
xlim(F.ax, [1170 1230])
ylim(F.ax, [144 156])
F.ax.YTickLabel = cellfun(@(xx) [xx '$^{\circ}$'], F.ax.YTickLabel, 'UniformOutput', false)

% Color the ab and bc branches of PKP separately.
PKP_y = F.ph(2).YData;
PKP_x = F.ph(2).XData;

[~, caustic] = min(PKP_y);

PKPab_x = PKP_x(1:caustic);
PKPab_y = PKP_y(1:caustic);

PKPbc_x = PKP_x(caustic:end);
PKPbc_y = PKP_y(caustic:end);

hold(F.ax, 'on')
pl_PKPab = plot(F.ax, PKPab_x, PKPab_y, '-m', 'LineWidth', 1);
pl_PKPbc = plot(F.ax, PKPbc_x, PKPbc_y, '-g', 'LineWidth', 1);

% Edit the PKIKP and PKiKP phase branch colors and lines.
pl_PKIKP = F.ph(1);
pl_PKiKP = F.ph(3);

delete(F.ph(2))
delete(F.lg)

set(F.pltr, 'Color', 'k')
set(pl_PKIKP, 'Color', 'b', 'LineStyle', '-', 'LineWidth', 1)
set(pl_PKiKP, 'Color', 'r', 'LineStyle', '-', 'LineWidth', 1)


%%______________________________________________________________________________________%%
%%         Annotate 4 of the arrivals whose residuals are plotted in fig9.m             %%
%%______________________________________________________________________________________%%

% Long notes to self because this was slightly confusing to work out...
%
% NB, in fig9.m we find the travel time residual w.r.t PKPbc (I force the PKPbc
% phase to be the only .TaupTimes phase-field associated with the EQ structure)
% in the ADJUSTED (bathy = true) ak135 model.  Here, I want to mark that
% residual found under those conditions (the 30 s window gets shifted w.r.t. to
% the unadjusted model, for example) on an underlying record section where
% theoretical phase branches are from the unadjusted ak135 model.  This is no
% problem because the actual arrival time output of firstarrival.m, 'dat', in
% code, or 't_AIC', in my paper, is in reference to time of the seismogram, not
% any theoretical (adjusted or not) time (the arrival time in real life is the
% arrival time; no model, adjusted or not, is involved...these are data).  So
% there is no problem there -- I do not have to adjust 'dat' (other than
% changing its zero time to be in reference to the event time as opposed to the
% xaxis(h.NPTS, h.DELTA, h.B) native to firstarrival.m).
%
% Also, I cannot adjust the theoretical phase arrival-time branches plotted here
% because each theoretical arrival time gets an individual adjustment
% corresponding to each MERMAID due to the bathymetry and depth at/of that
% specific MERMAID at the time of the recording.  Ergo, there is no single
% adjustment that can be globally applied to the entire phase branch.  SO LEAVE
% THE BASE FIGURE'S PHASE BRANCHES UNADJUSTED.

for i = 1:length(sac)
    % Compute travel time residual w.r.t. PKPbc (as is done in fig9.m).
    PKPbc_EQ = EQ{i};

    % The first occurrence of 'PKP' phase name is the bc branch (EQ travel times
    % are sorted).
    PKPbc_idx = cellstrfind({EQ{i}.TaupTimes.phaseName}, 'PKP');

    % This ensures the only .TaupTimes associated with this EQ structure is the
    % PKPbc branch.
    PKPbc_EQ.TaupTimes = EQ{i}.TaupTimes(PKPbc_idx(1));

    % Compute the travel time residual w.r.t PKPbc as is done in fig9.m
    % using the ADJUSTED ak135 model.
    [tres(i), dat] = firstarrival(PKPbc_EQ.Filename, false, wlen, lohi, [], ...
                                  [], PKPbc_EQ, bathy, wlen2, fs, popas);

    % Shift the reference of that arrival time from the seismogram time
    % (xaxis(h.NPTS, h.DELTA, h.B)) so that 0 s occurs at the time of the event.
    [~, h] = readsac(sac{i});
    seisdate = seistime(h);

    % In absolute (datetime) terms.
    evt_time = irisstr2date(EQ{i}.PreferredTime);
    arr_time = seisdate.B + seconds(dat);

    % Where 0 s is the time of the event.
    t_AIC(i) = seconds(arr_time - evt_time);

    % Find the sample (x value) corresponding to that arrival time (we don't have to
    % worry about possible multiple results because time monotonically
    % increases; we aren't finding a y value (amplitude), of which there could
    % be multiple of the same magnitude in the seismogram -- find.m is
    % sufficient.
    xax = xaxis(h.NPTS, h.DELTA, h.B);

    % Via firstarrival.m --> timewindow.m: 'dat', the arrival time', is in reference to
    % an x-axis as defined above.
    arr_samp = find(xax == dat);
    wiggles = F.pltr(i).YData;
    arr_yval = wiggles(arr_samp);

    % Plot the actual (observed, AIC) arrival time.
    pl_t_AIC1 = plot(F.ax, t_AIC(i), arr_yval, 'kx', 'MarkerSize', 14, ...
                     'MarkerFaceColor', 'k', 'LineWidth', 2);

end
hold(F.ax, 'off')

% Cosmetics.
lg = legend([pl_t_AIC1 pl_PKIKP pl_PKPbc pl_PKiKP pl_PKPab], '$t_{{}_\mathrm{AIC}}$', ...
            '\textit{PKIKP}', '\textit{PKPbc}', '\textit{PKiKP}', '\textit{PKPab}', ...
            'Location', 'NorthWest');

axesfs(F.f, 20, 20)
botz([pl_PKIKP pl_PKPab pl_PKiKP pl_PKPbc]);

% Shift MERMAID serial numbers outside of axis.
for i = 1:length(F.pltx)
    F.pltx(i).Position(1) = 1232;
    F.pltx(i).Color = 'k';

end
latimes

% Add labels.
[lgp, txp] = textpatch(F.ax, 'NorthWest', '(b)', 25, 'Helvetica', false);
lgp.Box = 'off';
movev(lgp, 0.12);
moveh(lgp, -0.1375);
savepdf(mfilename)

% Print the SAC filenames which are marked here so that I may also note them on
% fig8a.m.
fprintf('Here are the SAC files just plotted --\n')
cellfun(@strippath, sac, 'UniformOutput', false)'
