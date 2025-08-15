function fig5c
% FIG5C
%
% Panel C of Figure 5: Occlusion-counting schematic.
%
% Cause it's easier to program than draw, right?
%
% See also: hunga_profbathschem to finish.
%
% Developed as: hunga_schematic2.m then fig9c.m
% (itself hunga_schematic.m, but normalized distances and radii)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 07-Aug-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

clc
close all

% This was modified from an original example that used the following (realistic)
% values; FJS and JCEI preferred a (0 -> 1) axes, so I just dived/overwrote
% labels so that I don't have to rewrite all the hardcoded annotations/text below.
r = [0:1500]*1e3;
R = r(end);
v = 1500;
f = 2.5;

fr = fresnelradius(r, R, v, f);

figure
ax = axes;
hold(ax, 'on');
ax.Box = 'on';
ax.YDir = 'reverse';

% plfrb = plot(r/1e3, fr/1e3);
% plfrb.Color = 'k';
% plfrb.LineStyle = '-';
% plfrb.LineWidth = 1.5*1.4;

plfr = plot(r/1e3, fr/1e3);
plfr.Color = 'm';
plfr.LineStyle = '-';
plfr.LineWidth = 1.5;

% plfr06b = plot(r/1e3, 0.6*fr/1e3);
% plfr06b.Color = 'k';
% plfr06b.LineStyle = '-';
% plfr06b.LineWidth = 1.5*1.4;

plfr06 = plot(r/1e3, 0.6*fr/1e3);
plfr06.Color = orange;
plfr06.LineStyle = '-';
plfr06.LineWidth = 1.5;

shrink(ax, 0.9, 3);

% pllosb = plot(ax.XLim, [0 0], 'k');
% pllosb.LineStyle = '-';
% pllosb.LineWidth = 1.5*1.4;

pllos = plot(ax.XLim, [0 0], 'r');
pllos.LineStyle = '-';
pllos.LineWidth = 1.5;

xticks([0:125:1500]);
xticklabels({'Source' '' '' '' '' '' '' '' '' '' '' '' 'Receiver'})
ax.XAxis.TickLabelRotation= 0
yticks([0:3:15]);
yticklabels({'0.0', '0.2', '0.4' '0.6' '0.8', '1.0'});
xlabel('Distance From Source')
ax.XLabel.Position(2) = -1.5;
ylabel(sprintf('Distance From GCP\nMax. Fresnel Radius'))
ax.XAxisLocation = 'Top';
grid(ax, 'on');
grid(ax, 'on');
ylim(ax, [0 16])
longticks(ax, 3)

col = repmat(0.8, 1, 3);

r250 = fill([200 300 300 200], [8 8 13 13], col);
r750 = fill([700 800 800 700], [5 5 12 12], col);
r1000 = fill([950 1050 1050 950], [0 0 2 2], col);
r1250 = fill([1200 1300 1300 1200], [3 3 6 6], col);

pa250 = plot([250 250], [0 7.5], 'Color', 'black', 'LineWidth', 1.5);
pl250 = plot(250, 7.25, 'v', 'MarkerFaceColor', 'black', 'MarkerEdgeColor', 'black');
phi250 = text(280, 5, '{\itF} = 0.7\cdot{\itF}{_1}', 'Color', 'black');

fr500 = fresnelradius(500e3, R, v, f)/1e3;
pa500 = plot([500 500], [0 fr500-0.5], 'Color', 'black', 'LineWidth', 1.5);
pl500 = plot(500, fr500-0.75, 'v', 'MarkerFaceColor', 'black', 'MarkerEdgeColor', 'black');
phi500 = text(530, 5, '{\itF} = {\itF}{_1}', 'Color', 'black');

lg = legend([pllos plfr06 plfr pl250 r250], 'Great-circle path', '0.6\cdotFresnel Radius', 'Fresnel Radius', 'Clearance', 'Occlusion', 'Location', ...
            'SouthEast', 'Box', 'on', 'AutoUpdate', 'off');
% lg = legend([pllos plfr06 plfr pl250 r250], 'Great-circle path', '0.6\times Fresnel Radius', 'Fresnel Radius', 'Clearance', 'Occlusion', 'Location', ...
%             'SouthEast', 'Box', 'on', 'AutoUpdate', 'off');

posx = [0:250:1500];
posx = posx(2:end-1);

s3 = {'0.7' '1.0' '0.3' '0.0 ' '0.3'};
l3 = text(posx, repmat(17.5, size(posx)), s3, 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Top');

s4 = {'0' '0' '0' '1 ' '0'};
l4 = text(posx, repmat(20, size(posx)), s4, 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Top');

s5 = {'0' '0' '1' '1 ' '1'};
l5 = text(posx, repmat(22, size(posx)), s5, 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Top');

s6 = {'1' '0' '1' '1 ' '1'};
l6 = text(posx, repmat(24, size(posx)), s6, 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Top');

sym_posx = repmat(90, 1, 4);
div = text(90, 17.5, '{\itF} / {\itF}_{1}', 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Top');
lam00 = text(90, 20, '\Lambda_{\color{red}{0.0}}', 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Top');
lam06 = text(90, 22, '\Lambda_{\color{orange}{0.6}}', 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Top');
lam10 = text(90, 24, '\Lambda_{\color{magenta}{1.0}}', 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Top');

eql1 = text(repmat(187.50, 1, 4), [17.5 20 22 24], {'=' '=' '=' '='}, 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Top');
eql2 = text(1500-[187.5 187.5 187.5], [20 22 24], {'=' '=' '='}, 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Top');

plus1 = text(repmat(375, 1, 3), [20 22 24], {'+' '+' '+'}, 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Top');
plus2 = text(repmat(625, 1, 3), [20 22 24], {'+' '+' '+'}, 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Top');
plus3 = text(repmat(875, 1, 3), [20 22 24], {'+' '+' '+'}, 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Top');
plus4 = text(repmat(1125, 1, 3), [20 22 24], {'+' '+' '+'}, 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Top');

sum0 = text(1395, 20, '1' , 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Top', 'Color', 'r');
sum06 = text(1395, 22, '3' , 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Top', 'Color', orange);
sum10 = text(1395, 24, '4' , 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Top', 'Color', 'm');

ttxt = text(60, -2, '{\itT}-Wave \Rightarrow');

% Line for division in ylabel
div_lin = annotation('line', [0.022 0.022], [0.4 0.63]);
latimes2

uistack([pllos r250 r750 r1000 r1250 pa250 pa500 plfr plfr06], 'top')
ax.XAxis.TickLabelRotation = -30;

lbC = text(60, 1.5, 'C', 'FontName', 'Helvetica', 'FontWeight',  'Bold', 'FontSize', 12);

savepdf(mfilename)
