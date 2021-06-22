function fig8
% FIG8
%
% plotmermaidglobalcatalog.m from start of the SPPIM array (05-Aug-2018) through 2019.
%
% Developed as: $SIMON2020_CODE/simon2020_plotmermaidglobalcatalog.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 22-Apr-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

% Define paths.
merdir = getenv('MERMAID');
evtdir = fullfile(merdir, 'events');
procdir = fullfile(merdir, 'processed');

% Ensure in GJI21 git branch.
startdir = pwd;
cd(procdir)
system('git checkout GJI21');
cd(evtdir)
system('git checkout GJI21');
cd(startdir)

[ah, ha] = krijetem(subnum(4, 2));

f = gcf;
fig2print(f, 'flandscape');

moveh(ha(1:4), +0.065);
moveh(ha(5:8), +0.085);

movev(ah(1:2), +0.01)
movev(ah(3:4), -0.01)
movev(ah(5:6), -0.04)
movev(ah(7:8), -0.07)

shrink(ha(1:4), 1/1.5, 1)
shrink(ha(5:end), 1, 1)

p = fullfile(getenv('MERMAID'), 'events', 'reviewed', 'identified', 'txt');
mercatfile = {'M4_DET.txt', 'M5_DET.txt', 'M6_DET.txt', 'M7_DET.txt', 'M8_DET.txt'};

% The first MERMAID deployed was P008 -- get that deployment date and
% use that as the start date.
supplement_directory = fullfile(getenv('GJI21_CODE'), 'data', 'supplement');
mer = read_simon2021gji_supplement_gps(supplement_directory);
mer = readmerloc;
startdate = mer.P008.locdate(1);

P025_deploy = datetime('14-Sep-2018 11:57:12', 'TimeZone', 'UTC');

% And go through the end of 2019.
enddate = datetime('31-Dec-2019 23:59:59.999', 'TimeZone', 'UTC');

ah_idx = 0;
for i = 1:5
    if i == 1
        % This is just for M4-4.9 statistics; not included in final plot.
        [F1_4, ha1_4, F2_4, ha2_4] = ...
            plotmermaidglobalcatalog([], [], fullfile(p, mercatfile{i}), [startdate enddate]);
        ha2_4.YLim = [0 100];
        ha2_4.Title.Position(2) = 103;

        % This plot isn't including in the paper, but I want to say biased detection was for P008.
        fprintf('\n\n!! P008 recorded %i of %i M4 events !!\n\n', F2_4.h.BinCounts(1), sum(F2_4.h.BinCounts))

        set(F2_4.h, 'FaceAlpha', 1,  'FaceColor', [0.5 0.5 0.5])
        savepdf('fig8_M4.pdf', F2_4.f);
        close(F1_4.f)
        close(F2_4.f)

        continue

    end
    ah_idx = ah_idx + 1;

    [F1(i), ha1(i), F2(i), ha2(i)] = ...
        plotmermaidglobalcatalog(ah(ah_idx), ah(ah_idx + 1), fullfile(p, mercatfile{i}), [startdate enddate]);

    set([F1(i).pl_null F1(i).pl_pos], 'Color', [0.5 0.5 0.5], 'MarkerFaceColor', [0.5 0.5 0.5])
    set(F2(i).h, 'FaceAlpha', 1,  'FaceColor', [0.5 0.5 0.5])
    ha1(i).XLim = [startdate enddate];
    ha1(i).XTick = linspace(startdate, enddate, 5);
    ha1(i).XAxis.TickLabelFormat = 'dd-MMM-uuuu';
    ha1(i).YTick = [0:4:16];

    ah_idx = ah_idx + 1;

end
floatstr = {'08' '09' '10' '11' '12' '13' '16' '17' '18' '19' '20' ...
            '21' '22' '23' '24' '25'};
set(ah(2:2:end), 'XTickLabels', floatstr);

% Adjust Ylims.
ah(2).YLim = [0 80];
ah(4).YLim = [0 60];
ah(6).YLim = [0 15];
ah(8).YLim = [0 2.5];
ah(8).YTick = [0:2];

% Adjust M5 limits and add text concerning number of missed events per
% day as opposed to black bar of missed events in negative direction.
ha1(2).YLim = [-1.25 8];
ha1(2).YTick = [0:2:8];
F1(2).pl_null.YData = [];


% Delete the 19 records from 01-Aug-2018 15:46:23 to 05-Aug-2018 12:49:55; I do
% not know why they are plotted when the xlim supposedly is after the last of
% these; maybe datetime xlims aren't exactly accurate.
delete(F1(2).pl_null_out)

hits = length(F1(2).pl_pos.XData);
misses = length(F1(2).pl_null.XData);
num_days = days(enddate - startdate);
misses_per_day = misses / num_days
midpoint = datenum((enddate-startdate)/2);
%tx5 = text(ha1(2), midpoint, -0.75, sprintf('$\\approx$4 missed events per day'));
tx5 = text(ha1(2), 242, -0.7, sprintf('$\\approx$4 missed events per day'));
tx5.HorizontalAlignment = 'Center';

