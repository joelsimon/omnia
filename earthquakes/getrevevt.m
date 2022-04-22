function [revEQ, rev_evt] = getrevevt(sac, evtdir)
% [revEQ, rev_evt] = GETREVEVT(sac, evtdir)
%
% Like getevt.m, but only return the reviewed .evt EQ structure.
%
% Useful, e.g., especially for REQ files where a reviewed .evt file saved
% without any associated .raw.evt or .raw.pdf files in the unreviewed directory,
% omissions that would otherwise break getevt.m.
%
% Input:
% sac       SAC filename (or cell array assuming all share single `evtdir`)
%               (def: '20180819T042909.08_5B7A4C26.MER.DET.WLT5.sac')
% evtdir    Path to directory containing 'raw/' and 'reviewed'
%               subdirectories (def: $MERMAID/events/)
% Output:
% revEQ     Reviewed EQ structure (or cell array, if `sac` is cell)
%               EQ = [] means .evt file exists and event unidentified
%               EQ = NaN means .evt file does not exist
% rev_evt   Full path to .evt file containing EQ structure
%               (or cell array, if `sac` is cell)
% See also: getevt.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 21-Apr-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

%% Recursive.

% Defaults.
defval('sac', '20180819T042909.08_5B7A4C26.MER.DET.WLT5.sac')
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))

if iscell(sac)

    %% Recursion.

    for i = 1:length(sac)
        [revEQ{i}, rev_evt{i}] = getrevevt(sac{i}, evtdir);

    end
    return

end

% Use dir.m recursive search to look through 'identified/', 'unidentified/, and
% 'purgatory/' subdirectories in 'reviewed'.
sac_name = strippath(sac);
evt_name = strrep(lower(sac_name), '.sac', '.evt');

rev_dir = dir(fullfile(evtdir, 'reviewed', '**/*', evt_name));
if isempty(rev_dir)
    warning('%s not found in %s', evt_name, rev_dir.folder)
    revEQ = NaN;
    rev_evt = [];

else
    rev_evt = fullfile(rev_dir.folder, rev_dir.name);
    if contains(rev_evt, 'purgatory')
        warning('\n%s in purgatory...perhaps not reviewed', sac_name)

    end
    rev_tmp = load(rev_evt, '-mat');
    revEQ = rev_tmp.EQ;

end
