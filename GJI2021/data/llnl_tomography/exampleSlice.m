clear,clc

load('LLNL_500km_Slice.mat')

p1 = slice(lon,lat,z,V,[],[],500);
set(p1,'EdgeColor','none')
grid on
xlim([min(lon) max(lon)])
ylim([min(lat) max(lat)])
zlim([499 501])
c = colorbar;
c.Label.String = '$\delta\mathrm{V}\hspace{-.25em}_{P}$ (\%)';
c.Label.Interpreter = 'latex';
c.TickLabelInterpreter = 'latex';
c.Label.FontSize = 11;
c.Location = 'southoutside';
set(c,'TickDir','out')
colormap(flipud(jet))
caxis([-2 2])
box on
view(0,90)
ax = gca;
ax.FontSize = 12;
ax.TickDir = 'out';
ax.ZDir = 'reverse';
ax.DataAspectRatio = [1 1 7];
ax.YTick = [-30 -20 -10 0];
ax.YTickLabel = {'-30$^{\circ}$','-20$^{\circ}$',...
                 '-10$^{\circ}$','0$^{\circ}$'};
ax.XTick = [180 190 200 210 220 230 240 250];
ax.XTickLabel = {'-180$^{\circ}$','-170$^{\circ}$','-160$^{\circ}$',...
                 '-150$^{\circ}$','-140$^{\circ}$','-130$^{\circ}$',...
                 '-120$^{\circ}$','-110$^{\circ}$'};
xlabel('Longitude')
ylabel('Latitude')
zlabel('Depth (km)')
set(gcf,'Position',[0 0 600 400]);
title(sprintf('LLNL South Pacific Slice: %i km',500))