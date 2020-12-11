function matchall(writecp)
% Matches all unmatched $MERMAID SAC files to the IRIS
% database using cpsac2evt.m and its defaults, assuming same system
% configuration as JDS.
%
% Input:
% writecp        true to write changepoint (.cp) files (def: false)
%
% A list of any files which are unsuccessfully matched using
% cpsac2evt.m are saved as 'matchall_fail.txt' $MERMAID/events (or
% empty if all successfully matched).
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 11-Dec-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default to not write cp files.
defval('writecp', false)

% Find only those SAC files which have not been preliminary matched.
allsac = fullsac;
rawevt = skipdotdir(dir(fullfile(getenv('MERMAID'), 'events', 'raw', 'evt')));
already_matched = strrep({rawevt.name}, '.raw.evt', '.sac'); % Not necessarily reviewed!
allsac_nopath = cellfun(@(xx) strippath(xx), allsac, 'UniformOutput', false);
[~, idx] = setdiff(allsac_nopath, already_matched);

% Loop over the unmatched SAC files.
fail = [];
new = 0;
s = allsac(idx);
fprintf('Searching for unmatched SAC files...\n')
for i = 1:length(s)
    [x, h] = readsac(s{i});

    % Get wavelet scale
    scale_idx = strfind(s{i}, 'WLT');
    if ~isempty(scale_idx)
        n = str2double(s{i}(scale_idx + 3));
        
    else
        % It's a raw signal, which is sampled at 6 scales
        n = 6

    end

    % Write raw event (.raw.evt) files).
    try
        cpsac2evt(s{i}, false, 'time', n);
        new = [new + 1];

    catch ME
        fail = [fail i];

    end
    close all

end

% Write changepoint (.cp) files.
if writecp && new > 0
    fprintf('Writing changepoint files...\n')
    writechangepointall;

end

% Make note of the SAC files that failed to be properly processed by cpsac2evt.m.
if ~isempty(fail)
    failsac = s(fail);
    failsac = cellfun(@(xx) strippath(xx), failsac, 'UniformOutput', ...
                      false);
    warning(['These SAC files were not matched:\n' ...
             repmat('%s\n', 1, length(failsac))], failsac{:})

else
    failsac = {};

end
fid = fopen(fullfile(getenv('MERMAID'), 'events', 'raw', 'matchall_fail.txt'), 'w');
fprintf(fid, '%s\n', failsac{:});
fclose(fid);

fprintf('\nAll done.\n')
