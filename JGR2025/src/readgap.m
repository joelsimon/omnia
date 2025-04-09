function gap = readgap(sac)
% gap = READGAP(sac)
%
% Return gaps identified in merged SAC files.
%
% Input:
% SAC    SAC filename
%
% Output:
% gap    Cell of start/end identified in sac2mergedsac_*_gap.mat
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 08-Sep-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

meta_dir = fullfile(getenv('HUNGA'), 'sac', 'meta');
ser = getmerser(sac);
f = fullfile(meta_dir, sprintf('sac2mergedsac_%s_gap.mat', ser));
if exist(f, 'file') == 2
    gap = load(f);
    gap = gap.gap;

else
    gap = [];

end