% Delete redundant xlabels.
set(ha1(2:4), 'XLabel', [])
set(ha2(2:4), 'XLabel', [])
ha2(end).XLabel.String = 'MERMAID (excluding ``P0'''' prefix)';

movev(ha, .03)
axesfs(f, 10, 10)

shrink(ha, 1.1, 1.1);
keyboard

mag = [5:8];
idx = 0;
for i = 2:length(ha1);
    idx = idx + 1;
    magtx(idx) = text(ha1(i), -175, ha1(i).YLabel.Position(2), sprintf(['\\' ...
                        'underline{\\textit{M}%i--%i.9}:'], mag(idx), ...
                                                      mag(idx)));

    hold(ha1(i), 'on')
    pl_P025_deploy(i) = plot(ha1(i), [P025_deploy P025_deploy], ha1(i).YLim, 'k--');
    hold(ha1(i), 'off')

end
%% DO NOT CHANGE THIS -- for some reason placing all at the bottom of the
%% stack makes the bold markerface in (h) not save properly.
botz(pl_P025_deploy(2), ha1(2))
botz(pl_P025_deploy(3), ha1(3))

set(magtx, 'FontSize', 14, 'FontWeight', 'Bold')
latimes

tx8 = text(ha1(end), F1(end).tl.Position(1), -1.5, sprintf('all events identified'));
tx8.HorizontalAlignment = 'Center';

F2(end).yl.Position(1) = F2(2).yl.Position(1);
latimes

movev(ah(3:4), .01)
movev(ah(5:6), .02)
movev(ah(7:8), .03)

% Label axes.
lax = labelaxes(ah, 'ul', true, 'FontSize', 14*1.2, 'Interpreter', 'LaTeX', ...
                'FontName', 'Times');
movev(lax, 0.025);
moveh(lax, -0.06);

% Highlight the events to be plotted as record sections.
hold(ha(1), 'on')
stem(ha(1), datetime('17-Nov-2019 12:13:27', 'TimeZone', 'UTC'), 5, 'k', 'Filled', 'LineWidth', 2)
hold(ha(1), 'off')

hold(ha(2), 'on')
stem(ha(2), datetime('01-Sep-2019 15:54:20', 'TimeZone', 'UTC'), 15, 'k', 'Filled', 'LineWidth', 2)
hold(ha(2), 'off')

hold(ha(3), 'on')
stem(ha(3), datetime('22-Feb-2019 10:17:22', 'TimeZone', 'UTC'), 15, 'k', 'Filled', 'LineWidth', 2)
hold(ha(3), 'off')

hold(ha(4), 'on')
stem(ha(4), datetime('26-May-2019 07:41:15', 'TimeZone', 'UTC'), 12, 'k', 'Filled', 'LineWidth', 2)
hold(ha(4), 'off')

magtx(1).Position(1) = -183;
magtx(2).Position(1) = -176;
magtx(3).Position(1) = -188;
magtx(4).Position(1) = -183;

F1(2).tl.Position(2) = 8.5;

F1(3).tl.Position(2) = 17;
F1(4).tl.Position(2) = 17;
F1(5).tl.Position(2) = 17;

F2(2).tl.Position(2) = 84;
F2(3).tl.Position(2) = 63;
F2(4).tl.Position(2) = 15.75;
F2(5).tl.Position(2) = 2.6;

F1(2).yl.Position(1) = -50;
F1(3).yl.Position(1) = -45;
F1(4).yl.Position(1) = -55;
F1(5).yl.Position(1) = -50;

for i = 2:4
    delete(F1(i).tl)
    delete(F2(i).tl)

end
delete(F1(5).tl)
F2(5).yl.String = [F2(5).yl.String  '*'];
F2(5).tl.String = '(*only 5 MERMAIDs deployed during both events)';

% Uncomment this line to remove fig labels, e.g., for a presentation.
%delete(lax)

savepdf('fig8', 1)

%% Finally, make note of how many unidentified events we could have.

% Collect all events, ID'd or not.
EV = read_simon2021gji_supplement_events(...
    fullfile(supplement_directory, 'simon2021gji_supplement_events.txt')); % all events

% Remove glitches.
glitch_sac = bumps(false);
glitch_sac(cellstrfind(glitch_sac, 'prelim.sac')) = [];
[~, glitch_idx] = intersect(EV.filename, glitch_sac);
EV = rmstructindex(EV, glitch_idx);

% Count the NaN event IDs (unidentified)
unidentified_non_glitch = sum(isnan(str2double(EV.IRIS_ID)));

fprintf('There are and additional %i unidentified, non-glitch SAC files\n', unidentified_non_glitch)
fprintf('That is around %.1f possible EQ detections per MERMAID\n\n', unidentified_non_glitch/16)
