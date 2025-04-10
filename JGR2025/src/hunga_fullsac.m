function sac = hunga_fullsac(sac)
% sac = HUNGA_FULLSAC(sac)
%
% Return fullpath SAC file lists for HTHH data.
% 
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 12-Oct-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('sac', [])

if ~isempty(sac)
    sac = fullsac(sac, fullfile(getenv('HUNGA'), 'sac'));

else
    hundir = getenv('HUNGA');
    sacdir = fullfile(hundir, 'sac');
    imsdir = fullfile(sacdir, 'ims');

    sac = globglob(sacdir, '*.sac');
    imssac = globglob(imsdir, '*sac.pa');

    sac = [sac ; imssac];

end
