function fig1b
% FIG1B
%
% Plots ray paths on regional (South Pacific) map.
%
% Developed as: simon2021_map2.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 12-May-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

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

%% This is essentially lifted from FJS' `polynesia.m`
load(fullfile(getenv('IFILES'),'TOPOGRAPHY','POLYNESIA','732c10d12f3c1ff02b85522b39bfd9ee1aa42244.mat'))

% http://ds.iris.edu/gmap/#network=*&starttime=2018-06-01&maxlat=4&maxlon=251&minlat=-33&minlon=176&drawingmode=box&planet=earth
defval('c11',[175   5])
defval('cmn',[240 -35])
% Get the topography parameters
defval('vers',2019);
defval('npc',20);
defval('mult',1); mult=round(mult);

% Begin with a new figure, minimize it right away
defval('fs',6);
defval('cax',[-7000 1500]);

% Note that the print resolution for large images is worse than the
% detail in the data themselves. One could force print with more dpi.
clf
% Color bar first...
[cb,cm]=cax2dem(cax,'hor');
% then map
imagefnan(c11,cmn,z,cm,cax)
% then colorbar again for adequate rendering
[cb,cm]=cax2dem(cax,'hor');
% Cosmetics
set(gca,'FontSize',fs)
xlabel('Longitude')
ylabel('Latitude')
cb.XLabel.String=sprintf('GEBCO %i elevation (m)',vers);
cb.XTick=unique([cb.XTick minmax(cax)]);
warning off MATLAB:hg:shaped_arrays:ColorbarTickLengthScalar
warning on MATLAB:hg:shaped_arrays:ColorbarTickLengthScalar
%%

cb.Location = 'EastOutside';
cb.TickDirection = 'out';
cb.Label.Interpreter = 'LaTeX';

% Define `getsac` inputs.
returntype = 'DET';
incl_prelim = false;

% Generate base map.
f = gcf;
ax = gca;
fig2print(f, 'flandscape')
hold(ax, 'on')

% LineWidth.
lw = 0.5;

% Load the seismograms used in this study.
[id, figsac] = simon2021SRL_seismograms;

% Compute the raypaths for this study.
sac_ct = 0;
evt_ct = 0;
%% For every figure (id(i), figsac(i); i is the Figure index).
for i = 1:length(id)
    if isempty(id{i})
        continue

    end

    %% For every event ID associated with that Figure
    %% Fig. 9 is the only one with multiple IDs present
    for j = 1:length(id{i})
        evt_ct = evt_ct + 1;
        idsac = getsac(id{i}{j}, evtdir, procdir, returntype, incl_prelim);
        EQ = getevt(idsac{1}, evtdir);

        evla = EQ.PreferredLatitude;
        evlo = EQ.PreferredLongitude;;
        evlo(find(evlo<0)) = evlo(find(evlo<0)) + 360;

        evt_pl(evt_ct) = plot(evlo, evla, 'r*');
        evt_tx(evt_ct) = text(evlo, evla, sprintf('Fig. %i', i), 'Color', purp);

        %% For every SAC associated with that ID
        for k = 1:length(idsac)
            [~, h] = readsac(fullsac(idsac{k}));

            stla = h.STLA;
            stlo = h.STLO;
            stlo(find(stlo<0)) = stlo(find(stlo<0)) + 360;

            [trla, trlo] = track2('gc', evla, evlo, stla, stlo);
            trlo(find(trlo<0)) = trlo(find(trlo<0)) + 360;

            %% Plot the seismograms ACTUALLY SHOWN in black
            %% Except, I want Fig. 9 (model residuals) in gray
            if any(contains(idsac{k}, figsac{i})) && i ~= 9
                sac_ct = sac_ct + 1;
                Color = 'k';
                plk(sac_ct) = plot(trlo, trla, 'Color', Color, 'LineWidth', 2*lw);

            %% And all others in gray (including those in Fig. 9)
            %% Because I do not ACTUALLY SHOW seismograms in Fig. 9
            else
                Color = [0.6 0.6 0.6];
                plg = plot(trlo, trla, 'Color', Color, 'LineWidth', 2*lw);

            end
        end
    end
end

% Ensure black lines plotted over gray
for i = 1:length(plk)
    plk(i).ZData = ones(size(plk(i).XData));

end

% Add GPS drift tracks
gps = readgps;
endtime = datetime('31-Dec-2019 23:59:59.999', 'TimeZone', 'UTC');
mermaids = fieldnames(gps);
C = x2color([1:16], 1, 16, jet(16*4-1), false);
S = 25;
for i = 1:length(mermaids)
    rm_idx = find(gps.(mermaids{i}).locdate > endtime);
    gpla = gps.(mermaids{i}).lat;
    gplo = gps.(mermaids{i}).lon;
    gplo(find(gplo<0)) = gplo(find(gplo<0)) + 360;
    sc.(mermaids{i}) = scatter(gplo, gpla, S, C(i,:), 'Filled');
    sc.(mermaids{i}).ZData = 2*ones(size(sc.(mermaids{i}).XData));

end
set(ax, 'DataAspectRatio', [1 1 1])
xlim([175 240])
ylim([-35 -5])
box on
longticks(ax, 3)

axesfs([], 15, 15)

% Add degree symbols to ticklabels.
ax.YTickLabels = degrees(ax.YTick);
ax.XTickLabels = degrees(ax.XTick-360);
latimes

moveh(cb.Label, 0.25)
savepdf([mfilename '_labeled'])
delete([evt_pl evt_tx])
savepdf(mfilename)
