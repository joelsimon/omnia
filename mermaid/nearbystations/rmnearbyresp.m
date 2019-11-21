function rmnearbyresp(id, redo, otype, sacdir, nearbypz, tranfunc);
% RMNEARBYRESP(id, redo, otype, sacdir, nearbypz, tranfunc)
%
% Remove the instrument response for nearby stations.
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
% otype      Tranfer type in SAC: 'none', 'vel', or 'acc' (def)
% sacdir     Directory where individual ID subdirectories live
%                (def: $MERMAID/events/nearbystations/sac/)
% nearbypz   Concatenated pole-zero file name (from fetchnearbypz.m)
%                (def: $MERMAID/events/nearbystations/pz/nearbystations.pz)
% transfunc  Shell script detailing SAC transfer function
%               (def: $OMNIA/mermaid/nearbystations/nearbytransfer)
%
% *git history, if it exists, is respected with gitrmdir.m.
%
% See also: nearbytransfer (shell script), fetchnearbypz.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 21-Nov-2019, Version 2017b on GLNXA64

% Defaults.
defval('id', '11052554')
defval('redo', false)
defval('otype', 'acc')
defval('sacdir', fullfile(getenv('MERMAID'), 'events', 'nearbystations', 'sac'))
defval('nearbypz', fullfile(getenv('MERMAID'), 'events', 'nearbystations', ...
                            'pz', 'nearbystations.pz'))
defval('transcript', fullfile(getenv('OMNIA'), 'mermaid', 'nearbystations', 'nearbytransfer'))

% Sanity.
if all(~strcmpi(otype, {'none', 'vel', 'acc'}))
    error('Input otype must be one of: ''none'', ''vel'', or ''acc''')

end

% Generate suffix (e.g., '*.vel') to append to corrected SAC files.
id = num2str(id);
iddir = fullfile(sacdir, id);
suffix = ['.' otype];

% Parent SAC directory, where complete raw files exist.
if need2continue(redo, iddir, suffix)
    system(sprintf('%s %s %s %s', transcript, iddir, otype, nearbypz));

else
    fprintf('ID %s already contains corrected SAC files of type ''%s''\n', id, otype)

end

% Child SAC directory, 'unmerged', where separated fragments of raw
% files exist (nee2continue will deterime if that directory even
% exists.)
if need2continue(redo, fullfile(iddir, 'unmerged'), suffix)
    system(sprintf('%s %s %s %s', transcript, fullfile(iddir, 'unmerged'), otype, nearbypz));

else
    fprintf('ID %s (unmerged) already contains corrected SAC files of type ''%s''\n', id, otype)

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
% Futher, even if redo is false, if the list of corrected files does
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
