function fig4c(plot_mermaids)
% FIG4C(plot_mermaids)
%
% REQUIREMENTS: first run winnow_cluster_votes_Vp_CottaarLekic2016.sh
%
% Plots a map of Vp votes from Cottaar+2016, doi: 10.1093/gji/ggw324, with the
% deployment locations of the 16 Princeton MERMAIDs overlain.
%
% The number of slow Vp votes is displayed as a 1x1 degree box centered on the
% relevant integer lon/lat (which are squares; the data aspect ratio here is 1:1
% so lon/lat degrees are equal distance) without overlap, thus the box edges are
% on a +XXX.5 degree grid.  Thus the values on the edge of the axis have only
% 1/2 of their box area visible (the other half is cut off by the axis), while
% those in the corner have only 1/4 of their box visible (the vote count in the
% corner of the axis has the middle of the box exactly on the lon/lat in the
% corner of the axis, thus only 1/4 of the box area is inside the axis, while
% 3/4 of the box are is outside).
%
% Developed as: $SIMON2020_CODE/simon2020_vp_vote_map.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 23-Jun-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('plot_mermaids', true)

clc
close all

% Prep the figure.
figure
ha = gca;
hold(ha, 'on')
fig2print(gcf, 'flandscape')
fs = 13;
axesfs(gcf, fs, fs+2)
latimes
xlim([176 251])
ylim([-33 4])

tx = text(ha, 170, 5, '(c)', 'FontSize', 18, 'FontName', 'Times', 'Interpreter', 'LaTex');
box(ha, 'on')

longticks(ha, 3);

% Equalize degrees in N/S and E/W directions.
set(ha, 'DataAspectRatio', [1 1 1])

%%______________________________________________________________________________________%%
%%                       Plot the background Vp vote map                                %%
%%______________________________________________________________________________________%%

% Read and parse color palette text file.
fid = fopen(fullfile(getenv('GJI21_CODE'), 'data', 'vp_vote.cpt'));
fmt = '%1f %3f %3f %3f\n';
C = textscan(fid, fmt, 'HeaderLines', 2);
cmap = [C{2} C{3} C{4}]/255;
fclose(fid);

% Read and parse the winnowed cluster analysis Vp vote file.  The columns are
% longitude, latitude, number of slow Vp votes, all at 2700 km within the
% "nearby" bounding box.
[lon, lat, col] = read_winnowed_cluster_votes_Vp(cmap);

% Verify the color indices OF THE CORNERS are the same regardless of which edge
% you pull them from (e.g., the top left edge is seen by the "top" and the
% "left" color matrices).
%% See pg. S123, 2017.2 for a picture.
a = isequal(col.top(1,:), col.left(end,:));     % top left corner.
b = isequal(col.top(end,:), col.right(end,:));  % top right
c = isequal(col.bottom(end,:), col.right(1,:)); % bottom right
d = isequal(col.bottom(1,:), col.left(1,:));    % bottom left
if ~all([a b c d])
    error(['The color rgb triplets for the corners differ depending on if you ' ...
           'pull them from the first/last indices of the top(bottom) edge or ' ...
           'the left(right) edge.'])

end

% Marker size that just-so-happens to make he square scatter-plot markers fit
% exactly into a 1x1 degree box with minimal overlap.
markersize = 133.136;
shift = 0.555;

%% 1: Corners* (notes at bottom)
sc.top_left = scatter(ha, lon.top(1)+shift, lat.top(1)-shift, markersize, ...
                      col.top(1,:), 'Filled', 'Marker', 'square');
sc.top_right = scatter(ha, lon.top(end)-shift, lat.top(end)-shift, markersize, ...
                  col.top(end,:), 'Filled', 'Marker', 'square');
sc.bottom_right = scatter(ha, lon.bottom(end)-shift, lat.bottom(end)+shift, markersize, ...
                  col.bottom(end,:), 'Filled', 'Marker', 'square');
sc.bottom_left = scatter(ha, lon.bottom(1)+shift, lat.bottom(1)+shift, markersize, ...
                         col.bottom(1,:), 'Filled', 'Marker', 'square');

