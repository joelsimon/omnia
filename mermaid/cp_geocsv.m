function cp_geocsv(proc_dir, cp_dir, det_req)
% CP_GEOCSV(proc_dir, cp_dir, det_req)
%
% Copies <proc_dir>/452.020-P-06/geo_[<DET>_<REQ>].txt to
% <cp_dir>/P0006_geo_[<DET>_<REQ>].txt
%
% Input:
% proc_dir      Fullpath to processed directory, containing GeoCSV files
% cp_dir        Fullpath to destination directory, were renamed GeoCSV sent
% det_req       1: copies geo_DET.csv
%               2: copies geo_REQ.csv
%               3: copies geo_DET_REQ.csv
%
% Ex:
%    CP_GEOCSV('~/mermaid/processed/452*', '~/mermaid/everyone/geocsv/', 1)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 01-Mar-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

switch det_req
  case 1
    fname = 'geo_DET.csv';

  case 2
    fname = 'geo_REQ.csv';

  case 3
    fname = 'geo_DET_REQ.csv';

  otherwise
    error('Specify 1, 2, or 3 for input det_req')

end

d = fullfiledir(skipdotdir(dir(proc_dir)));
for i = 1:length(d)
    geocsv_file = fullfile(d{i}, fname);
    if exist(geocsv_file, 'file') ~= 2
        continue

    end
    kstnm = osean2fdsn(strippath(d{i}));
    cp_file = fullfile(cp_dir, sprintf('%s_%s', kstnm, fname));
    system(sprintf('cp %s %s', geocsv_file, cp_file));

    % Lazy printout -- no check of status...
    fprintf('Copied: %s to %s\n', geocsv_file, cp_file);

end
