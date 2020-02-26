function [corrected, failed] = rmcpptrespall(redo)
% [corrected, failed] = RMCPPTRESPALL(redo)
%
% Apply instrument-response correction ('none', 'vel', and 'acc') to
% all CPPT stations SAC files assuming JDS system defaults.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 26-Feb-2020, Version 2017b on GLNXA64

defval('redo', false)

% Fetch all event IDs in the cppt directory.
d = skipdotdir(dir(fullfile(getenv('MERMAID'), 'events', 'cpptstations', 'sac')));
id = {d.name}';

% Find unique event identifications (ignoring leading asterisks which
% signal possible multi-event traces).
star_idx = cellstrfind(id, '*');
for i = 1:length(star_idx)
    id{star_idx(i)}(1) = [];

end
id = unique(id);

otype = {'none', 'vel', 'acc'};
for j = 1:length(otype)
    attempted.(otype{j}) = 0;
    corrected.(otype{j}) = {};
    failed.(otype{j}) = {};
    for i = 1:length(id)
        attempted.(otype{j}) = attempted.(otype{j}) + 1;
        try
            [~, new] = rmcpptresp(id{i}, redo, otype{j});
            if new
                corrected.(otype{j}) = [corrected.(otype{j}) ; id{i}];

            end
        catch
            failed.(otype{j}) = [failed.(otype{j}); id{i}];

        end
    end

    fprintf('Total events:               %4i\n', length(id))
    fprintf('Events attempted:           %4i\n', attempted.(otype{j}))
    fprintf('Events corrected:           %4i\n', length(corrected.(otype{j})))
    fprintf('Events failed:              %4i\n\n', length(failed.(otype{j})))

end
