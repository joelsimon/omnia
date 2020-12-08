function gps = readgps(processed)
% gps = READGPS(processed)
%
% Read MERMAID GPS locations from csv file output by automaid v3.3.0+.
%
% NB, P023 was out of the water on for GPS dates:
% 2019-08-17T03:18:29Z
% 2019-08-17T03:22:02Z
% but those locations are NOT removed here. Be sure to remove them before
% processing, e.g., with driftstats.m
%
% Input:
% processed     Processed directory output by automaid
%                   (def: $MERMAID/processed)
% Output:
% gps           GPS structure that parses gps.csv, organized by float name
%
% See also: driftstats.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 08-Dec-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default path.
merpath = getenv('MERMAID');
defval('processed', fullfile(merpath, 'processed'))

% gps.csv format.
fmt = ['%s' ...
       '%f' ...
       '%f' ...
       '%f' ...
       '%f' ...
       '%f' ...
       '%s' ...
       '%s' ...
       '%s\n'];

% Loop over every subdir in processed/ and read individual MERMAID's gps files.
d = skipdotdir(dir(processed));
for i = 1:length(d)
    if d(i).isdir
        % Dynamically name gps.(field) for individual MERMAIDs
        mermaid = strrep(d(i).name(end-3:end), '-', '0');

        % Read gps.csv file within individual float directory
        file = fullfile(d(i).folder, d(i).name, 'gps.csv');
        fid = fopen(file, 'r');
        C = textscan(fid, fmt, 'HeaderLines', 3, 'Delimiter', ',');
        fclose(fid);

        % Parse.
        gps.(mermaid).time = C{1};
        gps.(mermaid).locdate = iso8601str2date(C{1});
        gps.(mermaid).lat = C{2};
        gps.(mermaid).lon = C{3};
        gps.(mermaid).hdop = C{4};
        gps.(mermaid).vdop = C{5};
        gps.(mermaid).clockdrift = C{6}; % GPS_time - MERMAID_time
        gps.(mermaid).source = C{7};
        gps.(mermaid).rawstr_lat = C{8}; % "[degrees]_[decimal minutes]"
        gps.(mermaid).rawstr_lon = C{9};  % "[degrees]_[decimal minutes]"

    end
end
