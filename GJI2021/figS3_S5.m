function figS3_S5(commonID)
% FIGS3_S5(commonID)
%
% Plots top 12 highest SNRs from each instrument class.
%
% !! Must first run: simon2021gji_data_exists.m !!
%
% Input:
% commonID    True to only compare residuals for events for which Raspbery
%                 recorded data (but did not necessarily make a pick) (def: true)
%
% Developed as: simon2020_plotfirstarrivals_max_snr.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 21-Jun-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

defval('commonID', true)

% Define paths.
merdir = getenv('MERMAID');
procdir = fullfile(merdir, 'processed');
evtdir = fullfile(merdir, 'events');

% Ensure in GJI21 git branch.
startdir = pwd;
cd(procdir)
system('git checkout GJI21');
cd(evtdir)
system('git checkout GJI21');
cd(startdir)

% `firstarrival` and `winnowfirstarrival` inputs
max_tres = 10
otype = 'vel'
commonID

% Path to relevant data.
mer_sdir = procdir;
mer_evtdir = evtdir;

% For trad, cannot go any deepr than 'events' beause may be in nearbystations/ or cpptstations/.
trad_sdir = evtdir;
trad_evtdir = evtdir;

datadir = fullfile(getenv('GJI21_CODE'), 'data');
mer_det_txt1 = fullfile(datadir, 'mer.firstarr.all.txt');
trad_det_txt1 = fullfile(datadir, sprintf('trad.firstarr.P.%s.txt', otype));
rasp_det_txt1 = fullfile(datadir, sprintf('rasp.firstarr.P.%s.txt', otype));

% Read the MERMAID data for its winnowing paramters.
max_twosd = realmax;
min_snr = realmin;
[mer_FA, ~, ~, perc] = winnowfirstarrival(mer_det_txt1, max_tres, max_twosd, min_snr, {'p' 'P'});
perc

% Set the minimum SNR to be the minimum of the MERMAID set -- i.e.,
% this is about the SNR that my eye allowed a pic.
max_twosd = max(mer_FA.twosd);
min_snr = min(mer_FA.SNR);

% Get the list of CPPT SAC files which were zero-filled and thus need
% to be removed in wwinnowfirstarrival.
rmsac = simon2021gji_rmcppt;

% For "nearby" stations -- they should ALL already be p or P, so passing {'p' 'P'} makes no difference.
[trad_FA, ~, ~, perc] = winnowfirstarrival(trad_det_txt1, max_tres, max_twosd, min_snr, {'p' 'P'}, rmsac);
perc
[rasp_FA, ~, ~, perc] = winnowfirstarrival(rasp_det_txt1, max_tres, max_twosd, min_snr, {'p' 'P'}, rmsac);
perc

%%______________________________________________________________________________________%%

% Possible further winnowing to only include event IDs for which data exists for
% all stations.
if commonID
    % These files written with simon2021gji_data_exists.m
    mer_data_exists = readtext(fullfile(datadir, 'data_exists.mer.txt'));
    trad_data_exists = readtext(fullfile(datadir, 'data_exists.trad.txt'));
    rasp_data_exists = readtext(fullfile(datadir, 'data_exists.rasp.txt'));
    all_instruments_data_exists = intersect(intersect(mer_data_exists, trad_data_exists), ...
                                            rasp_data_exists);
    % The above is overkill because: isequal(all_instruments_data_exists, rasp_data_exists)

    % Identify the indicies of those common event IDs in the main structures.
    mer_inter = intersect(mer_FA.ID, all_instruments_data_exists);
    mer_idx = find(ismember(mer_FA.ID, mer_inter));

    trad_inter = intersect(trad_FA.ID, all_instruments_data_exists);
    trad_idx = find(ismember(trad_FA.ID, trad_inter));

    rasp_inter = intersect(rasp_FA.ID, all_instruments_data_exists);
    rasp_idx = find(ismember(rasp_FA.ID, rasp_inter));

else
    % Keep all of them.
    mer_idx = [1:length(mer_FA.ID)];
    trad_idx = [1:length(trad_FA.ID)];
    rasp_idx = [1:length(rasp_FA.ID)];

end

%%______________________________________________________________________________________%%
makeplot(trad_FA, trad_idx, false, trad_sdir, trad_evtdir, 'Velocity (nm/s)', 'trad', [0.133 0.545 0.133], commonID)
makeplot(mer_FA, mer_idx, true, mer_sdir, mer_evtdir, 'Counts', 'mer', 'blue', commonID)
makeplot(rasp_FA, rasp_idx, false, trad_sdir, trad_evtdir, 'Velocity (nm/s)', 'rasp', raspberry, commonID)

%%______________________________________________________________________________________%%
function makeplot(FA, exist_idx, bathy, sdir, evtdir, ystr, name, col, commonID)

% Inputs for plotfirstarrival.m
FontSize = [10 8];
ci = false;
wlen = 30;
lohi = [1 5];
wlen2 = 1.75;
popas = [4 1];
pt0 = 0;

% Sort the traces BASED ON SNR.
[~, s_idx] = sort(FA.SNR, 'descend');

