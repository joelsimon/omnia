function [fetched, failed] = fetchnearbytracesall
% failed = FETCHNEARBYTRACESALL
%
% Run fetchnearbytraces.m for all event IDs
% (last column of 'identified.txt')
% assuming JDS system defaults.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 03-Sep-2019, Version 2017b

defval('filename', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                            'identified', 'txt', 'identified.txt'))
defval('txtfile', fullfile(getenv('MERMAID'), 'events', 'nearbystations', 'nearbystations.txt'))
defval('mer_evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('mer_sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('nearby_sacdir', fullfile(getenv('MERMAID'), 'events', 'nearbystations', 'sac'))
defval('nearbydir', fullfile(getenv('MERMAID'), 'events', 'nearbystations'))

[~, ~, ~, ~, ~, ~, ~, ~, ~, id] = readidentified(filename);

% Find unique event identifications (ignoring leading asterisks which
% signal possible multi-event traces).
star_idx = cellstrfind(id, '*');
for i = 1:length(star_idx)
    id{star_idx(i)}(1) = [];

end
id = unique(id);

fetched = {};
failed = {};
for i = 1:length(id)
    try
        tr = fetchnearbytraces(id{i}, false, txtfile, mer_evtdir, nearby_sacdir);
        if ~isempty(tr)
            nearbysac2evt(id{i}, false, mer_evtdir, mer_sacdir, nearbydir);
            fetched = [fetched ; id{i}];

        end
    catch
        failed = [failed ; id{i}];

    end
end
