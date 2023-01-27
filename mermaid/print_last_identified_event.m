function print_last_identified_event(filename)
% PRINT_LAST_IDENTIFIED_EVENT(filename)
%
% Print date of last identified .DET for each MERMAID.
%
% Must run firstarrival.m
%
% Input:
% filename    Fullpath filename to firstarrival.txt
%                 (def: $MERMAID/events/reviewed/identified/txt/firstarrival.txt)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 27-Jan-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default
defval('filename', fullfile(getenv('MERMAID'), 'events', 'reviewed', 'identified', ...
                            'txt', 'firstarrival.txt'))

% Read firstarrivals.txt as a structure.
FA = readfirstarrivalstruct(filename);

% Extract list of serial numbers from filenames.
sac = FA.s;
ser = getmerser(sac);
uniq_ser = unique(ser);
ser_list = uniq_ser;

% Loop backwards over all filenames and note first
% occurrence of each serial number.
last_idx = [];
for i = length(sac):-1:1
    % Consider only .DET files; I'm interested in if
    % MERMAID is sending good data on its own accord.
    if contains(sac{i}, 'REQ')
        continue

    end

    % Remove serial number from "yet-to-be-found" list
    % after first occurrence.
    str_idx = find(strcmp(ser{i}, ser_list));
    if ~isempty(str_idx);
        last_idx = [last_idx i];
        ser_list(str_idx) = [];

    end

    % Break loop when all serial numbers found.
    if isempty(ser_list)
        break

    end
end
last_sac = sac(last_idx);
last_ser = ser(last_idx);

% Extract date of last identified .sac from filename.
[~, sort_idx] = sort(last_ser);
last_ser = last_ser(sort_idx);
last_sac = last_sac(sort_idx);
last_date = mersac2date(last_sac);

% Print ouput to command window.
for i = 1:length(last_date)
    fprintf('Float %s: %s\n', last_ser{i}, datestr(last_date(i), 1))

end
