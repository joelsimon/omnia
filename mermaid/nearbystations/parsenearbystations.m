function [network, station, datacenter, url, latitude, longitude, elevation, sitename, starttime, endtime] = parsenearbystations(txtfile, uniq)
% [network, station, datacenter, url, latitude, longitude, elevation, sitename, starttime, endtime] = PARSENEARBYSTATIONS(txtfile, uniq)
%
% Parses the textfile 'nearbystations.txt' generated at
% http://ds.iris.edu/gmap/.
%
% N.B.: stations can and do change location, sensor type, active status
% etc. while maintaining the same station name.  The input txtfile includes this
% information to some extent, it is not returned by PARSENEARBYSTATIONS by
% default because the most up-to-date info should be retrieved with
% irisFetch.Stations.
%
% Input:
% txtfile      Text file of station names to parse, from http://ds.iris.edu/gmap
%                  (def: '$MERMAID/events/nearbystations/nearbystations.txt')
% uniq         true to only return birth-location info for each stations (def: true)
%                  e.g., if Raspberry station moved, only return initial lat/lon
%
% Output:
% network      Network code
% station      Station code
% datacenter   Name of relevant data center
% url          Suggested* url of relevant data center
% latitude     Latitude [decimal degrees]
% longitude    Longitude [decimal degrees]
% elevation    Elevation [m]
% sitename     Site name, if given
% starttime    Station birthdate, as datetime
% endtime      Station death, as datetime
%
% *Invalid for http://raspberryshake.net: should be https ('s')
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 09-May-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default.
defval('txtfile', fullfile(getenv('MERMAID'), 'events', 'nearbystations', 'nearbystations.txt'))
defval('uniq', true)

% Read the entire file into memory.
tx = readtext(txtfile);

% Find the lines that start with #DATACENTER (they separate blocks).
dcline = cellstrfind(tx, 'DATACENTER');

% Remove the header, the only other place where the '|' column separator exists.
tx(1:dcline(1)-1) = [];

% Adjust the dcline accordingly.
dcline = dcline - (dcline(1)-1);

% Specify datetime format.
date_fmt = 'uuuu-MM-dd''T''HH:mm:ss';

% Loop through every line and keep the network and station names.
tx_idx = 0;
for i = 1:length(tx)
    % Determine this block's datacenter.
    if ~isempty(dcline) && i == dcline(1)
        % This index in the textfile is a line describing the datacenter.
        % Parse it and remove that index from dcline.  This block's
        % datacenter then remains a pseudo-constant for this loop
        % until the next dcline index, or the dcline vector is empty
        dataline = tx{dcline(1)};
        dataline = fx(strsplit(dataline, '='), 2);
        dataparts = strsplit(dataline, ',');
        block_datacenter = dataparts(1);
        block_url = dataparts(2);
        dcline(1) = [];  % After last datacenter dcline is empty.

    end

    % Determine if this line describes a station or is an empty
    % line separating blocks.
    if isempty(strfind(tx{i}, '|'))
       continue

    else
        % Parse the station info.
        tx_idx = tx_idx + 1;
        this_line = strsplit(tx{i}, '|', 'CollapseDelimiters', false);
        network{tx_idx} = this_line{1};
        station{tx_idx} = this_line{2};
        latitude(tx_idx) = str2double(this_line{3});
        longitude(tx_idx) = str2double(this_line{4});
        elevation(tx_idx) = str2double(this_line{5});
        sitename{tx_idx} = str2double(this_line{6});
        starttime(tx_idx) = datetime(this_line{7}, 'Format', date_fmt, 'TimeZone', 'UTC');
        endtime(tx_idx) = datetime(this_line{8}, 'Format', date_fmt, 'TimeZone', 'UTC');
        datacenter{tx_idx} = block_datacenter;
        url{tx_idx} = block_url;

    end
end

% Remove duplicate stations and reorder outputs accordingly.
if uniq
    [~, idx] = unique(station);
    network = network(idx);
    station = station(idx);
    latitude = latitude(idx);
    longitude = longitude(idx);
    elevation = elevation(idx);
    sitename = sitename(idx);
    starttime = starttime(idx);
    endtime = endtime(idx);
    datacenter = datacenter(idx);
    url = url(idx);

end