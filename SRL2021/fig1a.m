function fig1a
% FIG1A
%
% Plots ray paths on global map.
%
% Developed as: simon2021_map1
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 11-May-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

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

% Define `getsac` inputs.
returntype = 'DET';
incl_prelim = false;

%% ___________________________________________________________________________ %%
%%                             Global map                                      %%
%% ___________________________________________________________________________ %%
% Generate base map.
f = figure;
ax = gca;
fig2print(f, 'flandscape')

origin = [0 211.6];
axm = axesm('MapProjection', 'Hammer', 'Origin', origin);
geoshow(axm, 'landareas.shp', 'FaceColor', [1 1 1]);
setm(gca, 'FFaceColor', [0.85 0.85 0.85]);
framem('on')
hold(gca, 'on')

% MarkerSize and LineWidth.
S = 20;
lw = 0.5;

% Plot the plate boundaries.  Use 0:360 degrees because: (1) that's allowed, and
% (2) I don't have to average NaNs around the wrap at 180 degrees.
[~, ~, plat, plon] = plateboundaries;
plp = plotm(plat, plon, 'k', 'LineWidth', lw);

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
        EQ = getevt(idsac{1});

        evt_pl(evt_ct) = plotm(EQ.PreferredLatitude, EQ.PreferredLongitude, 'r*');
        evt_tx(evt_ct) = textm(EQ.PreferredLatitude, EQ.PreferredLongitude, ...
                               sprintf('Fig. %i', i), 'Color', purp);

        %% For every SAC associated with that ID
        for k = 1:length(idsac)
            [~, h] = readsac(fullsac(idsac{k}));
            [trla, trlo] = track2('gc', ...
                                  EQ.PreferredLatitude, ...
                                  EQ.PreferredLongitude, ...
                                  h.STLA, ...
                                  h.STLO);

            %% Plot the seismograms ACTUALLY SHOWN in black
            %% Except, I want Fig. 9 (model residuals) in gray
            if any(contains(idsac{k}, figsac{i})) && i ~= 9
                sac_ct = sac_ct + 1;
                Color = 'k';
                plk(sac_ct) = plotm(trla, trlo, 'Color', Color, 'LineWidth', 2*lw);

            %% And all others in gray (including those in Fig. 9)
            %% Because I do not ACTUALLY SHOW seismograms in Fig. 9
            else
                Color = [0.6 0.6 0.6];
                plg = plotm(trla, trlo, 'Color', Color, 'LineWidth', 2*lw);

            end
        end
    end
end
tightmap
axis off

% Add bounding box of zoom in
plb(1) = plotm([-5 -5], [175 240]);
plb(2) = plotm([-35 -35], [175 240]);

plb(3) = plotm([-5 -35], [175 175]);
plb(4) = plotm([-5 -35], [240 240]);

set(plb, 'Color', 'k', 'LineWidth', 0.25)

% Ensure black lines plotted over gray
for i = 1:length(plk)
    plk(i).ZData = ones(size(plk(i).ZData));

end

% Add GPS drift tracks
gps = readgps;
endtime = datetime('31-Dec-2019 23:59:59.999', 'TimeZone', 'UTC');
mermaids = fieldnames(gps);
C = x2color([1:16], 1, 16, jet(16*4-1), false);
S = 1;
for i = 1:length(mermaids)
    rm_idx = find(gps.(mermaids{i}).locdate > endtime);
    gps.(mermaids{i}) = rmstructindex(gps.(mermaids{i}), rm_idx);
    sc.(mermaids{i}) = scatterm(gps.(mermaids{i}).lat, gps.(mermaids{i}).lon, ...
                                S, C(i,:), 'Filled');
    sc.(mermaids{i}).Children.ZData = 2*ones(size(sc.(mermaids{i}).Children.XData));
    lgstr{i} = mermaids{i}(end-1:end);

end
lg = legend(struct2array(sc), lgstr{:})
axesfs([], 15, 15)
latimes

% Add MERMAID legend
lg.Location = 'EastOutside';
lg.Color = 'none';
lg.Orientation = 'Vertical';
lg.Box = 'off';
lg.Position(1) = 0.91;
lg.Position(2) = 0.275

savepdf([mfilename '_labeled'])
delete([evt_pl evt_tx])
savepdf(mfilename)
