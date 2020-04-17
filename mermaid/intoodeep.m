function [danger, dates, stdp, ocdp] = intoodeep(s, mbuffer, vers)
% [danger, dates, stdp, ocdp] = INTOODEEP(s, mbuffer, vers)
%
% Returns list of SAC files whose station depth is less than (deeper) the GEBCO
% depth at that location plus a variable depth-buffer.
%
% Input:
% s          Cell array of fullpath SAC files (def: fullsac)
% mbuffer    Depth buffer -- ocean must be at least 'mbuffer' deeper than
%                MERMAID to not be flagged [m] (def: 500)
% vers       GEBCO bathymetric version (see gebco.m) (def: '2014')
%
% Output:
% danger     Cell array of SAC files flagged for being too close to the seafloor
% dates      Cell array of datetimes of flagged SAC files
% stdp       Cell array of station depths of flagged SAC files
% ocdp       Cell array of ocean depths of flagged SAC files
%
% See also: gebco.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu | joeldsimon@gmail.com
% Last modified: 17-Apr-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('s', fullsac);
defval('mbuffer', 500);
defval('vers', '2014')

danger = {};
stdp = {};
ocdp = {};
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

    end
end
dates = mersac2date(danger);
