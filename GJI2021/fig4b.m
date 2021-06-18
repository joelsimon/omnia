function fig4b(plot_mermaids)
% FIG4B(plot_mermaids)
%
% Local version of FJS' polynesia.m with some extra formatting touches.
% (for him, last modified by fjsimons-at-alum.mit.edu, 03/12/2020)
%
% Developed as: $SIMON2020/simon2020_bathy.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 11-Mar-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('plot_mermaids', true)

close all

%%______________________________________________________________________________________%%
%%                           Inspired by FJS' 'polynesia.m'                             %%
%%______________________________________________________________________________________%%

load(fullfile(getenv('IFILES'),'TOPOGRAPHY','POLYNESIA','732c10d12f3c1ff02b85522b39bfd9ee1aa42244.mat'))

% http://ds.iris.edu/gmap/#network=*&starttime=2018-06-01&maxlat=4&maxlon=251&minlat=-33&minlon=176&drawingmode=box&planet=earth
defval('c11',[176   4])
defval('cmn',[251 -33])
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

%%______________________________________________________________________________________%%
%%                                  Joel Edits                                          %%
%%______________________________________________________________________________________%%

fig2print(gcf, 'flandscape')

xlim([176 251])
ylim([-33 4])
ha = gca;
hold(ha, 'on')
set(ha, 'DataAspectRatio', [1 1 1])

fs = 13;

cb.FontSize = fs;
cb.Label.FontSize = fs;
cb.Label.Interpreter = 'latex';

movev(gca, 0.1)
movev(cb, 0.11)
cb.Ticks(9) = [];

ha.XTick = [180:10:250];
ha.XTickLabel = {'-180$^{\circ}$'  ...
                 '-170$^{\circ}$' ...
                 '-160$^{\circ}$' ...
                 '-150$^{\circ}$' ...
                 '-140$^{\circ}$' ...
                 '-130$^{\circ}$' ...
                 '-120$^{\circ}$' ...
                 '-110$^{\circ}$'};


ha.YTick = [-30:10:0];
ha.YTickLabel = flip({'0$^{\circ}$' ...
                    '-10$^{\circ}$' ...
                    '-20$^{\circ}$' ...
                    '-30$^{\circ}$'});

longticks(ha, 3)
cb.TickLength = 0.015;
cb.TickDirection = 'out';

axesfs(gcf, fs, fs+2)
latimes
cb.Location = 'EastOutside';

tx = text(ha, 170, 5, '(b)', 'FontSize', 18, 'FontName', 'Times', 'Interpreter', 'LaTex');

%%______________________________________________________________________________________%%
%%                    Overlay the MERMAID deployment locations
%%______________________________________________________________________________________%%
if plot_mermaids

    % This is stripped from fig1.m

    % Get the locations of all floats at the time of their deployment.
    datadir = fullfile(getenv('GJI21_CODE'), 'data');
    str = readtext(fullfile(datadir, 'misalo.txt'));

    mlat = cellfun(@(xx) str2double(xx(31:40)), str);
    mlon = cellfun(@(xx) str2double(xx(43:53)), str);

    % Assuming this file is sorted...
    P008_idx = cellstrfind(str, 'P008')';
    P025_idx = cellstrfind(str, 'P025')';
    Princeton_idx = P008_idx:P025_idx;

    % Convert to from 0:180 = -180:0 to 0:360 longitude convection.
    mlon(find(mlon<0)) = mlon(find(mlon<0)) + 360;

    % Plot MERMAIDs.
    pl = plot(ha, mlon(Princeton_idx), mlat(Princeton_idx), 'v', 'MarkerFaceColor', ...
              porange, 'MarkerEdgeColor', 'k', 'MarkerSize', 12);


end
%%______________________________________________________________________________________%%

% Save it.
moveh(ha, -0.03)
moveh(cb.Label, 0.25)
savepdf('fig4b')
