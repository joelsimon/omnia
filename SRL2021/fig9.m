function tres = fig9(ref_time, plt)
% tres = FIG9(ref_time, plt)
%
% Plots travel time residual of core-arrivals vs PKPbc, and the theoretical
% differential travel time between core phases and PKPbc, both corrected for
% bathymetry and MERMAID cruising depth (i.e., in the adjusted ak135 model).
%
% Note that the colors and/or symbols differ between the two reference time
% options.
%
% Input:
% ref_time    The reference time for the zero-line (def: 'actual_arrival')
%             'actual_arrival': all times are residuals w.r.t. the actual
%                               arrival time (actual arrival time at 0 s)
%             'theoretical_PKPbc': all times are residuals w.r.t. the theoretical
%                                  arrival time of PKPbc in the adjusted ak135
%                                  model (theoretical PKPbc arrival time at 0 s)
% plt         Generate firstarrival.m plots for each PKPbc seismogram (def: false)
%
% Developed as: simon2021_PKPres.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 12-May-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

% Defaults.
defval('ref_time', 'actual_arrival')
defval('plt', false)

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

%% Load all events until end of 2019.
enddate = datetime('31-Dec-2019 23:59:59.999', 'TimeZone', 'UTC');
idfile = fullfile(evtdir, 'reviewed', 'identified', 'txt', 'identified.txt');
incl_prelim = false;

% reftime = 'SAC' in keeping with readevt2txt.m restriction barring 'EVT'
[s, ~, ~, ~, ~, ~, ~, ~, ph] = readidentified(idfile, [], enddate, 'SAC', ...
                                              'DET', incl_prelim);

% Find those which contain PK* (core phase).
idx = find(contains(ph, 'PK'));
s = s(idx);

%% Load the corresponding event structures and find the TaupTime corresponding to PKP.
idx = 0;
for i = 1:length(s)
    tmp_EQ = getevt(fullsac(s{i}, procdir), evtdir);

    % If the EQ structure contains no PKP arrival, ditch it.
    if ~any(contains({tmp_EQ.TaupTimes.phaseName}, 'PKP'))
        fprintf('Contains core, but no PKP -- ditched: %s\n', tmp_EQ.Filename)
        tmp_ph = {tmp_EQ.TaupTimes.phaseName};
        fprintf('Phase: %s\n', tmp_ph{:})
        fprintf('Dist:  %.2f deg\n', tmp_EQ.TaupTimes(1).distance) % distance same for all phases
        fprintf('Depth: %.2f km\n', tmp_EQ.PreferredDepth) % depth same for all phases
        fprintf('\n')

        if plt
            [f, ax, tx] = plotfirstarrival(tmp_EQ.Filename, [], [], tmp_EQ, ...
                                           ci, wlen, lohi, [], [], true, wlen2, ...
                                           fs, popas);
            ax.YLabel.String = strrep(ax.YLabel.String, 'Amplitude', 'Counts');
            numticks(ax, 'x', 7);

            pause(0.1)
            tack2corner(ax, tx.ul, 'ul')
            pause(0.1)
            tack2corner(ax, tx.ur, 'ur')
            pause(0.1)
            tack2corner(ax, tx.lr, 'lr')
            pause(0.1)
            tack2corner(ax, tx.ll, 'll')

            savepdf(sprintf('%s_ditched_no_PKP_%s', mfilename, tmp_EQ.Filename), f)
            close

        end
        continue

    else
        idx = idx + 1;
        EQ(idx) = tmp_EQ;

    end
end

% Clear the SAC filenames because now that list includes non-PKP arrivals (the
% relevant, retained filenames are in the EQ structures).
clear('s')

%% For each event, sort the arrival times by phase name. Compute
%% bathymetric/cruising depth correction for all phases.

PKIKP = NaN(length(EQ), 1);
PKPbc = NaN(length(EQ), 1);
PKPab = NaN(length(EQ), 1);
PKiKP = NaN(length(EQ), 1);

