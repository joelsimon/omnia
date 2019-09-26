function [fetched, failed] = nearbysac2evtall
% [fetched, failed] = NEARBYSAC2EVTALL
%
% Fetches and writes .evt files for every event ID for all nearby
% stations using nearbysac2evt.m.
%
% Pulls event IDs from the last column of 'identified.txt', written
% with evt2txt.m, assuming JDS system defaults.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 26-Sep-2019, Version 2017b on GLNXA64

defval('filename', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                            'identified', 'txt', 'identified.txt'))
defval('mer_evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('mer_sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('nearbydir', fullfile(getenv('MERMAID'), 'events', 'nearbystations'))

[~, ~, ~, ~, ~, ~, ~, ~, ~, id] = readidentified(filename);

star_idx = cellstrfind(id, '*');
for i = 1:length(star_idx)
    id{star_idx(i)}(1) = [];

end
id = unique(id);

attempted = 0;
fetched = {};
failed = {};
for i = 1:length(id)
    attempted = attempted + 1;
    try
        EQ = nearbysac2evt(id{i}, false, mer_evtdir, mer_sacdir, nearbydir);
        if ~isempty(EQ)
            fetched = fetch + 1;

        end

    catch 
        failed = [failed; id{i}];

    end
end

fprintf('Total events:      %4i\n', length(id))
fprintf('Events attempted:  %4i\n', attempted)
fprintf('Events fetched:    %4i\n', length(fetched))
fprintf('Events failed:     %4i\n', length(failed))
