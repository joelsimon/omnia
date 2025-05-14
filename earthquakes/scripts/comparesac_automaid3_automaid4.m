function comparesac_automaid3_automaid4(proc3, proc4)
% COMPARESAC_AUTOMAID3_AUTOMAID4(proc3, proc4)
%
% Run `comparesac` on all like SAC files for automaid v3 and v4.
%
% Input:
% proc3,4   Full paths to automaid v3,4 processed directories
%           (def: ~/mermaid/processed/ and ~/mermaid/processed_automaid-v4)
%
% Output:
% comparesac_automaid3_automaid4.txt printing all SAC files whose:
% * data differ
% * start or end times differ by more than the sampling interval
% * locations differ by more than 100 meters
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 14-May-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

defval('proc3', fullfile(getenv('MERMAID'), 'processed'));
defval('proc4', fullfile(getenv('MERMAID'), 'processed_automaid-v4'));

sac3 = fullsac([], proc3);
sac4 = fullsac([], proc4);

[~, idx3, idx4] = intersect(strippath(sac3), strippath(sac4));
sac3 = sac3(idx3);
sac4 = sac4(idx4);
lensac = length(sac3);

loc_thresh = 100; % meters

data_differ = {};
data_ct = 0;
max_time = 0;
max_loc = 0;

fname = fullfile(pwd, sprintf('%s.txt', mfilename));
writeaccess('unlock', fname, false)
fid = fopen(fname, 'w');
fprintf(fid, 'Analyzing %i SAC files with comparesac...\n\n', lensac);
for i = 1:lensac
    i
    sac = strippath(sac3{i});
    [data, time, loc, x, h, sd] = comparesac(sac3{i}, sac4{i});
    if ~data
        fprintf(fid, '%s data differ\n', sac)
        data_ct = data_ct + 1;
        data_differ{data_ct} = sac;

    end

    tdiff = max(abs(time)); % seconds
    if tdiff > h(1).DELTA
        fprintf(fid, '%s times differ: %.2f %.2f s\n', sac, time(1), time(2))
    end
    if tdiff > max_time
        max_time = tdiff;
        max_time_sac = sac;

    end

    if loc > loc_thresh % meters
        fprintf(fid, '%s location differs: %.1f m\n', sac, loc)

    end
    if loc > max_loc
        max_loc = loc;
        max_loc_sac = sac;

    end
end

fprintf(fid, '\nSummary....\n');
fprintf(fid, 'SAC files with different data:\n');
if ~isempty(data_differ)
    for i = 1:length(data_differ)
        fprintf(fid, '    %s\n', data_diff{i});

    end
else
    fprintf(fid, '    <none>\n');

end

fprintf(fid, '\nMax. time diff: %.6f s (%s)\n', max_time, max_time_sac);
fprintf(fid, '\nMax. location diff: %.1f m (%s)\n', max_loc, max_loc_sac);

fclose(fid);
writeaccess('lock', fname)

fprintf('Wrote: %s\n', fname)