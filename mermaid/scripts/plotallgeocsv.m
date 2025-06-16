function plotallgeocsv
% PLOTALLGEOCSV
%
% QDP to verify GeoCSV not completely wonky.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 05-Jun-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

close all

f = globglob(fullfile(getenv('MERMAID'), 'processed_everyone', '**/*', 'geo_DET_REQ.csv'));

plotcont
hold on
for i = 1:length(f)
    try
        G = readGeoCSV(f{i});
        scatter(longitude360(G.Longitude), G.Latitude)

    catch
        warning(strippath(f{i}))
        keyboard

    end
end
box on
longticks([], 2)
