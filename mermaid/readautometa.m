function [D, S] = readautometa(processed)
% [D, S] = READAUTOMETA(processed)
%
% Read and parse automaid_metadata.csv for all MERMAID floats.
%
% Input:
% processed     Processed directory output by automaid
%                   (def: $MERMAID/processed)
% Output:
% D             NaN (placeholder for future implementation)
% S             Metadata structure, organized by float, in raw strings
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 14-Jan-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default path.
defval('processed', fullfile(getenv('MERMAID'), 'processed'))

% CSV format: 23 fields.
fmt = [repmat('%s', [1 23]) '\n'];

% Field names (uppercase are actual SAC fields).
field = {'filename',
         'KNETWK',
         'KSTNM',
         'KHOLE',
         'KCMPNM',
         'STLA',
         'STLO',
         'STEL',
         'STDP',
         'CMPAZ',
         'CMPINC',
         'KINST',
         'SCALE',
         'USER0',
         'USER1',
         'USER2',
         'USER3',
         'KUSER0',
         'KUSER1',
         'KUSER2',
         'samplerate',
         'start',
         'end'};

% Loop over every MERMAID directory.
d = skipdotdir(dir(processed));
for i = 1:length(d)
    if d(i).isdir
        % Construct full path filename and change, e.g., 'P-08' to 'P008'.
        file = fullfile(d(i).folder, d(i).name, 'automaid_metadata.csv');
        mermaid = strrep(d(i).name(end-3:end), '-', '0');

        % Read the automaid metadata csv file.
        fid = fopen(file, 'r');
        C = textscan(fid, fmt, 'HeaderLines', 3, 'Delimiter', ',');
        fclose(fid);

        % Dynamically fill all fields.
        for j = 1:length(field)
            S.(mermaid).(field{j}) = C{j};

        end
    end
end

% Placeholder (future: cast strings to floats and ints).
D = NaN;