for i = 1:length(EQ)
    % Distance is the same for each phase-arrival -- it's one event.
    dist(i) = EQ(i).TaupTimes(1).distance;

    % Get the header info for this SAC file.
   [~, h] = readsac(fullsac(EQ(i).Filename, procdir));

    % I know these all include PKPab and PKPbc arrivals because I've looked. PKPbc
    % dies off around ~155 degrees; these are all below that. PKPbc always
    % arrives first (dives deeper; feels faster), therefore "isbc" is true for
    % the first of the two PKP arrivals.
    isbc = true;
    for j = 1:length(EQ(i).TaupTimes)
        ph_name = EQ(i).TaupTimes(j).phaseName;
        ar_time = EQ(i).TaupTimes(j).truearsecs;

        % Adjust the time for bathymetry and MERMAID cruising depth.
        z_ocean = gebco(h.STLO, h.STLA);
        if h.STDP == -12345 || isnan(h.STDP)
            z_mermaid = -1500;

        else
            z_mermaid = -h.STDP;

        end

        %% Compute this adjustment for every phase that theoretically arrives in the time
        %% window of the seismogram.  They will all be about equal, but they will
        %% have slight differences due to the different incident angles.
        tadj = bathtime(EQ(i).TaupTimes(j).model, ph_name, ...
                        EQ(i).TaupTimes(j).incidentDeg, z_ocean, z_mermaid);

        ar_time = ar_time + tadj;

        %% Sort phase arrivals by phase name.
        switch ph_name
          case 'PKIKP'
            PKIKP(i) = ar_time;

          case 'PKP'
            if isbc % the first PKP arrival is always the bc branch
                PKPbc(i) = ar_time;
                PKPbc_idx(i) = j; % save the index of PKPbc -- center firstarrival there
                isbc = false;     % next time the phase is PKP it is PKPab (arrives later)

            else
                PKPab(i) = ar_time;

            end

          case 'PKiKP'
            PKiKP(i) = ar_time;

          otherwise
            error('Unexpected phase arrival')

        end
    end
end

%% Compute the THEORETICAL differential travel time residuals w.r.t. PKPbc.
dPKIKP = PKIKP - PKPbc;
dPKPab = PKPab - PKPbc;
dPKiKP = PKiKP - PKPbc;

% Sort by distance.
[~, sidx] = sort(dist);
PKPbc_idx = PKPbc_idx(sidx);
EQ = EQ(sidx);
dist = dist(sidx);
dPKIKP = dPKIKP(sidx);
dPKPab = dPKPab(sidx);
dPKiKP = dPKiKP(sidx);

% Get the public IDs to plot some record sections.
for i = 1:length(EQ)
    ID{i} = fx(strsplit(EQ(i).PublicId, '='),  2);

end
ID = unique(ID);

%% Compute the first-arrival residual where PKPbc arrival time is considered the first arrival.
if plt
    for i = 1:length(ID)
        recordsection(ID{i}, lohi, 'etime')
        savepdf(sprintf('rs_%s', ID{i}))
        close

    end
end

for i = 1:length(EQ)
    % This ensures that the ONLY (and therefore, the first) arrival in the EQ
    % structure is PKPbc.
    first_arr_PKP_EQ  = EQ(i);
    first_arr_PKP_EQ.TaupTimes = EQ(i).TaupTimes(PKPbc_idx(i));

    % Compute residual, corrected for bathymetry and cruising depth.
    [tres(i), dat(i)] = firstarrival(first_arr_PKP_EQ.Filename, false, wlen, ...
                                     lohi, [], [], first_arr_PKP_EQ, bathy, ...
                                     wlen2, fs, popas);

    % Keep track of the travel time to list a final range to put the mean
    % residual in context.
    ttime(i) = first_arr_PKP_EQ.TaupTimes.time;

    if plt
        % Plot the individual residuals.
        [f, ax, tx] = plotfirstarrival(first_arr_PKP_EQ.Filename, [], [], ...
                                   first_arr_PKP_EQ, ci, wlen, lohi, [], [], ...
                                   true, wlen2, fs, popas);
        ax.YLabel.String = strrep(ax.YLabel.String, 'Amplitude', 'Counts');
        ax.XLabel.String = strrep(ax.XLabel.String, 'PKP', 'PKPbc');
        numticks(ax, 'x', 7);

        pause(0.1)
        tack2corner(ax, tx.ul, 'ul')
        pause(0.1)
        tack2corner(ax, tx.ur, 'ur')
        pause(0.1)
        tack2corner(ax, tx.lr, 'lr')
        pause(0.1)
        tack2corner(ax, tx.ll, 'll')

        savepdf(sprintf('%s_%s', mfilename, EQ(i).Filename), f)
        close

    end
end

% Print the arrival times using the PKPbc-centered windows for direct
% comparisons with with arrival times found in PKIKP-centered windows
% (simon2021_PKIKPres.m).  Note that these times are in reference to
% xaxis(h.NPTS, h.DELTA, h.B).
datadir = fullfile(getenv('SRL21_CODE'), 'data');
[~, foo] = mkdir(datadir);
fname = fullfile(datadir, sprintf('%s.txt', mfilename));
fid = fopen(fname, 'w');
fprintf(fid, '%s: arrival time of PKPbc-centered firstarrival.m\n', mfilename)
fmt = '%44s    %.2f (s)\n';
for i = 1:length(PKIKP)
    fprintf(fid, fmt, EQ(i).Filename, dat(i));

end
fclose(fid);

%%______________________________________________________________________________________%%

