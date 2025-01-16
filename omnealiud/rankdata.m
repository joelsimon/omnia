function r = rankdata(data, direc)
% r = rankdata(data, direc)
%
% Return data rank.
%
% Input:
% data    A data vector
% direc   'ascend' (default) or 'descend'
%
% Output:
% r       Data rank
%
% Ex:
%    data = randi(100, 1, 5)
%    r_up   = RANKDATA(data, 'ascend')
%    r_down = RANKDATA(data, 'descend')
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 15-Jan-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

% Default.
defval('direc', 'ascend');

% Thanks Roger Stafford at mathworks help pages.
[~, idx] = sort(data, direc);
r = 1:length(data);
r(idx) = r;
