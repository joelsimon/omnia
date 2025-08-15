function [kstnm, kcmpnm] = imsinfo(sac)
% [kstnm, kcmpnm] = IMSINFO(sac)
%
% Return station and channel name given IMS .sac filename.
%
% Input:
% sac        IMS .sac filename
%
% Output:
% kstnm      Station name
% kcmpnm     Channel name
%
% Ex:
%    [kstnm, kcmpnm] = IMSINFO('H03N1.EDH.202201150400_4hr.sac')
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 23-May-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

basename = strippath(sac);
splitty = strsplit(basename, '.');
kstnm = splitty{1};
kcmpnm = splitty{2};
