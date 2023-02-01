function [danger, dates, stdp, ocdp, stla, stlo] = intoodeep(s, mbuffer, vers, sav)
% [danger, dates, stdp, ocdp, stla, stlo] = INTOODEEP(s, mbuffer, vers, sav)
%
% Returns list of SAC files whose station depth is less than (deeper) the GEBCO
% depth at that location plus a variable depth buffer.
%
% Input:
% s          Cell array of fullpath SAC files (def: fullsac)
% mbuffer    Depth buffer -- ocean must be at least 'mbuffer' deeper than
%                MERMAID to not be flagged [m] (def: 500)
% vers       GEBCO bathymetric version (see gebco.m) (def: '2014')
% sav        true to write output to text file in pwd (false)
%
% Output:
% danger     SAC files flagged for being too close to the seafloor
% dates      Datetimes of flagged SAC files
% stdp       Station depths of flagged SAC files
% ocdp       GEBCO ocean depths of flagged SAC files
% stla       Station latitudes of flagged SAC files
% stlo       Station longitudes of flagged SAC files
%
% See also: gebco.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 31-Jan-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('s', fullsac);
defval('mbuffer', 500);
defval('vers', '2014')
defval('sav', false);

danger = {};
dates = [];
stdp = [];
ocdp = [];
stlo = [];
stla = [];

for i = 1:length(s)
    [~, h] = readsac(s{i});
    z_mermaid = -h.STDP;
    if z_mermaid == -12345 || isnan(z_mermaid)
        continue

    end
    z_ocean = gebco(h.STLO, h.STLA, vers);
    if (z_mermaid - mbuffer) < z_ocean
        danger = [danger ; s(i)];
        stdp = [stdp ; z_mermaid];
        ocdp = [ocdp ; z_ocean];
        stla = [stla ; h.STLA];
        stlo = [stlo ; h.STLO];

    end
end
if ~isempty(danger)
    dates = mersac2date(danger);

end

if sav
    fname = fullfile(pwd, sprintf('%s.txt', mfilename));
    fid = fopen(fname, 'w');
    fmt = '%s,%s,%i,%i,%.4f,%.4f\n';
    for i = 1:length(danger)
        fprintf(fid, fmt, strippath(danger{i}), datestr(dates(i), 1), stdp(i), ocdp(i), stla(i), stlo(i));

    end
    fclose(fid)
    fprintf('Wrote: %s\n', fname)

end
