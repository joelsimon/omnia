function loc = readlocraw(processed)
% loc = READLOCRAW(processed)
%
% Return RAW STRINGS (i.e., literally the printed text in loc.txt) of interpolated MERMAID locations
% at the time of recording SAC/miniSEED files from text file output by automaid v3.2.0+.
%
% NB, see readloc.m to read and cast these data as double (something usable).  This function is to
% verify strings printed by various entities (automaid; mseed2sac) are equal within precision.
%
% Input:
% processed     Processed directory output by automaid
%                   (def: $MERMAID/processed)
% Output:
% loc           Interpolated GPS structure that parses loc.txt, organized by float name
%
% See also: readloc.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 23-Nov-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% See readloc.m for comments.

merpath = getenv('MERMAID');
defval('processed', fullfile(merpath, 'processed'))

fmt = '%s    %s    %s    %s\n';
d = skipdotdir(dir(processed));
for i = 1:length(d)
    if d(i).isdir
        file = fullfile(d(i).folder, d(i).name, 'loc.txt');
        fid = fopen(file, 'r');
        C  = textscan(fid, fmt, 'HeaderLines', 3);

        mermaid = strrep(d(i).name(end-3:end), '-', '0');
        loc.(mermaid).file_name = C{1};
        loc.(mermaid).stla = C{2};
        loc.(mermaid).stlo = C{3};
        loc.(mermaid).stdp = C{4};
        
    end
end
