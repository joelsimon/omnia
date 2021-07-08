function fig10_S2(commonID)
% FIG10_S2(commonID)
%
% First run: simon2021gji_data_exists.m to write textfiles which lists the event
% IDs for which each instrument class recorded data (Raspberry data do not exist
% for many events).
%
% !! Must first run: simon2021gji_data_exists.m !!
%
%
% Input:
% commonID    True to only compare residuals for events for which Raspbery
%                 recorded data (but did not necessarily make a pick) (def: false)
%
% Devloped as: simon2020_firstarrival_histogram
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 07-Jul-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('commonID', false)

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

otype = 'vel'

commonID
close all
max_tres = 10;

wlen = 30;
lohi = [1 5];
wlen2 = 1.75;

% Path to relevant textfile.
datadir = fullfile(getenv('GJI21_CODE'), 'data');
mer_det_txt1 = fullfile(datadir, 'mer.firstarr.all.txt');

trad_det_txt1 = fullfile(datadir, sprintf('trad.firstarr.P.%s.txt', otype));
rasp_det_txt1 = fullfile(datadir, sprintf('rasp.firstarr.P.%s.txt', otype));

% Read the MERMAID data -- P waves only.
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
[rasp_FA, ~, ~, perc] = winnowfirstarrival(rasp_det_txt1, max_tres, max_twosd, min_snr, {'p' 'P'});
perc

% Generate subplot.
[ah, ha] = krijetem(subnum(3,3));
shrink(ah, 1, 1.3)
movev(ah(4:6), 0.03);
movev(ah(7:9), 0.06);

f = gcf;
fig2print(f, 'flandscape')

% Possible further winnowing to only include event IDs for which data exists for
% all stations.
if commonID
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

    % Compute max. decibel difference between stations
    trad2mer = decibel(max(trad_FA.SNR(trad_idx)), max(mer_FA.SNR(mer_idx)));
    mer2rasp = decibel(max(mer_FA.SNR(mer_idx)), max(rasp_FA.SNR(rasp_idx)));

else
    % Keep all of them.
    mer_idx = [1:length(mer_FA.ID)];
    trad_idx = [1:length(trad_FA.ID)];
    rasp_idx = [1:length(rasp_FA.ID)];

end

% "Tradtiional" seismometers.
titstr = 'Traditional seismometer';
plotem(ha(1), ha(2), ha(3), trad_FA.tres(trad_idx), trad_FA.SNR(trad_idx), ...
       trad_FA.twosd(trad_idx), titstr, [0.133 0.545 0.133], 1);

% MERMAID.
titstr = 'MERMAID';
plotem(ha(4), ha(5), ha(6), mer_FA.tres(mer_idx) , mer_FA.SNR(mer_idx), ...
       mer_FA.twosd(mer_idx), titstr, 'blue', 0.7);
ha(4).XLabel.String = '$t^\star_{\mathrm{res}}$ (s)';

% Raspberry Shake.
titstr = 'Raspberry Shake';
plotem(ha(7), ha(8), ha(9), rasp_FA.tres(rasp_idx), rasp_FA.SNR(rasp_idx), ...
       rasp_FA.twosd(rasp_idx), titstr, raspberry, 1);

%% Cosmetics.
moveh(ha(1:3), -0.03)
moveh(ha(7:end), 0.03)

longticks(ha, 1.5)
set(ha, 'Box', 'on')

latimes
set(ha(4:end), 'YLabel', [])


set(ha(4:end), 'YLabel', [], 'YTickLabel', [])

moveh(ha(4:6), -0.06)
moveh(ha(7:9), -0.12)
movev(ah(4:6), 0.03)
movev(ah(7:9), 0.06)

axesfs([], 10, 10)

% Label.
[lax, th] = labelaxes(ah, 'ul', true, 'Interpreter', 'LaTeX', 'FontName', ...
                      'Times', 'FontSize', 12);
movev(lax, 0.03)
moveh(lax, -0.025)

% Uncomment this line to remove fig labels, e.g., for a presentation.
delete(lax)

if ~commonID
    savepdf('fig10')

else
    savepdf('figS2')
    clc
    fprintf('dB gain max. SNR traditional over MERMAID: %.1f\n', trad2mer)
    fprintf('dB gain max. SNR MERMAID over Raspberry Shake: %.1f\n', mer2rasp)

end


%______________________________________________________________________________%

function plotem(ha1, ha2, ha3, tres, SNR, twosd, titstr, col, falph)

xlim1 = [-10 10];
xlim2 = [0 4];
xlim3 = [0 0.6];

