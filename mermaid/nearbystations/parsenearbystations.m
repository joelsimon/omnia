function [network, station, latitude, longitude, datacenter, url] = parsenearbystations(txtfile)
% [network, station, latitude, longitude, datacenter, url] = PARSENEARBYSTATIONS(txtfile)
%
% Parses the textfile 'nearbystations.txt' generated at
% http://ds.iris.edu/gmap/.
%
% Input:
% txtfile      Text file of station names to parse, from http://ds.iris.edu/gmap
%                  (def: '$MERMAID/events/nearbystations/nearbystations.txt')
%
% Output:
% network      Network code
% station      Station code
% datacenter   Name of relevant data center
% url          Suggested* url of relevant data center
%
% *Invalid for http://raspberryshake.net: should be https ('s')
% 
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 05-Sep-2019, Version 2017b

% Default.
defval('txtfile', fullfile(getenv('MERMAID'), 'events', 'nearbystations', 'nearbystations.txt'))

% Read the entire file into memory.
tx = readtext(txtfile);

% Find the lines that start with #DATACENTER (they separate blocks). 
dcline = cellstrfind(tx, 'DATACENTER');

% Remove the header, the only other place where the '|' column separator exists.
tx(1:dcline(1)-1) = [];

% Adjust the dcline accordingly.
dcline = dcline - (dcline(1)-1);

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
        this_line = strsplit(tx{i}, '|');
        network{tx_idx} = this_line{1};
        station{tx_idx} = this_line{2};
        latitude{tx_idx} = str2double(this_line{3});
        longitude{tx_idx} = str2double(this_line{4});
        datacenter{tx_idx} = block_datacenter;
        url{tx_idx} = block_url;

    end
end

% Remove duplicate stations and reorder outputs accordingly.
[station, uniq_idx] = unique(station);
network = network(uniq_idx);
latitude = latitude(uniq_idx);
longitude = longitude(uniq_idx);
datacenter = datacenter(uniq_idx);
url = url(uniq_idx);
