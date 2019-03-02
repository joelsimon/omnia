function dups = mermaid_sacf_duplicates
% dups = MERMAID_SACF_DUPLICATES
%
% Returns SAC files that are both in 'identified' and 'unidentified'
% folders in $MERAZUR/events.
%
% Input:   None
% 
% Output:
% dups      Cell array of SAC files in both 'id' and 'uid' folders
% 
%
% UPDATED: As of lastfetch.txt being Fri Jan 25 18:53:04 UTC 2019
% output is empty (redundancy issues have been resolved).
%
% PREVIOUSLY: As of lastfetch.txt being Mon Jul 16 15:06:12 UTC 2018 -- 
%
% dups =
%
%   4×1 cell array
%
%     {'m13.20130430T053005.sac'}
%     {'m16.20150323T102337.sac'}
%     {'m18.20131016T101404.sac'}
%     {'m31.20160729T214445.sac'}
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 13-Feb-2019, Version 2017b

id = mermaid_sacf('id');
uid = mermaid_sacf('uid');

for i = 1:length(id)
    id{i} = strippath(id{i});
end

for i = 1:length(uid)
    uid{i} = strippath(uid{i});
end

dups = intersect(id, uid);
