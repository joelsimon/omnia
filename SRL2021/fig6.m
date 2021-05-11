function fig6
% FIG6
%
% Plots cross-sectional ray paths of inner- and outer-core phases through the Earth.
%
% Developed as: simon2020_tauppath
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 05-Feb-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

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

figure

%%______________________________________________________________________________________%%

% Figure 7: PKIKP wave
s = '20191220T115726.16_5E0574F1.MER.DET.WLT5.sac';
EQ = getevt(fullsac(s, procdir), evtdir);


[tt_pkikp, ~, ax, path_pkikp, source_pkikp, receiver_pkikp, lg] = ...
    taupPath('ak135', EQ.PreferredDepth, 'PKIKP', 'deg', EQ.TaupTimes(1).distance);
fprintf('\n')

set(source_pkikp, 'Marker', '*', 'MarkerSize', 4)
set(receiver_pkikp, 'Marker', '^', 'MarkerSize', 4)
set(path_pkikp, 'Color', 'b')
delete(lg)


%%______________________________________________________________________________________%%

%% PKPbc only -- all but P-09

% Ordered from top to top in Figure 8 -- exlcuding P-09, which we address later.
s = {'20181025T231318.08_5BD3ADDA.MER.DET.WLT5.sac', ...
     '20181025T231318.13_5BD80CFE.MER.DET.WLT5.sac', ...
     '20181025T231300.19_5BD80EDE.MER.DET.WLT5.sac'};

hold(gca, 'on')
for i = 1:length(s)
    EQ = getevt(fullsac(s{i}, procdir), evtdir);

    [tt_pkpbc, ~, ax, path_pkpbc, source_pkpbc, receiver_pkpbc, lg] = ...
        taupPath('ak135', EQ.PreferredDepth, 'PKP', 'deg', EQ.TaupTimes(1).distance);
    fprintf('\n')

    set(receiver_pkpbc, 'Marker', '^', 'MarkerSize', 4)
    set(path_pkpbc(1), 'Color', 'g')
    delete(path_pkpbc(2)); % PKPab only in P-09
    delete(source_pkpbc); % same source as in P-09
end


%% PKPbc and PKPab -- in P-09

s = '20181025T231330.09_5BD6FE4A.MER.DET.WLT5.sac';
EQ = getevt(fullsac(s, procdir), evtdir);

[tt_pkp, ~, ax, path_pkp, source_pkp, receiver_pkp, lg] = ...
    taupPath('ak135', EQ.PreferredDepth, 'PKP', 'deg', EQ.TaupTimes(1).distance);

delete(lg)
set(source_pkp, 'Marker', '*', 'MarkerSize', 4)
set(receiver_pkp, 'Marker', '^', 'MarkerSize', 4)

path_pkpbc = path_pkp(1);
path_pkpab = path_pkp(2);

set(path_pkpbc, 'Color', 'g')
set(path_pkpab, 'Color', 'm'); % PKPab

camroll(90)

uistack([path_pkpbc path_pkpab], 'bottom')

% Legend.
paths = [path_pkikp path_pkpbc path_pkpab];
phases = {'\textit{PKIKP} (Fig. 7)', ...
          '\textit{PKPbc}\hspace{.65em}(Fig. 8)', ...
          '\textit{PKPab}\hspace{.58em}(Fig. 8)'};

lg = legend(paths, phases, 'Interpreter', 'LaTeX', 'Location', 'NorthWest');

lg.Position = [0.4235    0.6921    0.1881    0.0890];
lg.Box = 'off'

savepdf(mfilename)
