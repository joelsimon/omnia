function [nearby_sac, nearby_sacu] = getnearbysac(id, otype, nearbydir)
% [nearby_sac, nearby_sacu] = GETNEARBYSAC(id, otype, nearbydir)
%
% Return the SAC file(s) in [nearbydir]/sac/[id].
%
% Input:
% id           IRIS public event identification number
%                  (def: 10948555)
% otype        Nearby SAC file output type, see rmnearbyresp.m
%              []: (empty) return raw time series (def)
%              'none': return displacement time series (nm)
%              'vel': return velocity time series (nm/s)
%              'acc': return acceleration time series (nm/s/s)
% nearbydir    Path to directory containing nearby stations
%                   'sac/' and 'evt/' subdirectories
%                   (def: $MERMAID/events/nearbystations/)
%
% Output:
% nearby_sac   Cell array of SAC files from nearby stations
% nearby_sacu  Cell array of unmerged SAC files from nearby stations,
%                  if they exist (see mergenearbytraces.m)
%
% See also: getnearbysacevt.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 12-Feb-2020, Version 2017b on GLNXA64

% Defaults.
defval('id', '10948555')
defval('otype', [])
defval('nearbydir', fullfile(getenv('MERMAID'), 'events', 'nearbystations'))

% Sanity.
id = strtrim(num2str(id));
iddir = fullfile(nearbydir, 'sac', id);
if exist(iddir, 'dir') ~= 7
    error(sprintf('Nonexistent event ID directory:\n%s', iddir))

end

%  Default to have an empty suffix, i.e., return raw SAC files.
suffix = [];
if ~isempty(otype)
    if all(~strcmpi(otype, {'none', 'vel', 'acc'}))
        error('If nonempty, otype must be one of: ''none'', ''vel'', or ''acc''')

    else
        suffix = sprintf('.%s', otype);

    end
end

% Fetch complete SAC files in top-level directory.
sac_request =  fullfile(iddir, sprintf('*.SAC%s', suffix));
nearby_sac = getem(sac_request);

% Fetch split SAC files in child directory.
sacu_request =  fullfile(iddir, 'unmerged', sprintf('*.SAC%s', suffix));
nearby_sacu = getem(sacu_request);

%_____________________________________________________________________________%
function sac = getem(sac_request)
sacdir = skipdotdir(dir(sac_request));
if ~isempty(sacdir)
    for i = 1:length(sacdir)
        if ~sacdir(i).isdir
            sac{i} = fullfile(sacdir(i).folder, sacdir(i).name);

        end
    end
    sac = sort(sac(:));

else
    %warning('No SAC files found matching:\n %s', sac_request);
    sac = {};

end