figure
ha = gca;
hold on

xlim([144 154])

switch ref_time
  case 'theoretical_PKPbc'
    %% Plot the theoretical differential vs PKPbc and the OBSERVED differential
    %% (tres); both corrected for bathymetry and MERMAID cruising depth.

    pPKPbc = plot(xlim, [0 0], 'k');
    pPKIKP = plot(dist, dPKIKP, 'b:o', 'MarkerSize', 8, 'MarkerFaceColor', 'w');
    pPKiKP = plot(dist, dPKiKP, 'm:o', 'MarkerSize', 8, 'MarkerFaceColor', 'w');
    pPKPab = plot(dist, dPKPab, 'g:o', 'MarkerSize', 8, 'MarkerFaceColor', 'w');
    ptres = plot(dist, tres, 'diamond', 'Color', 'k', 'MarkerFaceColor', 'k', 'MarkerSize', 10);

    lg = legend([ptres pPKPbc pPKPab pPKiKP pPKIKP], '$t_{\mathrm{res}}^{\star}$', ...
                '$\Delta$\textit{PKPbc}', '$\Delta$\textit{PKPab}', ...
                '$\Delta$\textit{PKiKP}', '$\Delta$\textit{PKIKP}', 'Location', ...
                'NorthWest')

    ylabel('Residual w.r.t. adjusted \textit{PKPbc} arrival time (s)')
    text(144.5, -6.5, sprintf('Mean($t_\\mathrm{res}^{\\star}$) = %.2f s', mean(tres)))
    ylim([-8 12])
    yticks([-8:2:12])

  case 'actual_arrival'
    dPKPbc = PKPbc - PKPbc;  % Differential residual of PKPbc with itself; i.e., 0.
    pzero = plot(xlim, [0 0], 'k-');

    % `tres-tres` is obviously 0; done here for dimension; really this is just to
    % mark the actual epicentral distances at which we recorded data.
    pPKIKP = plot(dist, dPKIKP-tres(:), 'd', 'MarkerSize', 10, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k');
    pPKPbc = plot(dist, dPKPbc-tres(:), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k');
    pPKiKP = plot(dist, dPKiKP-tres(:), '^', 'MarkerSize', 10, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k');
    pPKPab = plot(dist, dPKPab-tres(:), 's', 'MarkerSize', 10, 'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'k');

    lg = legend([pPKIKP pPKPbc pPKiKP pPKPab], '\textit{PKIKP}', '\textit{PKPbc}', ...
                '\textit{PKiKP}', '\textit{PKPab}', 'Location', 'NorthWest');

    topz(pPKPbc)

    % This will really be the Xlabel (the axes get flipped in the rotated version).
    ylabel('Time relative to arrival (s)')

    ylim([-13 13])
    yticks([-12:4:12])
    set(ha, 'YDir', 'Reverse')

    % Print the mean residuals w.r.t to PKPbc, since that is not included on this figure.
    fprintf('Mean residual w.r.t. PKPbc is %.2f s\n', mean(tres))

  otherwise
    error('Specify either ''theoretical_PKPbc'' or ''actual_arrival'' for input ''ref_time''.')

end

% Final cosmetics, unchanged between both cases.
xticks([144:2:154])
ha.XTickLabel = cellfun(@(xx) [xx '$^{\circ}$'], ha.XTickLabels, 'UniformOutput', false);
longticks([], 2)
box on
xlabel('Epicentral distance (degrees)')
axesfs([], 14, 14);
latimes

% Save it (but maybe rotate the axis first).
if strcmp(ref_time, 'actual_arrival')
    ha.XAxisLocation = 'top';
    camroll(ha, 90)
    lg.Location = 'SouthWest';

end
savepdf(mfilename)

% End with some helpful printouts.
% None of the residuals were NaN, so this statement is true (all EQs contributed data).
fprintf('\nNumber of earthquakes that contributed data: %i\n\n', length(ID))
fprintf('Plotted the following SAC files:\n')
for i = 1:length(EQ)
    fprintf('%s\n', EQ(i).Filename)
    fprintf('\t...at %.2f km depth and %.2f degrees\n\n', EQ(i).PreferredDepth, ...
            EQ(i).TaupTimes(1).distance)

end
fprintf('\n!!!!    Wrote %s    !!!!\n', fname)

tres
fprintf('The mean tres is: %.1f s\n', mean(tres))
fprintf('The minmax travel times are: %.1f, %.1f s\n', min(ttime), max(ttime))
fprintf('The percent pertubation is: %.1f%s\n', (mean(tres)/mean(ttime))*100, '%')

% Print the catalog this event metadata was culled from
for i = 1:length(EQ)
    fprintf('\n')
    EQ(i).Filename
    [~, contrib_author, ~] = eventid(EQ(i))

end
