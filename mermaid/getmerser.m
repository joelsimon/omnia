function ser = getmerser(sacfile)
% ser = GETMERSER(sacfile)
%
% Return MERMAID serial number given a SAC filename.
%
% Input:
% sacfile     SAC filename(s) following automaid v3.4+ convention
%                 (accepts cells)
%
% Output:
% ser        Two- to four-digit MERMAID serial number(s)
%
% Ex:
%    GETMERSER({'20180819T042909.08_5B7A4C26.MER.DET.WLT5.sac', ...
%               '20220115T043452.0026_623BE70D.MER.REQ.WLT5.sac'})
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 13-Apr-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

%% Recursive.

if iscell(sacfile)
    for i = 1:length(sacfile)
        ser{i} = getmerser(sacfile{i});
    end
    return

end

ser = fx(strsplit(fx(strsplit(strippath(sacfile), '.'), 2), '_'), 1);
