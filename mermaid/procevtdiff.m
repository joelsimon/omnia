function [proc_only, evt_only] = procevtdiff(proc_dirpath, evt_dirpath)
% [proc_only, evt_only] = PROCEVTDIFF(proc_dirpath, evt_dirpath)
%
% Returns difference of lists of .sac and .evt files in their respective dirs.
%
% Input:
% proc_dirpath  Path to (recursive) SAC file directories
%                   (def: $MERMAID/processed)
% evt_dirpath   Path to (recursive) .evt (mat) file directories
%                   (def: $MERMAID/eventsd/reviewed)
%
% Output:
% proc_only     Files (basename, no extension) only in `proc_dirpath`
% evt_only      Files (basename, no extension) only in `evt_dirpath`
%
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 14-Jan-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults.
mer_dirpath = getenv('MERMAID');
defval('proc_dirpath', fullfile(mer_dirpath, 'processed'))
defval('evt_dirpath', fullfile(mer_dirpath, 'events', 'reviewed'))

% The the lists of filenames.
proc_filenames = get_filenames(proc_dirpath, '.sac');
evt_filenames = get_filenames(evt_dirpath, '.evt');

% Compare the lists of filenames.
proc_only = setdiff(proc_filenames, evt_filenames);
evt_only = setdiff(evt_filenames, proc_filenames);

function filenames = get_filenames(dirpath, ext)
% Define directory.
diro = dir(fullfile(dirpath, sprintf('**/*%s', ext)));

% Recursively search directory.
filenames = recursivedir(diro);
if isempty(filenames)
    warning('No files with %s extensions in %s', ext, dirpath)

end

% Remove fullpath (leave basename only) and extension.
filenames = cellfun(@(xx) strippath(xx(1:end-length(ext))), filenames, ...
                        'UniformOutput', false);
