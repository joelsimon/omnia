function [mer_updated, nearby_updated, nearbyu_updated, failed] = updateidall(force)
% [mer_updated, nearby_updated, nearbyu_updated, failed] = UPDATEIDALL(force)
%
% Updates every MERMAID and 'nearby' .evt file associated with every
% identified event, using updateid.m
%
% Pulls event IDs from the last column of 'identified.txt', written
% with evt2txt.m, assuming JDS system defaults.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 29-Nov-2019, Version 2017b on GLNXA64

defval('force', false)
defval('filename', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                            'identified', 'txt', 'identified.txt'))
defval('mer_evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('mer_sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('nearbydir', fullfile(getenv('MERMAID'), 'events', 'nearbystations'))
defval('model', 'ak135')
defval('ph', defphases)
defval('baseurl', 1);

[~, ~, ~, ~, ~, ~, ~, ~, ~, id] = readidentified(filename);

% Find unique event identifications (ignoring leading asterisks which
% signal possible multi-event traces).
star_idx = cellstrfind(id, '*');
for i = 1:length(star_idx)
    id{star_idx(i)}(1) = [];

end
id = unique(id);

attempted = 0;
mer_updated = {};
nearby_updated = {};
nearbyu_updated = {};
failed = {};
for i = 1:length(id)
    attempted = attempted + 1;
    try
        [me, ~, ne, ~, neu] = updateid(id{i}, force,  mer_evtdir, mer_sacdir, nearbydir, model, ph, baseurl);
        if ~isempty(me)
            mer_updated = [mer_updated ; id{i}];

        end
        if ~isempty(ne)
            nearby_updated = [nearby_updated ; id{i}];

        end
        if ~isempty(neu)
            nearbyu_updated = [nearbyu_updated ; id{i}];

        end
    catch ME
        keyboard
        failed = [failed ; id{i}];

    end
end

fprintf('Total events:                   %4i\n', length(id))
fprintf('Events attempted:               %4i\n', attempted)
fprintf('MERMAID events updated:         %4i\n', length(mer_updated))
fprintf('Nearby events updated:          %4i\n', length(nearby_updated))
fprintf('Unmerged nearby events updated: %4i\n', length(nearbyu_updated))
fprintf('Events failed:                  %4i\n', length(failed))
