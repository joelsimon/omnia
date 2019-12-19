function [corrected, correctedu, failed] = rmnearbyrespall(redo)
% [corrected, correctedu, failed] = RMNEARBYRESPALL(redo)
%
% Apply instrument-response correction ('none', 'vel', and 'acc') to
% all 'nearby' stations SAC files assuming JDS system defaults.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 18-Dec-2019, Version 2017b on GLNXA64

defval('redo', false)
defval('filename', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                            'identified', 'txt', 'identified.txt'))

% Get MERMAID-identified event numbers.
[~, ~, ~, ~, ~, ~, ~, ~, ~, id] = readidentified(filename);

% Find unique event identifications (ignoring leading asterisks which
% signal possible multi-event traces).
star_idx = cellstrfind(id, '*');
for i = 1:length(star_idx)
    id{star_idx(i)}(1) = [];

end
id = unique(id);

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

    fprintf('\nRemoving instrument response and writing %s SAC files...\n', ostr{j})
    fprintf('Total events:               %4i\n', length(id))
    fprintf('Events attempted:           %4i\n', attempted.(otype{j}))
    fprintf('Events corrected:           %4i\n', length(corrected.(otype{j})))
    fprintf('Unmeregd events corrected:  %4i\n', length(correctedu.(otype{j})))
    fprintf('Events failed:              %4i\n\n', length(failed.(otype{j})))

end
