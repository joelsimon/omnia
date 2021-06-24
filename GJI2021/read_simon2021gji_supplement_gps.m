 function gps = read_simon2021gji_supplement_gps(supplement_directory)
% gps = READ_SIMON2021GJI_SUPPLEMENT_GPS(supplement_directory)
%
% Read MERMAID GPS locations from Joel D. Simon's 2021 GJI paper???
%
% Those GPS files were output by automaid v3.4.0-7. They are not trimmed
% "http://geoweb.princeton.edu/people/simons/SOM/P00??_all.txt" files (written
% by FJS' vit2tbl.m), as was done with first original submission to GJI.
%
% NB, P023 was out of the water during GPS dates:
% 2019-08-17T03:18:29Z
% 2019-08-17T03:22:02Z
% but those locations are NOT removed here. Be sure to remove them before
% processing, e.g., with driftstats.m
%
% Relies on subfunctions retrievable at: https://github.com/joelsimon/omnia
%
% Input:
% supplement_directory  Directory where simon2021gji_supplement_????_gps.txt reside
%
% Output:
% gps                   GPS structure that parses *gps*.txt, organized by float name
%
% See also: driftstats.m, readgps.m (on which this specific case is based)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 23-Jun-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default path.
defval('supplement_directory', ...
       fullfile(getenv('GJI21'), 'supplement', 'data', 'textfiles'))

% gps.csv format.
fmt = ['%s' ...
       '%f' ...
       '%f' ...
       '%f' ...
       '%f' ...
       '%f' ...
       '%f' ...
       '%s' ...
       '%s' ...
       '%s\n'];

% Loop over every subdir in processed/ and read individual MERMAID's gps files.
d = dir(fullfile(supplement_directory, '*gps.txt'));

for i = 1:length(d)
        % Dynamically name gps.(field) for individual MERMAIDs.
        mermaid = d(i).name(25:29);

        % Read text file.
        fid = fopen(fullfile(d(i).folder, d(i).name), 'r');
        C = textscan(fid, fmt, 'HeaderLines', 3, 'Delimiter', ' ', 'MultipleDelimsAsOne', true);
        fclose(fid);

        % Parse.
        gps.(mermaid).time = C{1};
        gps.(mermaid).locdate = iso8601str2date(C{1});
        gps.(mermaid).lat = C{2};
        gps.(mermaid).lon = C{3};
        gps.(mermaid).hdop = C{4};
        gps.(mermaid).vdop = C{5};
        gps.(mermaid).clockdrift = C{6};
        gps.(mermaid).clockfreq = C{7};
        gps.(mermaid).source = C{8};
        gps.(mermaid).rawstr_lat = C{9};
        gps.(mermaid).rawstr_lon = C{10};

end
