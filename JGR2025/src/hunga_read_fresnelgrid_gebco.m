function fg = hunga_read_fresnelgrid_gebco(kstnm, freq, matdir)
% fg = HUNGA_READ_FRESNELGRID_GEBCO(kstnm, freq, matdir)
%
% Return (gridded; equal area) Fresnel-zone tracks, GEBCO-elevations, etc.
%
% Columns of lat/lon are Fresnel-tracks (sub)parallel to great-circle (middle
% column; `gcidx`). Rows of lat/lon are Fresnel-radii perpendicular to
% great-circle.
%
% Input:
% kstnm     Five-character MERMAID station name (e.g., 'P0016')
% freq      Frequency (Hz)
% matdir    Directory where hunga_write_fresnelgrid_gebco_<Hz>_<KSTNM>.mat saved
%               (def: $HUNGA/code/static/)
%
% Output:
% fg        Struct with fieldnames:
%           .lat: Fresnel-grid latitudes [deg]
%           .lon: Fresnel-grid longitudes [deg]
%           .depth_m: GEBCO 2014 depth at lat/lon [m]
%           .gcdist_m: Cumulative distance along great-circle path [m]
%           .fr_m: Fresnel-radius along great circle path [m]
%           .gcidx: Column index of great-circle path (gclat=lat(:, gcidx))
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 20-Mar-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('matdir', fullfile(getenv('HUNGA'), 'code', 'static'));

if ischar(freq)
    error('Input freq must be number (not string)')

end

%% RECURSIVE
if length(freq) > 1
    for i = 1:length(freq)
        fg(i) = hunga_read_fresnelgrid_gebco(kstnm, freq(i), matdir);


    end
    return

end
%% RECURSIVE

fname = fullfile(matdir, sprintf('hunga_write_fresnelgrid_gebco_%.1fHz_%s.mat', freq, kstnm));
tmp = load(fname);
fg = tmp.fg;
