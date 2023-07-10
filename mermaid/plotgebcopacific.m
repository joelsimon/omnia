function F = plotgebcopacific()
% F = PLOTGEBCOPACIFIC
%
% Plot GEBCO basemap of entire South Pacific: 120 -> 300 E; -60 -> 80 N.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 10-Jul-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Plot basemap.
F.f = figure;
F.ha = gca;

matfile = fullfile(getenv('IFILES'), 'TOPOGRAPHY', 'PACIFIC', 'c11_120-80_cmn_300-neg60.mat');
load(matfile)

% Check matfile name for bounding box.
c11 = [120 80];
cmn = [300 -60];

% Color bar first...
cax = [-7000 1500];
[F.cb, F.cm] = cax2dem(cax, 'hor');

% then map
F.bathy = imagefnan(c11, cmn, z, F.cm, cax);

% then colorbar again for adequate rendering
[F.cb, C. cm] = cax2dem(cax);
F.cb.Location = 'EastOutside';
F.cb.Label.String = 'GEBCO Elevation (m)';
