function tot_sec = hunga_totaltime()
% tot_sec = HUNGA_TOTALTIME
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 16-Sep-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

hundir = getenv('HUNGA');
sacdir = fullfile(hundir, 'sac');
sac = globglob(sacdir, '*.sac');
xsac = onlyfilledsac(sac);
%sac(find(endsWith(sac, 'merged.filled.sac'))) = []; % should be identical
sac = rmbadsac(sac);

stime_sec = 0;
gtime_sec = 0;
for i = 1:length(sac)
    [~, hdr] = readsac(sac{i});
    gap = readgap(sac{i});
    fs = efes(hdr, false);

    stime = seistime(hdr);
    ssec = seconds(stime.E - stime.B);
    stime_sec = stime_sec + ssec;

    for j = 1:length(gap)
        % Don't subtract 1 sample to conver to seconds
        % (every sample filled represents one sampling interval)
        gsamp = gap{j}(end) - gap{j}(1);
        gsec = gsamp * hdr.DELTA;
        gtime_sec = gtime_sec + gsec;

    end
end

% Total time is trace time minus gap time.
tot_sec = stime_sec - gtime_sec;
