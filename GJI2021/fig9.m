function fig9
% FIG9
%
% Plot the 4 lowest, highest, and 33- and 66-percentile mermaid signals, based
% on their uncertainty, for residuals with +/-10 s and max uncertainties of 0.15 s
%
% Developed as: simon2020_plotfirstarrivals.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 21-Jun-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

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
max_tres = 10;
max_twosd = 0.15;

wlen = 30;
lohi = [1 5];
wlen2 = 1.75;
popas = [4 1];
pt0 = 0;

% Path to relevant textfile.
datadir = fullfile(getenv('GJI21_CODE'), 'data');
mer_det_txt1 = fullfile(datadir, 'mer.firstarr.all.txt');

% Read data.
[FA, ~, ~, perc] = winnowfirstarrival(mer_det_txt1, max_tres, max_twosd, [], {'p' 'P'});
perc

% Sort the data from low- to high-uncertainty.
[~, sidx] = sort(FA.twosd, 'ascend');

FA.SNR = FA.SNR(sidx);
FA.s = FA.s(sidx);
FA.tres = FA.tres(sidx);
FA.twosd = FA.twosd(sidx);

% Total number of residuals which passed thresholds.
ls = length(FA.s);

% Split data in 33rd  and 66th percentiles.
q = round(prctile(1:ls, [33 66])); % == round(quantile(1:ls, [0.33 0.66]))

% 4 lowest-uncertainty signals.
lo_idx = [1:3];

% 4 highest-uncertainty signals.
hi_idx = [ls-2:ls];

% 33rd percentile.
mid1_idx = [q(1)-1:q(1)+1];

% 66th percentile.
mid2_idx = [q(2)-1:q(2)+1];

% Combine the indices.
mer_idx = [lo_idx mid1_idx mid2_idx hi_idx];

% Pull the relevant SAC files and their uncertainties.
s12 = FA.s(mer_idx);
hardcode_twosd12 = FA.twosd(mer_idx);

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

% Inputs for plotfirstarrival.m
FontSize = [10 8];
ci = false;
bathy = true;

% Plot em.
for i = 1:12
    ax = ha(i);
    axes(ax)
    [~, ~, tx, pl, FA] = plotfirstarrival(s12{i}, ax, FontSize, [], ci, wlen, ...
                                          lohi, procdir, evtdir, bathy, wlen2, ...
                                          [], popas, pt0, hardcode_twosd12(i));
    ax.XLabel.String{2} = [];
    ax.YLabel.String = strrep(ax.YLabel.String, 'Amplitude', 'Counts');
    ax.YLabel.Position(1) = -18;
    numticks(ax, 'x', 7);

    % Label the rounded max counts (they are non-integer due to filtering of the waveform).
    max_counts = round(pl.maxc.YData);
    ax.YLabel.String{2} = sprintf('[max. %i]', max_counts);

    % Edit top left textpatch to be two lines with date on top
    % Edit top right textpatch to include MERMAID number
    tx.ulth.String = sprintf('%s\n%s', irisstr2date(FA.EQ.PreferredTime), tx.ul.String{:});
    tx.urth.String = sprintf('%s\nP00%s', tx.urth.String, getmerser(s12{i}));

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

% Uncomment this line to remove fig labels, e.g., for a presentation.
%delete(lax)

savepdf('fig9')
