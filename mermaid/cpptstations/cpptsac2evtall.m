function [fetched, failed] = cpptsac2evtall(redo)
% [fetched, failed] = CPPTSAC2EVTALL(redo)
%
% Fetches and writes .evt files for every event ID for all CPPT
% stations using cpptsac2evt.m.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 31-Jan-2020, Version 2017b on MACI64

% Defaults.
defval('redo', false)
defval('filename', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                            'identified', 'txt', 'identified.txt'))
defval('mer_evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('mer_sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('cpptdir', fullfile(getenv('MERMAID'), 'events', 'cpptstations'))
defval('model', 'ak135')
defval('ph', defphases)
defval('baseurl', 1);

% We do not necessarily have CPPT data for every event ID, as is the
% case for nearbystations data, so instead of reading the
% 'identified.txt' and parsing event IDs from there, look at the CPPT
% sac/ directory itself and loop over those IDs present.
cppt_sacdir = skipdotdir(dir(fullfile(cpptdir, 'sac')));
id = {cppt_sacdir.name};

attempted = 0;
fetched = {};
failed = {};
for i = 1:length(id)
    attempted = attempted + 1;
    try
        cppt_EQ = cpptsac2evt(id{i}, redo, mer_evtdir, mer_sacdir, ...
                              cpptdir, model, ph, baseurl);
        if ~isempty(cppt_EQ)
            fetched = [fetched; id{i}];

        end
    catch ME
        keyboard 
        failed = [failed; id{i}];

    end
end

fprintf('Total events:               %4i\n', length(id))
fprintf('Events attempted:           %4i\n', attempted)
fprintf('Events fetched:             %4i\n', length(fetched))
fprintf('Events failed:              %4i\n', length(failed))
