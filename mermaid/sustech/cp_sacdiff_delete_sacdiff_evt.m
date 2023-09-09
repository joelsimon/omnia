function cp_sacdiff_delete_sacdiff_evt()
% CP_SACDIFF_DELETE_SACDIFF_EVT
%
% Copies .sac files made by Joel (the updated ones) that were identified to
% differ from the ones made by Yong (the outdated ones) to
% ~/mermaid/sustech_on_mac so that I can git-push them to my mac and rematch
% their events there.  Also delete .evt files in Joel's event's folder,
% ~/mermaid/sustech_events/, to be replaced by my rematches.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu | joeldsimon@gmail.com
% Last modified: 07-Sep-2023, Version 9.3.0.713579 (R2017b) on GLNXA64

merdir = getenv('MERMAID');
sacdir = fullfile(merdir, 'processed_sustech');
evtdir = fullfile(merdir, 'events_sustech');

fname = fullfile(sacdir, 'compare_yong_joel', 'yong_joel_sac_diff.txt');
fid = fopen(fname, 'r');
C = textscan(fid, '%s | %s | %s\n');
fclose(fid);

sac_diff = C{2};
for i = 1:length(sac_diff)
    [succ, mess] = copyfile(fullsac(sac_diff{i}, sacdir), '~/mermaid/sustech_on_mac/processed/');
    if ~succ
        error(mess)

    else
        fprintf(mess)

    end

    [~, rev_evt] = getrevevt(sac_diff{i}, evtdir);
    gitrmfile(rev_evt);

end