%% 2: Edges*
sc.left = scatter(ha, lon.left(2:end-1)+shift, lat.left(2:end-1), markersize, ...
                  col.left(2:end-1,:), 'Filled', 'Marker', 'square');
sc.right = scatter(ha, lon.right(2:end-1)-shift, lat.right(2:end-1), markersize, ...
                   col.right(2:end-1,:), 'Filled', 'Marker', 'square');
sc.bottom = scatter(ha, lon.bottom(2:end-1), lat.bottom(2:end-1)+shift, markersize, ...
                    col.bottom(2:end-1,:), 'Filled', 'Marker', 'square');
sc.top = scatter(ha, lon.top(2:end-1), lat.top(2:end-1)-shift, markersize, ...
                 col.top(2:end-1,:), 'Filled', 'Marker', 'square');

%% 3: Interior*
sc.interior = scatter(ha, lon.interior, lat.interior, markersize, col.interior, ...
                      'Filled', 'Marker', 'square');

% Add colorbar grading from pink to red/black corresponding to 0 to 5 slow Vp votes.
colormap(ha, cmap)
[~, cbticks, cbticklabels] = x2color([0:5], 0, 5, cmap, true);
cb = colorbar('Location', 'EastOutside');
cb.XTick = cbticks;
cb.TickLabels = cbticklabels;
cb.Label.Interpreter = 'LateX';
cb.Label.String = {'Number of slow V\hspace{-0.25em}$_{\textit{P}}$ votes among 5 models' ...
                   '(Cottaar \& Leki{\''c}, 2016)'};
cb.FontSize = fs;
cb.Label.FontSize = fs;

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

%% Cosmetics.

xlabel('Longitude')
ylabel('Latitude')
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

cb.TickDirection = 'out';
cb.TickLength = 0.015;

% Save it.
moveh(cb.Label, 0.18)
latimes
savepdf('fig4c')


%%______________________________________________________________________________________%%
%%                                  EOF
%%______________________________________________________________________________________%%

function [lon, lat, col] = read_winnowed_cluster_votes_Vp(cmap)
% Function to read and parse the relevant winnowed text file.

region = {'interior', 'left', 'right', 'bottom', 'top'};

for i = 1:length(region)
    fid = fopen(fullfile(getenv('GJI21_CODE'), 'data', ...
                         sprintf('winnowed_cluster_votes_Vp_CottaarLekic2016_%s.txt', region{i})));
    fmt = '%3f %3f %1f';
    C = textscan(fid, fmt);
    lon.(region{i}) = C{1};
    lat.(region{i}) = C{2};
    votes.(region{i}) = C{3}; % Votes for slow Vp
    fclose(fid);

    % Map the number of slow Vp votes to the pink --> red/black colormap supplied by
    % Jessica.
    col.(region{i}) = x2color(votes.(region{i}), 0, 5, cmap);

end

%% Notes
% *Order of operations so that the colored squares do not overlap the edge of
% the axis.
%
% (1). First, plot the four corners (x(1) and x(end)). However, instead of
% plotting the 1x1 degree square at the corner where it would have 3/4 of its
% area outside of the axis, manually shift it inside (e.g., down and right in
% the top left corner) so that the entire colored-square is inside the axis.
%
% (2). Next, plot the top/right/bottom/edges: Except, only plot x(2:end-1) so
% that the corners are not plotted (done in the previous step).  Similar to the
% corners, to avoid 1/2 of the box area being outside of the axis, manually
% shift their boxes inside the axis (e.g., up for the bottom edge) so that the
% entire colored-square is inside the axis.  Because the edges come second to
% the corners, they overlap the corners so that only 1/4 of corners' box area is
% visible, representing the portion of the corner's lon/lat that would be
% visible inside the axis.
%
% (3). Finally, plot the interior of the map.  Now the final data (which do not
% include the degrees of lon/lat at the edges) will overlap those edge-boxes in
% the previous step so that only 1/2 of their box area, representing the number
% of votes on the edge, is visible.
%
% *To see what I mean, color the corner and/or edge pieces green.
