function deploy = deploydate
% deploy = DEPLOYDATE
%
% Return MERMAID deployment dates.  Relies on text copy of "deploy" method in
% utils.py, part of automaid (update deploydate.txt here if that changes).
% 
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 06-May-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

% Read and convert the python dict
txt = readtext('deploydate.txt');
for i = 1:length(txt)

    if strcmp(txt{i}(1), '#')
        continue

    end
    serdat = strsplit(txt{i}, ':');
    ser = strrep(serdat{1}, '"', '');
    dat = extractBetween(serdat{2}, '(', ')');

    kstnm = osean2fdsn(ser);
    dday = datetime(str2num(dat{:}));
    deploy.(kstnm) = dday;

end
