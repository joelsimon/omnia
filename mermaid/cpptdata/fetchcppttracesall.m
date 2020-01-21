function fetchcppttracesall
%
% Script(ish) to generate requests for all CPPT data.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 21-Jan-2020, Version 2017b on GLNXA64

defval('starttime', [])
defval('endtime', datetime('31-Dec-2019 23:59:59.999', 'TimeZone', 'UTC'))
defval('filename', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                            'identified', 'txt', 'identified.txt'))
defval('txtfile', fullfile(getenv('MERMAID'), 'events', 'nearbystations', 'nearbystations.txt'))
defval('mer_evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('mer_sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('nearby_sacdir', fullfile(getenv('MERMAID'), 'events', 'nearbystations', 'sac'))
defval('nearbydir', fullfile(getenv('MERMAID'), 'events', 'nearbystations'))

[~, ~, ~, ~, ~, ~, ~, ~, ~, id] = readidentified(filename, starttime, endtime, 'evt');

% Find unique event identifications (ignoring leading asterisks which
% signal possible multi-event traces).
star_idx = cellstrfind(id, '*');
for i = 1:length(star_idx)
    id{star_idx(i)}(1) = [];

end
id = unique(id);

fetchcppttraces(id);
