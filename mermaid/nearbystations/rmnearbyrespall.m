function [corrected, correctedu, failed] = rmnearbyrespall(redo)
% [corrected, correctedu, failed] = RMNEARBYRESPALL(redo)
%
% Apply instrument-response correction to all 'nearby' stations SAC
% files assuming JDS system defaults.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 29-Nov-2019, Version 2017b on GLNXA64

defval('redo', false)
defval('filename', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                            'identified', 'txt', 'identified.txt'))

% Get MERMAID-identified event numbers.
[~, ~, ~, ~, ~, ~, ~, ~, ~, id] = readidentified(filename);

% Find unique event identifications (ignoring leading asterisks which
% signal possible multi-event traces).
star_idx = cellstrfind(id, '*');
for i = 1:length(star_idx)
    id{star_idx(i)}(1) = [];

end
id = unique(id);

attempted = 0;
corrected = {};
correctedu = {};
failed = {};
for i = 1:length(id)
   attempted = attempted + 1;
    try
        [~,~, new, newu] = rmnearbyresp(id{i}, redo);
        if new
            corrected = [corrected ; id{i}];

        end
        if newu
            correctedu = [correctedu ; id{i}];

        end
    catch
        failed = [failed; id{i}];

    end
end

fprintf('Total events:      %4i\n', length(id))
fprintf('Events attempted:  %4i\n', attempted)
fprintf('Events corrected:  %4i\n', length(corrected))
fprintf('Events failed:     %4i\n', length(failed))
