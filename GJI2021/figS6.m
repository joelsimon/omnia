function figS6
% FIGS6
%
% This beautifies the plot made by compare.m in
% $MERMAID/events/cpptstations/pz/examples/PAE_PMOR_PPTF_amplitude/ where I
% proved I had correctly derived the displacement SACPZ CONSTANT. See there for
% the full derivation.
%
% Developed as: simon2020_sacpzcompare.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 17-Mar-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

% Define paths.
merdir = getenv('MERMAID');
procdir = fullfile(merdir, 'processed');
evtdir = fullfile(merdir, 'events');

% Ensure in GJI21 git branch -- complimentary paper w/ same data set.
startdir = pwd;
cd(procdir)
system('git checkout GJI21');
cd(evtdir)
system('git checkout GJI21');
cd(startdir)

ID = '10937540';
s1 = fullfile(evtdir, 'cpptstations', 'sac', ID, ...
              '2018.231.0019.00.PAE.CPZ1.SHZ.SAC.none');
s2 = fullfile(evtdir, 'cpptstations', 'sac', ID, ...
              '2018.231.0019.00.PMOR.CP1Z.SHZ.SAC.none');
s3 = fullfile(evtdir, 'nearbystations', 'sac', ID, ...
              'G.PPTF.00.BHZ.2018.231.00.18.40.SAC.none');

EQ1 = load(fullfile(evtdir, 'cpptstations', 'evt', ID, ...
                    '2018.231.0019.00.PAE.CPZ1.SHZ.evt'), '-mat');
EQ1 = EQ1.EQ;
EQ2 = load(fullfile(evtdir, 'cpptstations', 'evt', ID, ...
                    '2018.231.0019.00.PMOR.CP1Z.SHZ.evt'), '-mat');
EQ2 = EQ2.EQ;
EQ3 = load(fullfile(evtdir, 'nearbystations', 'evt', ID, ...
                    'G.PPTF.00.BHZ.2018.231.00.18.40.evt'), '-mat');
EQ3 = EQ3.EQ;

[x1, h1] = readsac(s1);
x1 = detrend(x1);
[x2, h2] = readsac(s2);
x2 = detrend(x2);
[x3, h3] = readsac(s3);
x3 = detrend(x3);

f1 = EQ1.TaupTimes(1).truearsecs;
f2 = EQ2.TaupTimes(1).truearsecs;
f3 = EQ3.TaupTimes(1).truearsecs;

[xw1, W1] = timewindow(x1, 500, f1, 'middle', h1.DELTA, h1.B);
[xw2, W2] = timewindow(x2, 500, f2, 'middle', h2.DELTA, h2.B);
[xw3, W3] = timewindow(x3, 500, f3, 'middle', h3.DELTA, h3.B);

figure
f = gcf;
fig2print(f, 'flandscape');
ha = gca;
shrink(ha, 1, 2.5);

plot(W1.xax-f1, xw1, 'Color', purp)
hold on
plot(W2.xax-f2, xw2, 'r')
plot(W3.xax-f3, xw3, 'Color', [0.6 0.6 0.6])
lg = legend('RSP.PAE (SACPZ by JDS)', 'RSP.PMOR (SACPZ by JDS)', 'G.PPTF (SACPZ by IRIS)', ...
            'Location', 'NorthEast', 'AutoUpdate', 'off');
lg.Box = 'off';

ylim([-4e5 4e5])
xlim([-15 90])
xticks([-15:15:90])
vertline(0, [], 'k--');

xlabel('Time relative to theoretical arrival of \textit{P} phase (s)')
ylabel('Displacement (nm)')

pae2pptf = grcdist([h1.STLO h1.STLA],[h3.STLO h3.STLA]);
pmor2pptf = grcdist([h2.STLO h2.STLA],[h3.STLO h3.STLA]);

fprintf('PAE is %.2f km away from PPTF\n', pae2pptf);
fprintf('PMOR is %.2f km away from PPTF\n', pmor2pptf);

% They all correspond to the same EQ
magtype = EQ1.PreferredMagnitudeType;
magstr = sprintf('\\textit{%s}$_{\\mathrm{%s}}$ %2.1f', upper(magtype(1)), lower(magtype(2)), ...
                 EQ1.PreferredMagnitudeValue);
depthstr = sprintf('%2.1f km depth', EQ1.PreferredDepth);
locstr = titlecase(sprintf('%s', EQ1.FlinnEngdahlRegionName));
title([magstr ' ' locstr ' at ' depthstr ' on ' datestr(EQ1.PreferredTime) ' UTC']);

str = sprintf('Distance: RSP.PAE to G.PPTF = %.1f km; RSP.PMOR to G.PPTF = %.1f km', pae2pptf, pmor2pptf);
[lg2, tx] = textpatch(ha, 'South', str);
lg2.Position(2) = 0.36;
lg2.Box = 'off';


latimes
axesfs([], 12, 12);
shg
longticks(ha, 3)

savepdf('figS6')
