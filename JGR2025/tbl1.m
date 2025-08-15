function tbl1
% TBL1
%
% Write Table 1: Fresnel radii for different frequencies/distances.
%
% Developed as: hunga_write_fresnel_radii_table.m tbl2.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 15-Aug-2025, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

clc

% T wave frequencies, Hz.
freqs = [2.5:2.5:10];

% Representative stations for table.
kstnm = {'P0054', ...
         'P0021', ...
         'H03N1'};

% T wave velocity in m/s.
c = 1480;

% Read great-ricle file
gc = hunga_read_great_circle_gebco;

% Open file.
fname = fullfile(getenv('HUNGA'), 'code', 'static', [mfilename '.txt']);
writeaccess('unlock', fname, false)
fid = fopen(fname, 'w+');

% Write commented frequency header line -- should be able to just strip this
% out and put in .tex file; separating it in case I want, e.g., a line
% between header and data.
fprintf(fid, '%sReceiver', '%');
for j = 1:length(freqs)
    fprintf(fid, ' & $f=$%.1f~Hz', freqs(j));

end
fprintf(fid, '\n');

for i = 1:length(kstnm)
    station = kstnm{i};
    R_km = gc.(station).tot_distkm;
    R_m = R_km * 1e3;

    fprintf(fid, station);
    for j = 1:length(freqs)
        f = freqs(j);
        fr_max_m  = fresnelmax(c, f, R_m);

        % Check code to ensure max radius at middle of path.
        fr_mid_m = fresnelradius(R_m/2, R_m, c, f);
        if abs(fr_max_m - fr_mid_m) > 1e-10
            error('radius at midpoint does not equal max radius')

        end

        % Write radii in km.
        fr_max_km = fr_max_m / 1e3;
        fprintf(fid, ' & %2i km', round(fr_max_km));

    end
    fprintf(fid, '\\\\ \n');

end
fclose(fid);
writeaccess('lock', fname)
fprintf('Wrote: %s\n', fname)