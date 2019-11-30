function [fetched, fetchedu, failed] = nearbysac2evtall(redo, starttime, endtime)
% [fetched, fetchedu, failed] = NEARBYSAC2EVTALL(redo, starttime, endtime))
%
% Fetches and writes .evt files for every event ID for all nearby
% stations using nearbysac2evt.m.
%
% Pulls event IDs from the last column of 'identified.txt', written
% with evt2txt.m, assuming JDS system defaults.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 26-Nov-2019, Version 2017b on GLNXA64

defval('redo', false)
defval('starttime', [])
defval('endtime', [])
defval('filename', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                            'identified', 'txt', 'identified.txt'))
defval('mer_evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('mer_sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('nearbydir', fullfile(getenv('MERMAID'), 'events', 'nearbystations'))
defval('model', 'ak135')
defval('ph', defphases)
defval('baseurl', 1);
[~, ~, ~, ~, ~, ~, ~, ~, ~, id] = readidentified(filename, starttime, endtime);

star_idx = cellstrfind(id, '*');
for i = 1:length(star_idx)
    id{star_idx(i)}(1) = [];

end
id = unique(id);

attempted = 0;
fetched = {};
fetchedu = {};
failed = {};
for i = 1:length(id)
    attempted = attempted + 1;
    try
        [nearby_EQ, nearby_EQu] = nearbysac2evt(id{i}, redo, mer_evtdir, mer_sacdir, nearbydir, model, ph, baseurl);
        if ~isempty(nearby_EQ)
            fetched = [fetched; id{i}];

        end
        if ~isempty(nearby_EQu)
            fetchedu = [fetchedu; id{i}];

        end
    catch
        failed = [failed; id{i}];

    end
end

fprintf('Total events:               %4i\n', length(id))
fprintf('Events attempted:           %4i\n', attempted)
fprintf('Events fetched:             %4i\n', length(fetched))
fprintf('Unmerged events fetched:    %4i\n', length(fetchedu))
fprintf('Events failed:              %4i\n', length(failed))
