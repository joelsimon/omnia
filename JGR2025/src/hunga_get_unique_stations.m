function station = hunga_get_unique_stations()
% station = HUNGA_GET_UNIQUE_STATIONS
%
% Determine which SAC files need to be merged
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 12-Apr-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

sacdir = fullfile(getenv('HUNGA'), 'sac');
sacfile = globglob(sacdir, '*.sac');

station = struct();
for i = 1:length(sacfile)
    [~, h] = readsac(sacfile{i});

    if ~isfield(station, h.KSTNM)
        station.(h.KSTNM) = {strippath(sacfile{i})};

    else
        station.(h.KSTNM) = [station.(h.KSTNM) {strippath(sacfile{i})}];

    end
end
