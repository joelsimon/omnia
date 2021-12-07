function ser = getmerser(sacfile)
% ser = GETMERSER(sacfile)
%
% Return MERMAID serial number given a SAC filename.
%
% Input:
% sacfile     SAC filename following automaid v3.4+ convention
%
% Output:
% ser        Two-digit MERMAID serial number
%
% Ex:
%    sacfile = '20180819T042909.08_5B7A4C26.MER.DET.WLT5.sac'
%    ser = GETMERSER(sacfile)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 06-Dec-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

%% Recursive.

if iscell(sacfile)
    for i = 1:length(sacfile)
        ser{i} = getmerser(sacfile{i});
    end
    return

end

ser = fx(strsplit(fx(strsplit(strippath(sacfile), '.'), 2), '_'), 1);
