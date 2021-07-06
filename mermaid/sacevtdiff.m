function [raw_del, rev_del] = sacevtdiff(procdir, evtdir)
% [raw_del, rev_del] = SACEVTDIFF(procdir, evtdir)
%
% Delete .evt files with no (longer any) associated SAC file.
%
% Useful for, e.g., cleanup of stale 'prelim.evt' files.
%
% Input:
% procdir       Path to directory to be (recursively) searched for
%                  SAC files (def: $MERMAID/processed/)
% evtdir        Path to directory containing 'raw/' and 'reviewed'
%                   subdirectories (def: $MERMAID/events/)
%
% Output:
% raw(rev)_del  Lists of deleted raw and reviewed .evt files
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 06-Jul-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64


% Defaults.
defval('procdir', fullfile(getenv('MERMAID'), 'processed'))
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))
raw_del = {};
rev_del = {};

% Collect list of SAC files in the processed directory.
proc_sac = strippath(fullsac([], procdir));
proc_sac = cellfun(@(xx) strrep(xx, '.sac', ''), proc_sac, 'UniformOutput', false);

% Collect lists of raw and reviewed .evt files in the events directory.
raw_evtdir = skipdotdir(dir(fullfile(evtdir, 'raw', 'evt', '*.evt')));
rev_evtdir = skipdotdir(dir(fullfile(evtdir, 'reviewed', '**/*.evt')));

raw_sac = {raw_evtdir.name}';
raw_sac = cellfun(@(xx) strrep(strrep(xx, '.raw', ''), '.evt', ''), raw_sac, 'UniformOutput', false);

rev_sac = {rev_evtdir.name}';
rev_sac = cellfun(@(xx) strrep(strrep(xx, '.rev', ''), '.evt', ''), rev_sac, 'UniformOutput', false);

% Setdiff the SAC file list with the .evt file lists.
[~, raw_idx] = setdiff(raw_sac, proc_sac);
[~, rev_idx] = setdiff(rev_sac, proc_sac);

% Delete the raw .evt files with no (longer any) associated SAC file.
for i = 1:length(raw_idx)
    raw_del{i} = fullfile(raw_evtdir(raw_idx(i)).folder, raw_evtdir(raw_idx(i)).name);

    if isgitfile(raw_del{i})
        % If using an older version of git you much actually cd to directory;
        % `git -C` is a newer feature.
        [status, foo] = system(sprintf('git -C %s rm %s', raw_evtdir(raw_idx(i)).folder, raw_del{i}));
        if status == 0
            fprintf('Deleted: %s\n', strippath(raw_del{i}));

        end
    else
        delete(raw_del{i})
        fprintf('Deleted: %s\n', strippath(raw_del{i}));

    end
end
raw_del = raw_del';

% Delete the reviewed .evt files with no (longer any) associated SAC file.
for i = 1:length(rev_idx)
    rev_del{i} = fullfile(rev_evtdir(rev_idx(i)).folder, rev_evtdir(rev_idx(i)).name);

    if isgitfile(rev_del{i})
        % If using an older version of git you much actually cd to directory;
        % `git -C` is a newer feature.
        [status, foo] = system(sprintf('git -C %s rm %s', rev_evtdir(rev_idx(i)).folder, rev_del{i}));
        if status == 0
            fprintf('Deleted: %s\n', strippath(rev_del{i}));

        end
    else
        delete(rev_del{i})
        fprintf('Deleted: %s\n', strippath(rev_del{i}));

    end
end
rev_del = rev_del';