ylim1 = [0 0.3];
ylim2 = [0 0.36];
ylim3 = [0 0.24];

% Axes 1: residual histogram

axes(ha1);
hold(ha1, 'on')
h1 = histogram(tres, 'Normalization', 'Probability', 'BinWidth', ...
               1, 'FaceColor', col, 'FaceAlpha', falph);

plot([mean(tres) mean(tres)], ylim1, 'k--')
hold(ha1, 'off')

xlim(xlim1)
ylim(ylim1)

xlabel('$t_{\mathrm{res}}$ (s)')
ylabel('Probability')
numticks([], 'x', 5);
numticks([], 'y', 3);
title(sprintf('%s [N: %i]', titstr, length(tres)), 'FontSize', 13)


text(-9.5, 0.27, sprintf('Mean = %.2f', mean(tres)), 'HorizontalAlignment', 'Left')
text(-9.5, 0.2325, sprintf('St. Dev. = %.2f', std(tres, 1)), 'HorizontalAlignment', 'Left')
%text(+5.5, 0.135, sprintf('[N: %i]', length(tres)), 'HorizontalAlignment', 'Right')

% Axes 2: SNR

axes(ha2);
hold(ha2, 'on')
log10SNR = log10(SNR);
H = histogram(log10SNR, 'Normalization', 'Probability', 'BinWidth', 1/5, 'FaceColor', col, 'FaceAlpha', falph);
plot(repmat(mean(log10SNR), 1, 2), ylim2, 'k--');
hold(ha2, 'off')

xlabel('$\mathrm{log}_{10}\mathrm{SNR}$')
ylabel('Probability')
xlim(xlim2)
ylim(ylim2)
numticks([], 'x', 5);
numticks([], 'y', 3);

% Find mode as displayed.
hold(ha2, 'on')
[~, mode_val] = max(H.Values);
mode_edges = [H.BinEdges(mode_val) H.BinEdges(mode_val+1)];
middle_mode = mean(mode_edges);
%vertline(middle_mode); % uncomment to verify correct bin selected
fprintf('%s mean-mode distance: %.2f\n',  titstr, mean(log10SNR) - middle_mode);
hold(ha2, 'off')

text(3.9, 0.324, sprintf('Min. = %.2f', min(log10SNR)), 'HorizontalAlignment', 'Right');
text(3.9, 0.279, sprintf('Med. = %.2f', median(log10SNR)), 'HorizontalAlignment', 'Right');
text(3.9, 0.234,  sprintf('Max. = %.2f', max(log10SNR)), 'HorizontalAlignment', 'Right');

% Axes 3: Two-standard deviation of a error estimate.

axes(ha3);
hold(ha3, 'on')
histogram(twosd, 'Normalization', 'Probability', 'BinWidth', (1/50)*(6/4), 'FaceColor', col, 'FaceAlpha', falph);
plot(repmat(mean(twosd), 1, 2), ylim3, 'k--');
hold(ha3, 'off')

xlabel('$2\mathrm{SD}_{\mathrm{err}}$ (s)')
ylabel('Probability')
xlim(xlim3)
ylim(ylim3)

numticks([], 'x', 5);
numticks([], 'y', 3);

min_err = min(twosd);
if ~contains(titstr, 'Raspberry')
    if min_err < 1/20 % the sampling interval of these decimated data
        text(0.585, 0.18*1.2, sprintf('Min. $<$ 1/$f_s$', min_err), 'HorizontalAlignment', 'Right');

    else
        text(0.585, 0.18*1.2, sprintf('Min. = %.2f', min_err), 'HorizontalAlignment', 'Right');

    end
    text(0.585, 0.155*1.2, sprintf('Med. = %.2f', median(twosd)), 'HorizontalAlignment', 'Right');
    text(0.585, 0.13*1.2, sprintf('Max. = %.2f', max(twosd)), 'HorizontalAlignment', 'Right');

else % Raspberry
    if min_err < 1/20 % the sampling interval of these decimated data
        text(0.01, 0.18*1.2, sprintf('Min. $<$ 1/$f_s$', min_err), 'HorizontalAlignment', 'Left');

    else
        text(0.01, 0.18*1.2, sprintf('Min. = %.2f', min_err), 'HorizontalAlignment', 'Left');

    end
    text(0.01, 0.155*1.2, sprintf('Med. = %.2f', median(twosd)), 'HorizontalAlignment', 'Left');
    text(0.01, 0.13*1.2, sprintf('Max. = %.2f', max(twosd)), 'HorizontalAlignment', 'Left');

end
