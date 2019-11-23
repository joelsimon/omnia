defval('filename', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                            'identified', 'txt', 'identified.txt'))

[~, ~, ~, ~, ~, ~, ~, ~, ~, id] = readidentified(filename);



% Find unique event identifications (ignoring leading asterisks which
% signal possible multi-event traces).
star_idx = cellstrfind(id, '*');
for i = 1:length(star_idx)
    id{star_idx(i)}(1) = [];

end
id = unique(id);

ids = [];
for i = 1:length(id)
    try
        rmnearbyresp(id{i}, false);

    catch
        keyboard
        ids = [ids; id{i}];

    end
end
ids