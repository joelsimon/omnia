function ID = remergenearbytraces
% ID = REMERGENEARBYTRACES
%
% One-time function to fix issue discovered in $OMNIA commit:
%
% 222c5bd0d5a00d524686aedb12411f227548b260
%
% Runs:
%
% fetchnearbytraces(id)
% rmnearbyresp(id) [for otype 'none', 'vel', and 'acc']
% nearbysac2evt(id)
%
% for all event IDs that were improperly merged (assuming JDS system
% defaults), and returns those event IDs.
%
% Script-ish to rerun mergesac on 'nearby' stations' ID directories,
% which have failed since at least
%
% commit 6444374dd6fe901a6e846f7b66df3f7f3e494dcd
%
% in which I put a '#' in the SAC command 'merge', causing it to fail,
% and thus resulting in no *.merged.SAC files, but the appropriate file
% list which should have been merged was indeed sent to the /unmerged/.
%
% To fix, I will locate all directories which have /unmerged/
% subdirectories but which do not have the corresponding *.merged.SAC
% files and refetch with fetchnearbytraces.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 05-Feb-2020, Version 2017b on GLNXA64

% Inspect every event ID subdirectory.
spath =  fullfile(getenv('MERMAID'), 'events', 'nearbystations', 'sac');
sdir = skipdotdir(dir(spath));

ID = [];
for i = 1:length(sdir)

    % Ultimately this is what will be compared for every ID directory: the
    % list of unmerged and merged SAC files must be equal.
    unmerged_glob = {};
    merged_glob = {};

    id = sdir(i).name;
    unmerged_dir = dir(fullfile(sdir(i).folder, sdir(i).name, 'unmerged', '*.SAC'));
    if isempty(unmerged_dir)
        continue

    end

    % There exist files in the unmerged subdir. Check if they have
    % corresponding merged files in the main ID directory.
    for j = 1:length(unmerged_dir)
        delims = strfind(unmerged_dir(j).name, '.');
        unmerged_glob{j} = unmerged_dir(j).name(1:delims(4));

    end
    unmerged_glob = unique(unmerged_glob);
    sort(unmerged_glob);

    merged_dir = dir(fullfile(sdir(i).folder, sdir(i).name, '*.merged.SAC'));
    if ~isempty(merged_dir)
        for j = 1:length(merged_dir)
            delims = strfind(merged_dir(j).name, '.');
            merged_glob{j} = merged_dir(j).name(1:delims(4)); % already unique

        end
        sort(merged_glob);

        % This list should already be unique, as that is handled by
        % mergenearbytraces.m, but we might as well verify.
        if ~isequal(unique(merged_glob), merged_glob)
            error('the globs for the merged SAC files are nonunique for ID: %s', id)

        end

        % Finally, compare the two lists.
        if isequal(merged_glob, unmerged_glob)
            continue

        end
    end

    % If we are here, unmerged SAC files exist but their corresponding
    % merged SAC files do not, or those two lists differ.
    fetchnearbytraces(id, true);
    rmnearbyresp(id, true, 'none');
    rmnearbyresp(id, true, 'vel');
    rmnearbyresp(id, true, 'acc');
    nearbysac2evt(id, true);

    ID = [ID ; id];

end
