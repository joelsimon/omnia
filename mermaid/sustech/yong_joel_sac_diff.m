function yong_joel_sac_diff()
% YONG_JOEL_SAC_DIFF
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu | joeldsimon@gmail.com
% Last modified: 08-Sep-2023, Version 9.3.0.713579 (R2017b) on GLNXA64

mer_dir = getenv('MERMAID');

yong_dir = fullfile(mer_dir, 'sustech_by_yong', 'processed');
joel_dir = fullfile(mer_dir, 'processed_sustech');

yong_sac = globglob(yong_dir, '**/*.sac');
joel_sac = globglob(joel_dir, '**/*.sac');

yong_bname = strippath(yong_sac);
joel_bname = strippath(joel_sac);

xtra_yong = setdiff(yong_bname, joel_bname);

[~, yong_idx, joel_idx] = intersect(yong_bname, joel_bname);
yong_sac = yong_sac(yong_idx);
joel_sac = joel_sac(joel_idx);

fname = fullfile(joel_dir, 'compare_yong_joel', sprintf('%s.txt', mfilename));

writeaccess('unlock', fname, false)
fid = fopen(fname, 'w');
for i = 1:length(joel_sac)
    fprintf('%05i of %i\n', i, length(joel_sac))

    [xy, hy] = readsac(yong_sac{i});
    [xj, hj] = readsac(joel_sac{i});

    if ~isequal(xy, xj)
        fprintf(fid, '%05i | %s | data\n', i, strippath(joel_sac{i}));
        continue

    end

    sdy = seistime(hy);
    sdj = seistime(hj);

    sdiff = seconds(sdy.B - sdj.B);
    ediff = seconds(sdy.E - sdj.E);
    if abs(sdiff) > 1/1000 or abs(ediff) > 1/1000
        fprintf(fid, '%05i | %s | time\n', i, strippath(joel_sac{i}));
        continue

    end

    mdiff = 1000 * grcdist([hy.STLO hy.STLA], [hj.STLO hj.STLA]); % meters
    if abs(mdiff) > 100
        fprintf(fid, '%05i | %s | location\n', i, strippath(joel_sac{i}));

    end


end
fclose(fid);
writeaccess('lock', fname)

fprintf('\nYong made these additional .sac files that Joel did not...\n')
for i = 1:length(xtra_yong)
    fprintf('%s\n', xtra_yong{i})

end

% "Yong's" event directory, as transmitted to me, most of which I kept but with
% `updatetauptimes` is ~/mermaid/sustech_by_yong/events
fprintf('Checking to verify Joel deleted those corresponding .evt files in Joel''s event/ directory...\n')
joel_evtdir = fullfile(getenv('MERMAID'), 'events_sustech');
for i = 1:length(xtra_yong)
    fprintf('Looking for %s .evt file\n', xtra_yong{i})
    [xtra_EQ, xtra_evt] = getrevevt(xtra_yong{i},  joel_evtdir);
    if isstruct(xtra_EQ);
        fprintf('!!! Must delete: %s !!\n\n', xtra_evt);

    else
        fprintf('(all good, already deleted)\n\n')

    end
end
