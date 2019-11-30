function [nearby_sac, nearby_sacu, new, newu] = rmnearbyresp(id, redo, otype, nearbydir, nearbypz, transcript, freqlimits)
% [nearby_sac, nearby_sacu, new, newu] = ...
%     RMNEARBYRESP(id, redo, otype, nearbydir, nearbypz, transcript, freqlimits)
%
% Remove the instrument response for nearby stations and save the
% corrected SAC file in the same directory with the output type appended.
%
% This function is simply a wrapper for the shell script
% nearbytransfer.  See there for deconvolution details.
%
% RMNEARBYRESP requires the SAC program.
%
% Any existing SAC files removed, e.g., in the case of redo = true,
% are printed to the screen.*
%
% id         Event ID [last column of 'identified.txt']
%                defval('11052554')
% redo       true to delete* existing corrected SAC files and remake them
%                (def: false)
% otype      Transfer type in SAC: 'none', 'vel', or 'acc' (def)
% nearbydir  Path to directory containing nearby stations
%                'sac/' and 'evt/' subdirectories
%                 (def: $MERMAID/events/nearbystations/)
% nearbypz   Concatenated pole-zero file name (from fetchnearbypz.m)
%                (def: $MERMAID/events/nearbystations/pz/nearbystations.pz)
% transcript Shell script detailing SAC transfer function
%                (def: $OMNIA/mermaid/nearbystations/nearbytransfer)
% freqlimits 1x4 array of freqlimits for SAC transfer in Hz
%                (def: [0.05 0.1 10 20])
% Output:
% nearby_sac    Cell array of corrected SAC files from nearby stations
% nearby_sacu   Cell array of corrected unmerged SAC files from nearby stations
% new           logical true if corrected SAC generated fresh
% newu          logical true if corrected SAC unmerged generated fresh
%
% *git history, if it exists, is respected with gitrmdir.m.
%
% See also: nearbytransfer (shell script), fetchnearbypz.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 29-Nov-2019, Version 2017b on GLNXA64

% Defaults.
defval('id', '11052554')
defval('redo', false)
defval('otype', 'acc')
defval('nearbydir', fullfile(getenv('MERMAID'), 'events', 'nearbystations'))
defval('nearbypz', fullfile(getenv('MERMAID'), 'events', 'nearbystations', ...
                            'pz', 'nearbystations.pz'))
defval('transcript', fullfile(getenv('OMNIA'), 'mermaid', 'nearbystations', 'nearbytransfer'))
defval('freqlimits', [0.05 0.1 10 20])

% Sanity.
if all(~strcmpi(otype, {'none', 'vel', 'acc'}))
    error('Input otype must be one of: ''none'', ''vel'', or ''acc''')

end

% Parent SAC directory, where complete raw files exist.
new = main(id, redo, otype, nearbydir, nearbypz, transcript, freqlimits, false);

% Child SAC directory, where incomplete (unmerged) raw files exist.
newu = main(id, redo, otype, nearbydir, nearbypz, transcript, freqlimits, true);

% Nab the corrected files.
[nearby_sac, nearby_sacu] = getnearbysac(id, otype, nearbydir);

%______________________________________________________________%
function new = main(id, redo, otype, nearbydir, nearbypz, transcript, freqlimits, ismerge)

% Generate suffix (e.g., '*.vel') to append to corrected SAC files.
suffix = ['.' otype];

% Find the relevant directory of SAC files.
id = num2str(id);
iddir = fullfile(nearbydir, 'sac', id);
mergestr = '';
if ismerge
    iddir = fullfile(iddir, 'unmerged');
    mergestr = ' unmerged';

end

if need2continue(redo, iddir, suffix)
    % This is where the (black) magic happens.
    [status, result] = system(sprintf('%s %s %s %s %f %f %f %f', ...
                                      transcript, iddir, nearbypz, ...
                                      otype, freqlimits(1), ...
                                      freqlimits(2), freqlimits(3), ...
                                      freqlimits(4)))

    % Handle errors.
    if status ~= 0 || contains(result, 'ERROR', 'IgnoreCase', true)
        error('SAC transfer failed (full printout above)')

    end
    new = true;

else
    new = false;
    if ~isempty(skipdotdir(dir(fullfile(iddir, ['*' suffix]))))
        fprintf('ID %s%s already contains corrected SAC files of type ''%s''\n', id, mergestr, otype)

    end
end

%______________________________________________________________%
function cont = need2continue(redo, iddir, suffix)
% Output: cont --> logical continuation flag
%
% By default redo is false. However, if no corrected SAC files exist
% (of the output type requested) main needs to continue execution.
% Therefore, determine if corrected SAC files exist and base
% continuation flag on the combination of the user-requested redo flag
% and the existence or lack thereof of corrected SAC files.
%
% Further, even if redo is false, if the list of corrected files does
% not match exactly the list of raw files, we need to dump everything
% and start over; see gitrmdir.m

cont = false;
if exist(iddir, 'dir') == 7
    raw_sac = skipdotdir(dir(fullfile(iddir, '*.SAC')));
    corr_sac = skipdotdir(dir(fullfile(iddir, ['*' suffix])));

    if ~isempty(corr_sac)
        all_raw = {raw_sac.name}';
        all_corr = {corr_sac.name}';
        all_corr_root = cellfun(@(xx) strrep(xx, suffix, ''), all_corr, ...
                                'UniformOutput', false);

        if redo || ~isequal(all_raw, all_corr_root)
            cont = true;
            [git_removed, deleted] = gitrmdir(corr_sac) % leave unterminated to print output

        end
    else
        cont = true;

    end
end
