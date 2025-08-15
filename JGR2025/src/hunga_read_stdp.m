function stdp = hunga_read_stdp(kstnm, filename)
% stdp = HUNGA_READ_STDP(kstnm, filename)
%
% Input:
% kstnm    Station name; if supplied, only one depth returned [m]
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 18-Dec-2024, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

defval('filename', fullfile(getenv('HUNGA'), 'sac', 'meta', 'stdp.txt'))
defval('kstnm', [])

fid = fopen(filename, 'r');
txt = textscan(fid, '%s %f');
fclose(fid);
if ~isempty(kstnm)
    stdp = txt{2}(cellstrfind(txt{1}, kstnm));

else
    stdp = struct();
    for i = 1:length(txt{1})
        stdp.(txt{1}{i}) = txt{2}(i);

    end
end

