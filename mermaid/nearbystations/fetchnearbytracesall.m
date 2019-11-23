function [fetched, failed] = fetchnearbytracesall(redo)
% [fetched, failed] = FETCHNEARBYTRACESALL(redo)
%
% Fetches and writes SAC files for every event ID for all nearby
% stations using fetchnearbytraces.m.
%
% Pulls event IDs from the last column of 'identified.txt', written
% with evt2txt.m, assuming JDS system defaults.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 26-Sep-2019, Version 2017b on GLNXA64

defval('redo', false)
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

attempted = 0;
fetched = {};
failed = {};

attempted2 = 0;
fetched2 = {};
failed2 = {};
for i = 1:length(id)
    attempted = attempted + 1;
    try
        tr = fetchnearbytraces(id{i}, redo, txtfile, mer_evtdir, nearby_sacdir);
        if ~isempty(tr)
            fetched = [fetched ; id{i}];
                    
        %     nearbysac2evt(id{i}, redo, mer_evtdir, mer_sacdir, nearbydir);
        %     nearbysac2evt2(id{i}, redo, mer_evtdir, mer_sacdir, nearbydir);

        end
    catch
        failed = [failed ; id{i}];

    end
end

fprintf('Total events:      %4i\n', length(id))
fprintf('Events attempted:  %4i\n', attempted)
fprintf('Events fetched:    %4i\n', length(fetched))
fprintf('Events failed:     %4i\n', length(failed))
