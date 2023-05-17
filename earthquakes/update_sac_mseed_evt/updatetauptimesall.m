function fname = updatetauptimesall(sacdir, evtdir)
% fname = UPDATETAUPTIMESALL(sacdir, evtdir)
%
% Run `updatetauptimes` on entire reviewed .evt directory.
%
% Input:*
% sacdir    Path to processed directory (output by automaid) containing .sac
%              (def: $MERMAID/processed)
% evtdir    Path to events directory (modified by omnia) containing .evt
%              (def: $MERMAID/events)
% Output:
% fname     Text file detailing which .evt files had their EQ.TaupTimes updated
% *n/a*     Overwrites any .evt file with required EQ.TaupTimes corrections
%
% *Note: these are base paths to be searched recursively, e.g., use
%  $MERMAID/events/, not $MERMAID/events/reviewed/identified/evt/, for `evtdir`
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 17-May-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default paths.
defval('sacdir', fullfile(getenv('MERMAID'), 'processed'));
defval('evtdir', fullfile(getenv('MERMAID'), 'events'));

% Get list of reviewed .sac and their .evt
[sac, evt] = revsac(1, sacdir, evtdir, 'ALL');

% Open text file that tallies which .evt required EQ.TaupTimes update.
fname = sprintf('%s_%s.txt', mfilename, datetime('now', 'Format', 'uuuu-MM-dd'));
fname = fullfile(evtdir, fname);
writeaccess('unlock', fname, false)
fid = fopen(fname, 'w+');

% Loop over all .evt and determine which need to be updated.
lensac = length(sac);
for i = 1:length(sac)
    fprintf('Checking...%s (%i of %i)\n', strippath(sac{i}), i, lensac)
    updated = updatetauptimes(sac{i}, evt{i});

    if updated
        fprintf(fid, '%s\n', strippath(evt{i}));

    end
end

% Write-restrict output file.
writeaccess('lock', fname)
fprintf('\nWrote: %s\n', fname)
