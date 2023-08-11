function VE1 = vertexag(ax, VE2, HorW)
% VE1 = VERTEXAG(ax, VE2, HorW)
%
% Compute current and/or adjust vertical exaggeration while holding current axis
% height or width constant.  Requires f.InnerPosition(3) == f.InnerPosition(4).
%
% NB: Check notes and warnings within code, and don't expect ax.DataAspectRatio
% to be correct after adjustment (TL;DR: adjustment is finicky, please verify).
%
% Input:
% ax       Axis handle
% VE2      Requested vertical exaggeration (axis adjusted if not empty; def [])
% Horw     'height': Adjust height to attain requested vertical exaggeration
%                    (hold width constant; def [])
%          'width': Adjust width to attain requested vertical exaggeration
%                 (hold height constant; def [])
%
% Output:
% VE1      Current/unadjusted vertical exaggeration of input axis
%
%
% % Before running Ex1 or Ex2, run the following -->
%    load('gebco.mat'); plot(dist_km, elev_m/1000);
%    xlabel('distance (km)'); ylabel('elevation (km)');
%    f = gcf; ax = gca; f.InnerPosition(3) = f.InnerPosition(4);
%
% Ex1: Adjust height so vertical exaggeration is 150
%    VERTEXAG(ax, 150, 'height');
%
% Ex2: Adjust width so vertical exaggeration is 375
%    VERTEXAG(ax, 375, 'width');
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 09-Aug-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

%% RECURSIVE.

% Defaults.
defval('VE2', []);
defval('HorW', []);

% Throw warning if f.InnerPosition
verifyInnerPosition(ax)

% Horizontal values.
p3 = ax.Position(3); % "distance on paper"
xl = range(ax.XLim); % "distance in real life"

% Vertical values.
p4 = ax.Position(4); % "distance on paper"
yl = range(ax.YLim); % "distance in real life"

% Scales are fractions of "distances on paper/distances in real life".
VS = p4/yl;
HS = p3/xl;

% Vertical exaggeration is the vertical scale over the horizontal scale.
VE1 = VS / HS;

if ~isempty(VE2)
    switch lower(HorW)
      case 'height'
        % Adjust height, hold width constant.
        adj_p4 = VE2 * HS * yl;
        ax.Position(4) = adj_p4;
        ax.Position(3) = p3;

      case 'width'
        % Adjust width, hold height constant.
        adj_p3 = VS / VE2 * xl;
        ax.Position(3) = adj_p3;
        ax.Position(4) = p4;

      otherwise
        error('Supply one of ''height'' or ''width'' for input ''HorW')

    end

    %% RECURSION
    % Bizare...have to run Ex2 twice to land on proper adjustment...
    while round(vertexag(ax)) ~= round(VE2)
        vertexag(ax, VE2, HorW);

    end
end


%% ___________________________________________________________________________ %%

function verifyInnerPosition(ax)
% *Controlling the vertical exaggeration (ax.DataAspectRatio) is a real pain in
% my MATLAB version R2017b and must be done carefully.  I have found that
% variously adjusting ax.DataAspectRatio before/after ax.Position(*) does not
% have the expected result, so it is always best to save the figure and manually
% verify (measure e.g. with the 'info' ruler in Mac Preview).  The best luck I
% have had requires that you set f.InnerPosition(3) = f.InnerPosition(4) (`f`
% being the the figure handle) BEFORE attempting to manually adjust the vertical
% exaggeration.  Further, sometimes an adjusted axis cannot be readjusted; the
% ax.Position values will change and feign the appearance of an adjusted
% vertical exaggeration when in fact the axis has not changed.

for i = 1:length(ax.Parent)
    h = ax.Parent(i);
    if isa(h, 'matlab.ui.Figure')
        if h.InnerPosition(3) ~= h.InnerPosition(4)
            error('Figure InnerPosition(3) ~= InnerPosition(4)\nSee note* in %s.m', mfilename)

        end
        break

    end
end
