function [ax, cb] = plotsouthpacificbathy(lon, lat, cax, filename)
% [ax, cb] = PLOTSOUTHPACIFICBATHY(lon, lat, cax, filename)
%
% Plot the bathymetry of the South Pacific
%
% lat       Latitude boundaries, southing [90:-90] (def: [4 -33])
% lon       Longitude boundaries, westing [0:360] (def: [176 251])
% cax       Colorbar limits, postive is meters below surface (def: -7000 1500)]
% filename  Bathymetric .mat filename (from FJS)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 17-Nov-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults
% http://ds.iris.edu/gmap/#network=*&starttime=2018-06-01&maxlat=4&maxlon=251&minlat=-33&minlon=176&drawingmode=box&planet=earth
defval('lon', [176 251])
defval('lat', [4 -33])
defval('cax',[-7000 1500]);
defval('filename', fullfile(getenv('IFILES'),'TOPOGRAPHY','POLYNESIA','732c10d12f3c1ff02b85522b39bfd9ee1aa42244.mat'))

% Adjust cax, if required, to avoid division by zero.
cax(find(cax==0)) = cax(find(cax==0)) + 1e-3;

% Load data .mat file
load(filename)

lonvals = linspace(176, 251, size(z, 2));
lonidx =  nearestidx(lonvals, lon);

latvals = linspace(4, -33, size(z, 1));
latidx =  nearestidx(latvals, lat);
keyboard
z = z(latidx(1):latidx(2), lonidx(1):lonidx(2));

% Parse lat/lon boundaries into matrix elements.
c11 = [lon(1) lat(1)];
cmn = [lon(2) lat(2)];

% Color bar first...
[cb, cm] = cax2dem(cax, 'hor');

% ...then map...
imagefnan(c11, cmn, z, cm, cax);
ax = gca;

% ...then colorbar again for adequate rendering.
[cb, cm] = cax2dem(cax, 'hor');

% Cosmetics
xlabel('Longitude')
ylabel('Latitude')
cb.XLabel.String=sprintf('GEBCO %i elevation (m)', 2019);
cb.XTick=unique([cb.XTick minmax(cax)]);