% If we are winnowing based on common IDs, find the intersection between the
% sorted SNR indices and the indices for which data is (maybe) common to all (if
% commonID is false, data_exists is all indices). 'stable' option keep ordering
% the same as s_idx.
s_idx = intersect(s_idx, exist_idx, 'stable');

% Sort the data from high- to low-SNR.
FA.SNR = FA.SNR(s_idx);
FA.s = FA.s(s_idx);
FA.twosd = FA.twosd(s_idx);
FA.ID = FA.ID(s_idx);

% Generate subplot.
[ha, hav] = krijetem(subnum(4, 3));
f = gcf;
fig2print(f, 'flandscape')

shrink(hav, 0.85, 1)
moveh(hav(1:4), -0.055)
moveh(hav(9:12), 0.055)

axpos = linspace(-0.04, 0.04, 4);
movev(hav([1 5 9]), axpos(4))
movev(hav([2 6 10]), axpos(3))
movev(hav([3 7 11]), axpos(2))
movev(hav([4 8 12]), axpos(1))

% Label axes.
[lax, th] = labelaxes(ha, 'ul', true, 'Interpreter', 'LaTeX', 'FontName', 'Times');
moveh(lax, -0.035)
movev(lax, 0.02)

% Plot em.
for i = 1:12
    % Get this EQ structure.
    [s, EQ] = fullsacevt(FA.s{i}, sdir, evtdir, FA.ID(i));

    ax = ha(i);
    axes(ax)

    % Decimate the data (as close as possible) to 20 Hz (note: for MERMAID decimate
    % is a pass-through function because the decimation factor R = 1).
    [~, ~, tx, pl] = plotfirstarrival(s, ax, FontSize, EQ, ci, wlen, lohi, [], ...
                                     [], bathy, wlen2, 20, popas, pt0, FA.twosd(i));
    pl.signal.Color = col;
    ax.XLabel.String{2} = [];
    ax.YLabel.String = strrep(ax.YLabel.String, 'Amplitude', ystr)
    ax.YLabel.Position(1) = -17.5;
    numticks(ax, 'x', 7);

    % Edit top left textpatch to be two lines with date on top
    tx.ulth.String = sprintf('%s\n%s', irisstr2date(EQ.PreferredTime), tx.ul.String{:});

    if strcmp(name, 'mer')
        % Label the rounded max counts (they are non-integer due to filtering of the waveform).
        max_counts = round(pl.maxc.YData);
        ax.YLabel.String{2} = sprintf('[max. %i]', max_counts);

        % Edit top right textpatch to include station name
        tx.urth.String = sprintf('%s\nP00%s', tx.urth.String, getmerser(s));

    else
        % Edit top right textpatch to include station name
        sta_name = strippath(s);

        % For "nearby stations:"
        % This unique network.station.location.channel name may be found by
        % keeping all characters up to the fourth period ('.')
        % delimiter. DO NOT USE strsplit because it ignores
        % empties between delims (e.g.,
        % AU.NIUE..BHZ.2018.220.01.38.57.SAC.acc, where the
        % location is missing).
        % station_info = strsplit(strippath(nearby_sac{i}), '.');
        % floatnum = cell2commasepstr(station_info(1:4), '.');
        delims = strfind(sta_name, '.');

        % CPPT SAC file names start with  number; "nearby" start with a letter.
        if isempty(str2num(sta_name(1)))
            % "nearby"
            sta = sta_name(1:delims(4)-1);

        else
            % CPPT (RSP network)
            ntwk = 'RSP';
            sta = [ntwk '.' sta_name(delims(4)+1:delims(7)-1)];

        end
        tx.urth.String = sprintf('%s\n%s', tx.urth.String, sta)

    end

    % Equalize upper-box heights.
    movev(tx.ulth, -.065)
    tx.ul.Position(4) = tx.ul.Position(4)*1.65;

    tx.ur.Position(2) = tx.ul.Position(2);
    tx.ur.Position(4) = tx.ul.Position(4);

    % Equalize all box widths.
    max_width = max([tx.ul.Position(3), ...
                     tx.ur.Position(3), ...
                     tx.lr.Position(3), ...
                     tx.ll.Position(3)]);

    tx.ul.Position(3) = max_width;
    tx.ur.Position(3) = max_width;
    tx.lr.Position(3) = max_width;
    tx.ll.Position(3) = max_width;

    pause(1) % required for following `tack2corner` to work
    tack2corner(ax, tx.ul, 'NorthWest');
    tack2corner(ax, tx.ur, 'NorthEast');
    tack2corner(ax, tx.lr, 'SouthEast');
    tack2corner(ax, tx.ll, 'SouthWest');

end
set(th, 'FontSize', 12)

% First figure S3...
switch name
  case 'trad'
    fignum = '3';

  case 'mer'
    fignum = '4';

  case 'rasp'
    fignum = '5';

end

% Uncomment this line to remove fig labels, e.g., for a presentation.
%delete(lax)

if commonID
    savepdf(['figS' fignum])

else
    savepdf(['figS' fignum '_commonID_false'])

end
close
