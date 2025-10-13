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
% Last modified: 01-Dec-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default paths.
defval('sacdir', fullfile(getenv('MERMAID'), 'processed'));
defval('evtdir', fullfile(getenv('MERMAID'), 'events'));

% Get list of reviewed .sac and their .evt
[sac, evt] = revsac(1, sacdir, evtdir, 'ALL');

% Open text file that tallies which .evt required EQ.TaupTimes update.
fname1 = fullfile(evtdir, sprintf('%s_%s.txt', datestr(datetime('now'), 29), mfilename));
writeaccess('unlock', fname1, false)
fid1 = fopen(fname1, 'w+');

fname2 = fullfile(evtdir, sprintf('%s_%s_phaseName1_mismatch.txt', datestr(datetime('now'), 29), mfilename));
writeaccess('unlock', fname2, false)
fid2 = fopen(fname2, 'w+');

fname3 = fullfile(evtdir, sprintf('%s_%s_tdiff_exceeds_1s.txt', datestr(datetime('now'), 29), mfilename));
writeaccess('unlock', fname3, false)
fid3 = fopen(fname3, 'w+');

% Loop over all .evt and determine which need to be updated.
lensac = length(sac);
for i = 1:length(sac)
    fprintf('Checking...%s (%i of %i)\n', strippath(sac{i}), i, lensac)
    [isupdated, new_EQ, old_EQ] = updatetauptimes(sac{i}, evt{i});

    if isupdated
        fprintf(fid1, '%s\n', strippath(evt{i}));

        for j = 1:length(old_EQ)
            if ~strcmp(new_EQ(j).TaupTimes(1).phaseName, old_EQ(j).TaupTimes(1).phaseName)
                fprintf(fid2, '%s\n', strippath(evt{i}));

            end
        end
    end

    tdiff(i) = new_EQ(1).TaupTimes(1).truearsecs - old_EQ(1).TaupTimes(1).truearsecs;
    if abs(tdiff(i)) > 1
        fprintf(fid3, '%s\n', strippath(evt{i}))

    end

end

% Write-restrict output file.
writeaccess('lock', fname1)
fprintf('\nWrote: %s\n', fname1)

writeaccess('lock', fname2)
fprintf('\nWrote: %s\n', fname2)
keyboard