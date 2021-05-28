function fig7
% FIG7
%
% Plots fig7.pdf and fig7_ambiguous.pdf for two (of 12 total) core-phase
% seismograms in the data set prepared for (our GJI paper ??), but not used
% there because that focused only on P waves.
%
% The ambiguous case is due to it being 0.1 degrees away from the caustic in
% ak135; i.e., the arrival is a phase bundle and not a clear and separate PKIKP.
% The non-ambiguous case is multiple degrees away from the caustic and thus I am
% more confident in it.
%
% A TauP travel-time curve (*taupCurve*.pdf) is plotted for both to see this
% fact.
%
% Developed as: simon2021_PKIKP.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 27-May-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

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

% firstarrival.m parameters.
wlen = 30;
lohi = [1 2];
ci = true;
bathy = true;
wlen2 = 1.75;
fs = [];
popas = [4 1];

% Gebco version number
gebco_vers = '2014';

% PKIKP wave.
s = {'20191023T162621.11_5DB247CE.MER.DET.WLT5.sac' ...
     '20191220T115726.16_5E0574F1.MER.DET.WLT5.sac'};

for i = 1:length(s)
    ha = axes;
    fig2print([], 'flandscape')
    shrink(ha, 1, 2.5);

    sac = fullsac(s{i}, procdir);
    [~, h] = readsac(sac);

    %% Core phases were not included in the firstarrival* (supplemental to GJI)
    %% text files, so there is no 2SD_err value to supply to this; it will differ
    %% slightly each time
    [f, ax, tx, pl, FA] = plotfirstarrival(sac, ha, [], [], ci, wlen, lohi, ...
                                           [], [], true, wlen2, fs, popas);

    pl.signal.Color = 'k';
    ax.YLabel.String = 'Counts';
    set(pl.syn, 'Color', 'blue', 'LineWidth', 1, 'LineStyle', '-')
    set([pl.dat pl.dat_minus pl.dat_plus], 'Color', 'k', 'LineWidth', pl.syn.LineWidth)

    ax.XLabel.String{2} = []

    % Delete the cirled max value and the note in the title.
    delete(pl.maxc)
    bracket = strfind(ax.Title.String, '[');
    ax.Title.String = ax.Title.String(1:bracket-2)

    % Add MERMAID number to title.
    period = strfind(s{i}, '.');
    mernum = s{i}(period+1:period+2);
    ax.Title.String = [ax.Title.String sprintf(' (MERMAID: %s)', mernum)];

    longticks(ax, 4);
    axesfs(f, 18, 18);
    latimes

    pause(0.1)
    tack2corner(ax, tx.ul, 'ul')
    pause(0.1)
    tack2corner(ax, tx.ur, 'ur')
    pause(0.1)
    tack2corner(ax, tx.lr, 'lr')
    pause(0.1)
    tack2corner(ax, tx.ll, 'll')

    EQ = getevt(fullsac(s{i}, procdir), evtdir)

    % Print the catalog these event metadata were culled from
    fprintf('\n')
    [~, contrib_author, ~] = eventid(EQ)

    if i == 1
        str = '_ambiguous';

    else
        str = [];

    end

    % Ensure that any updates haven't added / removed / reorded expected phases.
    if length(EQ.TaupTimes) ~= 2 || ~strcmp(EQ.TaupTimes(1).phaseName, 'PKIKP') || ...
            ~strcmp(EQ.TaupTimes(2).phaseName, 'PKiKP')
        error('Expected only two phases: PKIKP and PKiKP')

    end

    % Add the theoretical arrival time of PKiKP -- in this PKIKP-centered window it
    % is just the difference between it and PKIKP.
    z_ocean = gebco(h.STLO, h.STLA, gebco_vers);
    z_mermaid = -h.STDP;

    PKIKP_tadj = bathtime('ak135', 'PKIKP', EQ.TaupTimes(1).incidentDeg, ...
                          z_ocean, z_mermaid);
    PKiKP_tadj = bathtime('ak135', 'PKiKP', EQ.TaupTimes(2).incidentDeg, ...
                          z_ocean, z_mermaid);

    PKIKP_syn_tadj = EQ.TaupTimes(1).time + PKIKP_tadj;
    PKiKP_syn_tadj = EQ.TaupTimes(2).time + PKiKP_tadj;

    PKiKP_delay = PKiKP_syn_tadj - PKIKP_syn_tadj

    hold(ax, 'on')
    pl_PKiKP = plot(ax, [PKiKP_delay PKiKP_delay], ax.YLim, 'r', 'LineWidth', ...
                    pl.syn.LineWidth);
    hold(ax, 'off')
    botz(pl_PKiKP);
    ax.XTick = [-15:5:15]

    % Plot the associated travel-time curve.
    taupTime('ak135', EQ.PreferredDepth, 'PKIKP, PKP, PKiKP', 'deg', ...
             EQ.TaupTimes(1).distance)
    figure
    taupCurve('ak135', EQ.PreferredDepth, 'PKIKP, PKP, PKiKP');
    dist = EQ.TaupTimes(1).distance;
    xlim([dist-5 dist+5])
    set(findall(gcf, 'type', 'legend'), 'AutoUpdate', 'off')
    vertline(dist, gca, 'k--');
    savepdf(sprintf('%s_taupCurve%s', mfilename, str))
    close

    if i == 2
        ylim(ha, [-3e5 3e5])
        yticks(ha, -3e5:3e5:3e5)

    end

    % Replace "2SD" with "2Std.Dev."
    old = '2${\mathrm{SD}}_\mathrm{err}$';
    new = '2${\mathrm{St.Dev\hspace{-.1em}.}}_\mathrm{err}$';
    tx.lrth.String = strrep(tx.lrth.String, old, new);

    % Replace "SNR=9.9e+00" with "SNR=9.9"
    old = 'e+00';
    new = '';
    tx.llth.String = strrep(tx.llth.String, old, new);

    tx.ulth.FontSize = 14;
    tx.urth.FontSize = 14;
    tx.lrth.FontSize = 14;
    tx.llth.FontSize = 14;

    savepdf(sprintf('%s%s', mfilename, str), f);
    close

    fprintf('Filename: %s\n', strippath(sac))
    fprintf('Gebco %s depth: %i\n', gebco_vers, z_ocean)
    fprintf('MERMAID depth: %i\n', z_mermaid)

end
