function ph = purist(ph)
% ph = PURIST(ph)
%
% Converts various core phases to purist name for use in TauP.  See
% instruction manual pp.16 paragraph 9. Doesn't convert S phases.
%
% E.g. converts PKPab to PKP; PKPdf to PKIKP
%
%
% INPUT:
% ph                 Phase name, a string
%
% OUPUT
% ph                 Phase name acceptable as TauP input
%
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 30-Aug-2016, Version 2017b

if strcmp(strtrim(ph),'PKPdf')
    ph = 'PKIKP';

elseif strcmp(strtrim(ph),'PKPbc') || ...
        strcmp(strtrim(ph),'PKPab')
    ph = 'PKP';

end
