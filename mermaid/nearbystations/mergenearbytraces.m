function merged = mergenearbytraces(tr, id, sacdir)
% merged = MERGENEARBYTRACES(tr, id, sacdir)
%
% MERGENEARBYTRACES is a wrapper to the shell script 'mergesac' to
% merge split SAC files, specifically returned by fetchnearbytraces.m,
% into a single SAC file.  Requires SAC program.
%
% Output merged files are named:
%
% {NETWORK}.{STATION}.{LOCATION}.{CHANNEL}.merged.SAC,
%
% whose individual files share the common glob:
%
% {NETWORK}.{STATION}.{LOCATION}.{CHANNEL}*,
%
% the latter of which are moved to [sacdir]/unmerged.
%
% Input:
% tr        Trace structures from fetchnearbytraces.m
% id        Event ID [last column of 'identified.txt']
%               defval('11052554')
% sacdir    Directory where [id]/*.SAC written
%               (def: $MERMAID/events/nearbystations/sac/)
%
% Output:
% merged    Cell of merged filenames, if any (def: {})
%
% See also: mergesac, fetchnearbytraces.m, irisFetch.Traces
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 19-Sep-2019, Version 2017b on GLNXA64

% Defaults.
defval('id', '11052554')
defval('sacdir', fullfile(getenv('MERMAID'), 'events', 'nearbystations', 'sac'))
merged = {};
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
m_idx = 0;
iddir = fullfile(sacdir, num2str(id));
for i = 1:length(glob)
    filelist =  [glob{i} '*'];
    d = dir(fullfile(iddir, filelist));

    if length(d) > 1
        outfname = [glob{i} 'merged.SAC'];
        [status, result] = ...
            system(sprintf('mergesac %s "%s" %s', iddir, filelist, outfname));

        if status == 0
            m_idx = m_idx + 1;
            merged{m_idx} = fullfile(iddir, outfname);

        else
            error('mergesac failed with the following message --\n%s', result)

        end
    end
end
