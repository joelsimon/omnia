function F = plotgebcopacific(cax)
% F = PLOTGEBCOPACIFIC(cax)
%
% Plot GEBCO basemap of entire South Pacific: 120 -> 300 E; -60 -> 80 N.
%
% Input:
% cax     Color-axis limits (discontinuous at 0) [def: [-7000 1500]]
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 11-Nov-2024, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

defval('cax', [-7000 1500])

% Plot basemap.
F.f = figure;
F.ha = gca;

matfile = fullfile(getenv('IFILES'), 'TOPOGRAPHY', 'PACIFIC', 'c11_120-80_cmn_300-neg60.mat');
load(matfile)

% Check matfile name for bounding box.
c11 = [120 80];
cmn = [300 -60];

% Color bar first...
[F.cb, F.cm] = cax2dem(cax);

% then map
F.bathy = imagefnan(c11, cmn, z, F.cm, cax);

% then colorbar again for adequate rendering
[F.cb, C. cm] = cax2dem(cax);
F.cb.Location = 'EastOutside';
F.cb.Label.String = 'GEBCO Elevation [m]';
