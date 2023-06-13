function gps = readgps(processed, rm23)
% gps = READGPS(processed, rm23)
%
% Read MERMAID GPS locations from 'gps.csv' file output by automaid v3.4.0-K+
% (when "clockfreq" column was added). Note that gps.(mermaid).date may
% include redundant datetimes.
%
% NB, P0023 was out of the water around the GPS dates of --
% 2019-08-17T03:18:29Z
% 2019-08-17T03:22:02Z
% but unless `rm23` is true those locations are NOT removed here.
% Be sure to remove them before processing, e.g., with driftstats.m
%
% Input:
% processed     Processed directory output by automaid
%                   (def: $MERMAID/processed)
% rm23          Replace GPS data associated with dates:
%                   '2019-08-17T03:18:29Z' and '2019-08-17T03:22:02Z'
%                   (when P0023 was out of the water) with '', NaN, NaT
%                   (def: true)
%
% Output:
% gps           GPS structure that parses gps.csv, organized by float name
%
% See also: driftstats.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 17-Sep-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default path.
merpath = getenv('MERMAID');
defval('processed', fullfile(merpath, 'processed'))
defval('rm23', true)

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
d = skipdotdir(dir(processed));
for i = 1:length(d)
    if d(i).isdir
        % Dynamically name gps.(field) for individual MERMAIDs
        mermaid = osean2fdsn(d(i).name);

        % Read gps.csv file within individual float directory
        file = fullfile(d(i).folder, d(i).name, 'gps.csv');
        fid = fopen(file, 'r');
        C = textscan(fid, fmt, 'HeaderLines', 3, 'Delimiter', ',');
        fclose(fid);

        % Parse.
        gps.(mermaid).time = C{1};
        gps.(mermaid).date = iso8601str2date(C{1});
        gps.(mermaid).lat = C{2};
        gps.(mermaid).lon = C{3};
        gps.(mermaid).hdop = C{4};
        gps.(mermaid).vdop = C{5};
        gps.(mermaid).clockdrift = C{6}; % GPS_time - MERMAID_time
        gps.(mermaid).clockfreq = C{7};
        gps.(mermaid).source = C{8};
        gps.(mermaid).rawstr_lat = C{9}; % "[degrees]_[decimal minutes]"
        gps.(mermaid).rawstr_lon = C{10};  % "[degrees]_[decimal minutes]"

        % Verify sorting.
        if ~isequal(gps.(mermaid).date, sort(gps.(mermaid).date))
            error('GPS unsorted')

        end
    end
end

if rm23
    % Replace bad data values with empty strings, NaNs, or NaTs, as opposed to
    % removing the indices entirely, so as to maintain the same indexing (e.g.,
    % for driftstats.m), and so `diff`s  may be taken.  If we just removed
    % those indices entirely a diff would span from the last legit GPS
    % immediately before being recovered to the first legit GPS immediately
    % after being redeployed, which would incorrectly compute the velocity of
    % the boat.
    %
    % >> gps.P0023.lat(386:395)  % Indices may change with rewrite of 'gps.csv'
    %  -23.8419
    %  -23.8425
    %  -23.8436
    %  -23.8438
    %       NaN
    %       NaN
    %  -30.0526
    %  -30.0524
    %  -30.2723
    %  -30.2720
    %
    % >> gps.P0023.lon(386:395)
    % ans =
    %  -143.5497
    %  -143.5499
    %  -143.5501
    %  -143.5503
    %        NaN
    %        NaN
    %  -157.3934
    %  -157.3926
    %  -157.9978
    %  -157.9971

    bad_dates = iso8601str2date({'2019-08-17T03:18:29Z' '2019-08-17T03:22:02Z'});
    [~, bad_idx] = intersect(gps.P0023.date, bad_dates);

    gps.P0023.time(bad_idx) = {''};
    gps.P0023.date(bad_idx) = NaT;
    gps.P0023.lat(bad_idx) = NaN;
    gps.P0023.lon(bad_idx) = NaN;
    gps.P0023.hdop(bad_idx) = NaN;
    gps.P0023.vdop(bad_idx) = NaN;
    gps.P0023.clockdrift(bad_idx) = NaN;
    gps.P0023.source(bad_idx) = {''};
    gps.P0023.rawstr_lat(bad_idx) = {''};
    gps.P0023.rawstr_lon(bad_idx) = {''};

end
