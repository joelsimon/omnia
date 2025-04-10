function tblA1
% TBLA1
%
% Table A1: Ocean depths as repoted by GEBCO vs IMS 
%
% Developed as: hunga_write_gebco_ims_elevation_table.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 26-Jan-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

hundir = getenv('HUNGA');
imsdir = fullfile(hundir, 'sac', 'ims');
staticdir = fullfile(hundir, 'code', 'static');

sac = sort(globglob(imsdir, '*sac.pa'));
triad = struct;
for i = 1:length(sac)
    h(i) = sachdr(sac{i});
    gebco_depth(i) = -round(gebco(h(i).STLO, h(i).STLA));
    ims_depth(i) = -h(i).STEL;
    diff_depth(i) = gebco_depth(i) - ims_depth(i);

    if isfield(triad, h(i).KSTNM(1:4))
        triad.(h(i).KSTNM(1:4)) = [triad.(h(i).KSTNM(1:4)) diff_depth(i)];

    else
        triad.(h(i).KSTNM(1:4)) = diff_depth(i);

    end
end

fname = fullfile(staticdir, [mfilename '.txt']);
fid = fopen(fname, 'w');
fmt = '%5s & %5i & %5i & %5i & %5i\\\\ \n';
for i = 1:length(sac)
    if endsWith(h(i).KSTNM, '2')
        ave_triad_diff = round(mean(triad.(h(i).KSTNM(1:4))));

    else
        ave_triad_diff = '';

    end
    fprintf(fid, fmt, h(i).KSTNM, gebco_depth(i), ims_depth(i), diff_depth(i), ave_triad_diff);

end
fclose(fid);

fprintf('Wrote: %s\n', fname)
