function sacworkflow(ser)
% SACWORKFLOW(ser)
%
% SAC prepocessing workflow: copy, merge, fill.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 01-Feb-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

error(sprintf(['This is a one-time use function...you''re going to recopy things you don''t want\n'...
               'Use sacworkflow2 to remerge/refill']))

clc
close all
defval('ser', [])

% Paths
sacdir = fullfile(getenv('HUNGA'), 'sac');
undir = fullfile(sacdir, 'unmerged');
metadir = fullfile(sacdir, 'meta');

if exist(sacdir, 'dir') ~= 7
    mkdir(sacdir)

end
if exist(undir, 'dir') ~= 7
    mkdir(undir)

end
if exist(metadir, 'dir') ~= 7
    mkdir(metadir)

end

%% Copy from *processed/
if isempty(ser)
    rsync_cmd = 'rsync_sac';
    fprintf('Running %s\n', rsync_cmd);
    [status, result] = system(rsync_cmd);
    if ~status
        fprintf('Sucess:\n%s', result)

    else
        error('Failed with error:\n%s', result)

    end
end

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
