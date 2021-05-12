function simon2021SRL_PKIKPres(ref_time, plt)
% SIMON2021SRL_PKIKPRES(ref_time, plt)
%
% fig9.m but for arrival times found in windows centered on the theoretical
% arrival times of PKIKP phases, not PKPbc phases.
%
% The point of this function to is to verify that is we use an adjusted
% PKIKP-centered window we don't get drastically different arrival times.
%
% Developed as: simon2021_PKIKPres.m
% 
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 12-May-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults.
defval('ref_time', 'actual_arrival')
defval('plt', false)

clc
close all

% firstarrival.m parameters.
wlen = 30;
lohi = [1 2];
ci = true;
bathy = true;
wlen2 = 1.75;
fs = [];
popas = [4 1];

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

%% Load all events until end of 2019.
enddate = datetime('31-Dec-2019 23:59:59.999', 'TimeZone', 'UTC');
returntype = 'DET';
savepath = fullfile(getenv('SRL21_CODE'), 'data');
idfile = fullfile(evtdir, 'reviewed', 'identified', 'txt', 'identified.txt');
incl_prelim = false;

% reftime = 'SAC' in keeping with readevt2txt.m restriction barring 'EVT'
[s, ~, ~, ~, ~, ~, ~, ~, ph] = readidentified(idfile, [], enddate, 'SAC', 'DET', incl_prelim);

% Find those which contain PK* (core phase) -- don't do PKIKP here because I may
% not have saved that phase as the arrival, so while it could exist in the time
% window of the seismogram it is not the phase listed in 'identified.txt.'
idx = find(contains(ph, 'PK'));
s = s(idx);

%% Load the corresponding event structures and find the TaupTime corresponding to PKP.
idx = 0;
count = 0;
for i = 1:length(s)
    EQ(i) = getevt(s{i});

end
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

    % Identify which of the two PKP phases is the bc branch (the first of the two
    % PKP arrivals).
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
            PKIKP_idx(i) = j;     % save the index of the PKIKP phase

          case 'PKP'
            if isbc % the first PKP arrival is always the bc branch
                PKPbc(i) = ar_time;
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


%% Compute the THEORETICAL differential travel time residuals w.r.t. PKIKP.
dPKPbc = PKPbc - PKIKP;
dPKPab = PKPab - PKIKP;
dPKiKP = PKiKP - PKIKP;

% Sort by distance.
[~, sidx] = sort(dist);
PKIKP_idx = PKIKP_idx(sidx);
EQ = EQ(sidx);
dist = dist(sidx);

dPKPbc = dPKPbc(sidx);
dPKiKP = dPKiKP(sidx);
dPKPab = dPKPab(sidx);

% Get the public IDs to plot some record sections.
for i = 1:length(EQ)
    ID{i} = fx(strsplit(EQ(i).PublicId, '='),  2);

end
ID = unique(ID);

if plt
    for i = 1:length(ID)
        recordsection(ID{i}, lohi, 'etime')
        savepdf(sprintf('rs_%s', ID{i}))
        close

    end
end

%% Compute the first-arrival residual where PKIKP arrival time is considered the first arrival.
for i = 1:length(EQ)
    % This ensures that the ONLY (and therefore, the first) arrival in the EQ
    % structure is PKIKP.
    first_arr_PKP_EQ  = EQ(i);
    first_arr_PKP_EQ.TaupTimes = EQ(i).TaupTimes(PKIKP_idx(i));

    % Compute residual, corrected for bathymetry and cruising depth.
    [tres(i), dat(i)] = firstarrival(first_arr_PKP_EQ.Filename, false, wlen, ...
                                     lohi, [], [], first_arr_PKP_EQ, bathy, ...
                                     wlen2, fs, popas);

    if plt
        % Plot the individual residuals.
        [f, ax, tx] = plotfirstarrival(first_arr_PKP_EQ.Filename, [], [], ...
                                   first_arr_PKP_EQ, ci, wlen, lohi, [], [], ...
                                   true, wlen2, fs, popas);
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

        savepdf(sprintf('PKIKPres_%s', EQ(i).Filename), f)
        close

    end
end

