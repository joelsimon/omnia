function writeeventid(sacdir, evtdir)
% WRITEEVENTID(sacdir, evtdir)
%
% Write event text file with lines: <sac_filename>  | <contrib_id>  | <iris_id>
%
% Input:
% sacdir       Directory containg .sac files (def: $MERMAID/processed/)
% evtdir       Directory containg .evt files (def: $MERMAID/events/
%
% Output: eventid.txt
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 14-Aug-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))

fmt = '%-45s  | %14s  |  %8s\n';
fname = fullfile(evtdir, 'reviewed', 'identified', 'txt', 'eventid.txt');
writeaccess('unlock', fname, false);
fid = fopen(fname, 'w');
fprintf(fid, '                                SAC_FILENAME         CONTRIB_ID      IRIS_ID\n')';

[sac, evt] = revsac(1, sacdir, evtdir, 'ALL');
for i = 1:length(evt)
    sname = strippath(sac{i});
    tmp = load(evt{i}, '-MAT');
    EQ = tmp.EQ;
    if length(EQ) > 1
        EQ = EQ(1);
        sname = [sname '*'];

    end
    [contrib_eventid, ~, iris_eventid] = eventid(EQ);
    fprintf(fid, fmt, sname, contrib_eventid, iris_eventid);

end
fclose(fid);
writeaccess('lock', fname);
fprintf('Wrote: %s\n', fname)
