function hunga_write_stdp2header()
% HUNGA_WRITE_STDP2HEADER
%
% ONE-TIME-USE FUNCTION to read station depths from stdp.txt and write them into
% the STDP field of *REQ*.sac header.
%
% Note I had to compile stdp.txt manually because .REQ files don't include STDP
% in the header. So there is no "write_stdp." function to write that .txt file.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 26-Jan-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

hundir = getenv('HUNGA');
sacdir = fullfile(hundir, 'sac');
sac = globglob(sacdir, '*.sac');
stdp = hunga_read_stdp();

for i = 1:length(sac)
    if isimssac(sac{i})
        % Already (re)wrote those manually with hunga_ims_station_location_update.m
        continue

    end
    [x, h] = readsac(sac{i});
    h.STDP = stdp.(h.KSTNM);
    writesac(x, h, sac{i});

end