% Print the arrival times using the PKIKP-centered windows for direct
% comparisons with with arrival times found in PKPbc-centered windows (fig9.m).
% Note that these times are in reference to xaxis(h.NPTS, h.DELTA, h.B).
datadir = fullfile(getenv('SRL21_CODE'), 'data');
fname = fullfile(datadir, sprintf('%s.txt', mfilename));
fid = fopen(fname, 'w');
fprintf(fid, '%s: arrival time of PKIKP-centered firstarrival.m\n', mfilename)
fmt = '%44s    %.2f (s)\n';
for i = 1:length(PKIKP)
    fprintf(fid, fmt, EQ(i).Filename, dat(i));

end
fclose(fid);

%%______________________________________________________________________________________%%

figure
ha = gca;
hold on

switch ref_time
  case 'theoretical_PKIKP'
    %% Plot the theoretical differential vs PKIKP and the OBSERVED differential
    %% (tres); both corrected for bathymetry and MERMAID cruising depth.

    ptres = plot(dist, tres, 'diamond', 'Color', 'k', 'MarkerFaceColor', 'k', 'MarkerSize', 10);

    pPKIKP = plot(xlim, [0 0], 'k');
    pPKPbc = plot(dist, dPKPbc, 'b:o', 'MarkerSize', 8, 'MarkerFaceColor', 'w');
    pPKiKP = plot(dist, dPKiKP, 'm:o', 'MarkerSize', 8, 'MarkerFaceColor', 'w');
    pPKPab = plot(dist, dPKPab, 'g:o', 'MarkerSize', 8, 'MarkerFaceColor', 'w');

    lg = legend([ptres pPKIKP pPKPbc pPKPab pPKiKP], '$t_{\mathrm{res}}^{\star}$', ...
                '$\Delta$\textit{PKIKP}', '$\Delta$\textit{PKPbc}', ...
                '$\Delta$\textit{PKPab}', '$\Delta$\textit{PKiKP}', 'Location', ...
                'NorthWest');

    ylabel('Residual w.r.t. adjusted \textit{PKIKP} arrival time (s)')
    text(150, -3, sprintf('Mean($t_\\mathrm{res}^{\\star}$) = %.2f s', mean(tres)))
    topz(ptres)

  case 'actual_arrival'
    dPKIKP = PKIKP - PKIKP;  % Differential residual with itself; i.e., 0.

    % tres-tres is obviously 0; done here for dimension; really this is just to mark
    % the actual epicentral distances at which we recorded data.
    ptres = plot(dist, tres-tres, 'kx', 'MarkerSize', 14,  'LineWidth', 2);

    pPKIKP = plot(dist, dPKIKP-tres(:), 'd', 'MarkerSize', 10, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k');
    pPKPbc = plot(dist, dPKPbc-tres(:), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k');
    pPKiKP = plot(dist, dPKiKP-tres(:), '^', 'MarkerSize', 10, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k');
    pPKPab = plot(dist, dPKPab-tres(:), 's', 'MarkerSize', 10, 'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'k');

    lg = legend([ptres pPKIKP pPKPbc pPKiKP pPKPab], '$t_{{}_\mathrm{AIC}}$', ...
                '\textit{PKIKP}', '\textit{PKPbc}', '\textit{PKiKP}', '\textit{PKPab}', ...
                'Location', 'SouthWest', 'AutoUpdate', 'off');

    pzero = plot(xlim, [0 0], 'k-');
    botz(pzero) % Reference line; where an arrival would have 0 s residual w.r.t. PKIKP
    topz([pPKPbc ptres])

    % This will really be the Xlabel (the axes get flipped in the rotated version).
    ylabel('Time relative to arrival (s)')
    set(ha, 'YDir', 'Reverse')

  otherwise
    error('Specify either ''theoretical_PKIKP'' or ''actual_arrival'' for input ''ref_time''.')

end

% Final cosmetics, unchanged between both cases.
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
    savepdf('PKIKPres')

else
    savepdf('PKIKPres')

end

% End with some helpful printouts.
fprintf('\nNumber of earthquakes that contributed data: %i\n\n', length(ID))
fprintf('Plotted the following SAC files:\n')
for i = 1:length(EQ)
    fprintf('%s\n', EQ(i).Filename)
    fprintf('\t...at %.2f km depth and %.2f degrees\n\n', EQ(i).PreferredDepth, ...
            EQ(i).TaupTimes(1).distance)

end
fprintf('\n!!!!    Wrote %s    !!!!\n', fname)
