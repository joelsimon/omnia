function gps = readgps(processed)
% gps = READGPS(processed)
%
% Input:
% processed     Processed directory output by automaid
%                   (def: $MERMAID/processed)
% Output:
% gps           GPS structure that parses gps.txt, organized by float name
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 13-Nov-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default path.
merpath = getenv('MERMAID');
defval('processed', fullfile(merpath, 'processed'))

% gps.txt format.
fmt = '%20s    %10.6f    %11.6f    %6.3f    %6.3f    %17.6f  %s  %15s    %3s %7s    %4s %7s\n';

% Loop over every subdir in processed/ and read individual MERMAID's gps files.
d = skipdotdir(dir(processed));
for i = 1:length(d)
    if d(i).isdir
        % Dynamically name gps.(field) for individual MERMAIDs
        mermaid = strrep(d(i).name(end-3:end), '-', '0');

        % Read gps.txt file within individual float directory
        file = fullfile(d(i).folder, d(i).name, 'gps.txt');
        fid = fopen(file, 'r');
        C  = textscan(fid, fmt, 'HeaderLines', 3);
        fclose(fid);

        % Parse (skip "|" partition of C{7})
        gps.(mermaid).time = C{1};
        gps.(mermaid).date = iso8601str2date(C{1});
        gps.(mermaid).lat = C{2};
        gps.(mermaid).lon = C{3};
        gps.(mermaid).hdop = C{4};
        gps.(mermaid).vdop = C{5};
        gps.(mermaid).clockdrift = C{6};  % GPS_time - MERMAID_time
        gps.(mermaid).source = C{8};
        gps.(mermaid).rawstr_lat = cellfun(@(xx,yy) [xx ' ' yy], C{9}, C{10}, 'UniformOutput', false);
        gps.(mermaid).rawstr_lon = cellfun(@(xx,yy) [xx ' ' yy], C{11}, C{12}, 'UniformOutput', false);

    end
end
