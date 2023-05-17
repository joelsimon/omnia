function need2update = need2update_stla_stlo(procdir)
% need2update = NEED2UPDATE_STLA_STLO(procdir)
%
% Identify list of SAC files with header location data (STLA/STLO) that does not
% match what is printed in their respective "loc.txt" files output by automaid.
%
% Such occurrences can happen, e.g., if the SAC file is old and was written with
% an outdated version of automaid and then never overwritten with `redo=true`.
% As it stands currently (automaid < v3.6.0-F), metadata text files are
% overwritten with every run, but .sac/.mseed files are not.
%
% Input:
% procdir         $MERMAID processed directory, output with automaid
%                     (def: $MERMAID/processed)
%
% Output:
% need2dupate     Cell of SAC names that need to be updated (rewritten)
%                     (def: empty)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 31-Jan-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('procdir', fullfile(getenv('MERMAID'), 'processed'))

sac = fullsac([], procdir);
loc = readloc(procdir);

need2update = {};
for i = 1:length(sac)
    [~, hdr] = readsac(sac{i});

    idx = cellstrfind(loc.(hdr.KSTNM).sac, strippath(sac{i}));
    loc_STLA = loc.(hdr.KSTNM).stla(idx);
    loc_STLO = loc.(hdr.KSTNM).stlo(idx);

    if abs(loc_STLA - hdr.STLA) > 1e-6 || abs(loc_STLO - hdr.STLO) >= 1e-6
        need2update = [need2update ; strippath(sac{i})];

    end
end
