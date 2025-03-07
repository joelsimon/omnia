function [corrected, correctedu, failed] = rmnearbyrespall(redo)
% [corrected, correctedu, failed] = RMNEARBYRESPALL(redo)
%
% Apply instrument-response correction ('none', 'vel', and 'acc') to
% all 'nearby' stations SAC files assuming JDS system defaults.
%
% Downloads most up-to-date SACPZ files before deconvolving.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu | joeldsimon@gmail.com
% Last modified: 30-May-2020, Version 9.3.0.713579 (R2017b) on GLNXA64

defval('redo', false)

% Fetch all event IDs in the nearby directory.
d = skipdotdir(dir(fullfile(getenv('MERMAID'), 'events', 'nearbystations', 'sac')));
id = {d.name}';

% Find unique event identifications (ignoring leading asterisks which
% signal possible multi-event traces).
star_idx = cellstrfind(id, '*');
for i = 1:length(star_idx)
    id{star_idx(i)}(1) = [];

end
id = unique(id);

% Ensure SAC pole-zero files are up to date by downloading the latest.
fetchnearbypz

otype = {'none', 'vel', 'acc'};
ostr = {'displacement', 'velocity', 'acceleration'};
for j = 1:length(otype)
    attempted.(otype{j}) = 0;
    corrected.(otype{j}) = {};
    correctedu.(otype{j}) = {};
    failed.(otype{j}) = {};
    for i = 1:length(id)
        attempted.(otype{j}) = attempted.(otype{j}) + 1;
        try
            [~, ~, new, newu] = rmnearbyresp(id{i}, redo, otype{j});
            if new
                corrected.(otype{j}) = [corrected.(otype{j}) ; id{i}];

            end
            if newu
                correctedu.(otype{j}) = [correctedu.(otype{j}) ; id{i}];

            end
        catch
            failed.(otype{j}) = [failed.(otype{j}); id{i}];

        end
    end

    fprintf('Total events:               %4i\n', length(id))
    fprintf('Events attempted:           %4i\n', attempted.(otype{j}))
    fprintf('Events corrected:           %4i\n', length(corrected.(otype{j})))
    fprintf('Unmeregd events corrected:  %4i\n', length(correctedu.(otype{j})))
    fprintf('Events failed:              %4i\n\n', length(failed.(otype{j})))

end
