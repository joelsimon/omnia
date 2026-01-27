function hunga_comparesac(old_dir, new_dir)

old_dir = fullfile(getenv('HUNGA'), 'sac', 'unmerged');
new_dir = fullfile(getenv('MERMAID'), 'processed_everyone');

old_sac = globglob(old_dir, '*.sac');

fname = 'hunga_comparesac.txt';
fid = fopen(fname, 'w');
fprintf(fid, '                                          FILENAME     OLD_VER   NEW_VER DATA     TIME      LOC\n');

for i = 1:length(old_sac)
    new_sac{i} = fullsac(strippath(old_sac{i}), new_dir);
    if isempty(new_sac{i})
        continue

    end

    [data, time, loc, ~, hdr] = comparesac(old_sac{i}, new_sac{i});
    fprintf(fid, '%50s    %s    %s    %i    %5.2f    %5.1f\n', ...
            strippath(new_sac{1}), hdr(1).KUSER0, hdr(2).KUSER0, data, max(abs(time)), loc);


end
fclose(fid);