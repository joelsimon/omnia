function [filledsac, gap] = mergedsac2filledsac(sac, plt)
% [filledsac, gap] = MERGEDSAC2FILLEDSAC(sac, plt)
%
% (depreciated: ended up not saving *filled.sac files; filled gaps at runtime)
% 
% Fill gaps in SAC file and write *merged.filled.sac.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 28-Sep-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

close all
defval('perc', 25)
defval('plt', true)

sacdir = fullfile(getenv('HUNGA'), 'sac');
metadir = fullfile(sacdir, 'meta');
ser = getmerser(sac);

% So that I can input a pathless .sac file from different directory
if strcmp(sac, strippath(sac))
    sac = fullfile(sacdir, sac);

end

% Delete any existing *merged.filled.sac
oldsac = globglob(sacdir, sprintf('*.%s_*merged.filled.sac', ser));
for i = 1:length(oldsac)
    if isgitfile(oldsac{i})
        system(sprintf('git -C %s rm -f %s', sacdir, strippath(oldsac{i})));

    else
        delete(oldsac{i});

    end
end

% Read *.sac
[x, h] = readsac(sac);

% Read sac2mergedsac_*_gap.mat (gaps that were zero-filled during merge)
gap = readgap(sac);

if ~isempty(gap)
    [interp_x, interp_val, interp_idx, gap_idx] = interpgap(x, gap, perc, plt);

    % Write *merged.filled.sac
    % Don't overwrite -- append to current filename and be sure to delete old.
    filledsac = strrep(sac, 'merged.sac', 'merged.filled.sac');
    writesac(interp_x, h, filledsac);
    fprintf('Wrote: %s\n', filledsac)

    % Write gapfill_*.out
    f = fullfile(metadir, sprintf('%s_%s.out', mfilename, ser));
    writeaccess('unlock', f, false);
    fid = fopen(f, 'w');
    fprintf(fid, 'Gapfill: %s\n', strippath(sac));
    fprintf(fid, 'Interp1: Considered %i%s of gap length before/after\n\n', perc, '%');
    for i = 1:length(gap)
        fprintf(fid, sprintf('Gap %i ->\n', i));
        fprintf(fid, '    Indices (MATLAB starts at 1; SAC starts at 0):\n');
        fprintf(fid, '    %i\n', gap_idx{i}');
        fprintf(fid, '    \n');
        fprintf(fid, '    Interpolation values:\n');
        fprintf(fid, '    %.1f\n', interp_val{i}');
        fprintf(fid, '\n');

    end
    writeaccess('lock', f, false);
    fprintf('Wrote: %s\n', f);

else
    filledsac = [];
    fprintf('No gaps to fill in %s\n', strippath(sac))

end
