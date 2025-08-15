function sacworkflow2(ser)
% SACWORKFLOW2(ser)
%
% Re-merge and re-fill .sac, e.g., after removal of overlap/unused/bad .sac
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 01-Feb-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

% Paths
sacdir = fullfile(getenv('HUNGA'), 'sac');
undir = fullfile(sacdir, 'unmerged');
metadir = fullfile(sacdir, 'meta');

%% Merge (combine multiple *.sac to write *.merged.sac)
if isempty(ser)
    unsac = globglob(undir, '*sac');
    unser = unique(getmerser(unsac));

else
    unser = {ser};

end
for i = 1:length(unser)
    % Merge
    sac2mergesac_out = fullfile(metadir, sprintf('sac2mergedsac_%s.out', unser{i}));
    merge_cmd = sprintf('sac2mergedsac %s >! %s', unser{i}, sac2mergesac_out);
    fprintf('Running: `%s`\n', merge_cmd);
    [status, result] = system(merge_cmd);
    if status
        error('`%s` failed with error:\n%s', merge_cmd, result)

    end

    % Write gap file (from .txt to .mat)
    writegap(sac2mergesac_out);

end

%% Fill (interpolate zero-filled gaps from merge and write *merged.filled.sac)
if isempty(unser)
    sac = globglob(sacdir, '*merged.sac');

else
    sac = globglob(sacdir, sprintf('*.%s_*merged.sac', ser));

end
for i = 1:length(sac)
    fprintf('Runing `mergedsac2filledsac`: %s\n', strippath(sac{i}))
    mergedsac2filledsac(sac{i}, false);

end

warning('Now go delete/remake .evt files')
