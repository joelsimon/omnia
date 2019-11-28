function [nearbypz, pzfiles] = fetchnearbypz(txtfile, nearbydir)
% [nearbypz, pzfiles] = FETCHNEARBYPZ(txtfile, nearbydir)
%
% Write SAC pole-zero response files.
%
% FETCHNEARBYPZ requires the MERMAID python environment pymaid
% (python 2.7 with ObsPy).
%
% For 'classic' land seismometers the pole-zero files are directly queried from:
% http://service.iris.edu/irisws/sacpz/1/query?
%
% For Raspberry Shake stations the station.xml files are queried from:
% https://fdsnws.raspberryshakedata.com/fdsnws/station/1/query?
% and converted to pole-zero files using ObsPy.  This occurs in the
% shell script wgetrasppz, which FETCHNEARBYPZ calls.
%
% Input:
% txtfile      Text file of station names to parse, from http://ds.iris.edu/gmap
%                  (def: '$MERMAID/events/nearbystations/nearbystations.txt')
% nearbydir    Path to directory containing nearby stations
%                  'sac/' and 'evt/' subdirectories
%                  (def: $MERMAID/events/nearbystations/)
% Output:
% *N/A*        *Writes [net].[sta].pz files in [nearbydir]/pz/
%              *Writes concatenated nearbystations.pz in [nearbydir]/pz/
% nearbypz     Filename of concatenated responses
% pzfiles      Cell array of filenames of individual responses
%
% N.B.: the wget call in the shell script wgetrasppz is known to hang
% and/or incorrectly write .xml files, ergo, this function may require
% a rerun due to the unreliability of fdsnws.raspberryshakedata.com.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 26-Nov-2019, Version 2017b & Python 2.7.15 (pymaid env.) on GLNXA64

% Defaults.
defval('txtfile', fullfile(getenv('MERMAID'), 'events', 'nearbystations', 'nearbystations.txt'))
defval('nearbydir', fullfile(getenv('MERMAID'), 'events', 'nearbystations'))

% Make directory to store pole-zero files, if it does not already exist.
pzdir = fullfile(nearbydir, 'pz');
[~, ~] = mkdir(pzdir);

% Make note of current directory and move the pole-zero directory.
stardir = pwd;
cd(pzdir)

% Pull the relevant station names from the nearby stations textfile.
[net, sta] = parsenearbystations(txtfile);

% Defaults for 'classic' land stations.  The equivalent baseurl for
% Raspberry Shake is contained in the subroutine wgetrasppz.
baseurl = 'http://service.iris.edu/irisws/sacpz/1/query?';

% Activate MERMAID python environment 'pymaid' s.t. subroutine
% xml2pz.py (called in wgetrasppz) executes properly.
[~,~] = system('source activate pymaid');

% Loop over the stations and wget their pole-zero files.
pzfiles = {};
for i = 1:length(sta)
    % Pole-zero filename.
    pz = sprintf('%s.%s.Z.pz', net{i}, sta{i});

    if ~strcmp(net{i}, 'AM')
        % Make wget request.
        query = sprintf('net=%s%ssta=%s%sloc=*%scha=*Z%sstart=2018-06-01T01:01:01', net{i}, '&',  sta{i}, '&', '&', '&');
        system(sprintf('wget ''%s'' -O %s', [baseurl query], pz));

    else
        % Raspberry Shake gets special treatment because their response
        % metadata are returned as station.xml files, not SAC
        % pole-zero files.  The shell script wgetrasppz converts the
        % former to the latter.  The only required input is the
        % station name.  I construct the output .pz filename above
        % because I already know the naming convention of wgetrasppz.
        system(sprintf('$OMNIA/mermaid/nearbystations/wgetrasppz %s %s', sta{i}));

    end

    % Concatenate a list of .pz files fetched.
    pzfiles = [pzfiles pz];

end

% Concatenate the .pz files themselves so that a single pole-zero file
% can be read into SAC for all subsequent calls to 'transfer'.
nearbypz = fullfile(pzdir, 'nearbystations.pz');
system(sprintf('truncate -s 0 %s', nearbypz));  % Don't use touch -- does not empty existing file.
for i = 1:length(pzfiles)
    system(sprintf('cat %s >> %s', pzfiles{i}, nearbypz));

end

% Wrap up: deactivate python environment and return from whence you came.
system('source deactivate');
cd(stardir)
