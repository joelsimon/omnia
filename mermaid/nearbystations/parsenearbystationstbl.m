function [net, sta, lat, lon] = parsenearbystationstbl(filename)
% [net, sta, lat, lon] = PARSENEARBYSTATIONSTBL(filename)
%
% Reads hand-edited, LaTeX formatted, nearby stations table.
%
% Input:
% filename    Fullpath filename
%                (def: $MERMAID/events/nearbystations/nearbystatons.tbl)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 17-Nov-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default
defval('filename', fullfile(getenv('MERMAID'), 'events', 'nearbystations', 'nearbystations.tbl'));

% Read the file.
s = readtext(filename);

% Remove empty \newline.
s(end) = [];

% Parse the relevant info.
for i = 1:length(s)
    sp = strtrim(strsplit(strrep(s{i}, '\\', '') , '&'));

    net{i} = sp{1};
    sta{i} = sp{2};
    lat(i) = str2double(sp{3});
    lon(i) = str2double(sp{4});

end
