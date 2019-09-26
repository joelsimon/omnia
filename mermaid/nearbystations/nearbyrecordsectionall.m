function failed = nearbyrecordsectionall
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

count = 0;
failed = {};
for i = 1:length(id)
    i
    try
        F = nearbyrecordsection(id{i}, [], [], [], [], [], [], [], 'DET')
        if ~isempty(F)
            count = count + 1;
            savepdf(['nearbyrecordsection_' id{i}])

        end        
    catch ME
       failed = [failed ; id{i}];

    end
    close all

end

compilepdf('nearbyrecordsection_*.pdf', 'nbrs.pdf')