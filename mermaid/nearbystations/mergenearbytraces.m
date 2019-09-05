function merged = mergenearbytraces(tr, id, writedir)
% merged = MERGENEARBYTRACES(tr, id, writedir)
%
% Wrapper to shell script 'mergesac' to merge split SAC files into a
% single SAC file.
%
% Output merged files are named:
%
% {NETWORK}.{STATION}.{LOCATION}.{CHANNEL}.merged.SAC,
%
% whose individual files share the common glob:
%
% {NETWORK}.{STATION}.{LOCATION}.{CHANNEL}*,
%
% the latter of which are moved to [writedir]/unmerged.
%
% Input:
% tr        Trace structures from fetchnearbytraces.m
% id        Event ID [last column of 'identified.txt']
%               defval('11052554')
% writedir  Directory where [id]/*.SAC written
%               (def: $MERMAID/events/nearbystations/sac/)
%
% Output:
% merged    Merged filenames, if any (def: [])
%
% See also: fetchnearbytraces.m, irisFetch.Traces
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 02-Sep-2019, Version 2017b

% Defaults.
defval('id', '11052554')
defval('writedir', fullfile(getenv('MERMAID'), 'events', 'nearbystations', 'sac'))
merged = [];
if isempty(tr)
    return

end

% Identify all unique file pattern globs.
idx = 0;
for i = 1:length(tr)
    for j = 1:length(tr{i})
        idx = idx + 1;
        glob{idx} = [tr{i}(j).network '.' ...
                     tr{i}(j).station '.' ...
                     tr{i}(j).location '.' ...
                     tr{i}(j).channel '.' ];

    end
end
glob = unique(glob);

% Pass each unique glob to mergesac, which will handle the rest:
% $ mergesac {SAC directory} {file glob} {merge filename}
merged = [];
m_idx = 0;
sac_dir = fullfile(writedir, num2str(id));
for i = 1:length(glob)
    filelist =  [glob{i} '*'];
    d = dir(fullfile(sac_dir, filelist));

    if length(d) > 1
        outfname = [glob{i} 'merged.SAC'];
        [status, result] = ...
            system(sprintf('mergesac %s "%s" %s', sac_dir, filelist, outfname));

        if status == 0
            m_idx = m_idx + 1;
            merged{m_idx} = fullfile(sac_dir, outfname);

        else
            warning('No merge: mergesac exited with the following\n%s', result)

        end
    end
end        
