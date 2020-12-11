function loc = readloc(processed)
% loc = READLOC(processed)
%
% Read interpolated MERMAID locations at the time of recording SAC/miniSEED files from text file
% output by automaid v3.2.0+.
%
% NB, this function reads all data in as double; see readlocraw.m to read as native strings.
%
% Input:
% processed     Processed directory output by automaid
%                   (def: $MERMAID/processed)
% Output:
% loc           Interpolated GPS structure that parses loc.txt, organized by float name
%
% See also: readlocraw.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 23-Nov-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default path.
merpath = getenv('MERMAID');
defval('processed', fullfile(merpath, 'processed'))

% loc.txt format.
fmt = '%40s    %10.6f    %11.6f    %6f\n';

% Loop over every subdir in processed/ and read individual MERMAID's gps files.
d = skipdotdir(dir(processed));
for i = 1:length(d)
    if d(i).isdir
        % Read gps.txt file within individual float directory
        file = fullfile(d(i).folder, d(i).name, 'loc.txt');
        fid = fopen(file, 'r');
        C  = textscan(fid, fmt, 'HeaderLines', 3);
        fclose(fid);

        % Dynamically name gps.(field) for individual MERMAIDs
        mermaid = strrep(d(i).name(end-3:end), '-', '0');

        % Parse
        loc.(mermaid).sac = cellfun(@(xx) [xx '.sac'], C{1}, 'UniformOutput', false);
        loc.(mermaid).mseed = cellfun(@(xx) [xx '.mseed'], C{1}, 'UniformOutput', false);
        loc.(mermaid).stla = C{2};
        loc.(mermaid).stlo = C{3};
        loc.(mermaid).stdp = C{4};

    end
end
