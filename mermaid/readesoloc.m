function mer = readesoloc(eso_locdir)
% mer = READESOLOC(eso_locdir)
%
% Parse into struct MERMAID-location text files fetched from
% EarthScopeOceans.org using `fetchesoloc`.
%
% NB: these locations from .vit files (and not the raw .MER and .LOG files) and
% thus their timing is not exactly the same as the more accurate "merged" GPS
% fixes returned by `automaid`.
%
% Input:
% eso_locdir   Folder where, e.g., "N0001_all.txt" written to using `fetchesoloc`
%                  (def: $MERMAID/eso_locations)
%
% Output:
% mer          Struct parsing date/location info from each loc file
%
% See also: fetchesoloc
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 09-Mar-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default ESO locations directory
defval('eso_locdir', fullfile(getenv('MERMAID'), 'eso_locations'));

% Specify ESO loc file date format
date_fmt = 'dd-MMM-uuuuHH:mm:ss';

% Get list of all loc files in specified ESO dir
loc_file = globglob(eso_locdir, '*_all.txt');
for i = 1:length(loc_file)
    % Open and read each loc txtfile using format stolen from `vit2tbl`
    % Note empty delimiter because col 2 is day + space + time
    % (without, `textscan` splits col despite 20-char specification)
    fid = fopen(loc_file{i}, 'r');
    c = textscan(fid, fmtout, 'Delimiter', '');

    % FJS has this relic of 4-char station names still posted
    % (I think for proper site function?)
    % P054 == P0054; dump the 4-char stations
    kstnm = erase(strippath(loc_file{i}), '_all.txt');
    if length(kstnm) ~= 5
        continue

    end

    % Parse relevant columns struct
    mer.(kstnm).date = datetime(c{2}, 'InputFormat', date_fmt,'TimeZone', 'UTC');
    mer.(kstnm).lat = c{3}(:);
    mer.(kstnm).lon = c{4}(:);

    % Sort all fields based on date (P0043 unsorted on 14-Apr-2021)
    [~, idx] = sort(mer.(kstnm).date);
    mer.(kstnm) = structfun(@(xx) xx(idx), mer.(kstnm), 'Un', 0);

end


% Fuction pulled from `vit2tbl` written by Frederik J. Simons
% (https://github.com/earthscopeoceans/serverscripts/blob/master/vit2tbl.m)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAKE FORMAT STRING
function fmt = fmtout

% All but last one get spaces
stname_fmt  = '%5s   ';
%%%%%%%%%%%%%%%%%%%%%%%%
stdt_fmt    = '%20s ';   % Required despite %20s: set `textscan` delimiter to ''
STLA_fmt    = '%11.6f ';
STLO_fmt    = '%12.6f ';
%%%%%%%%%%%%%%%%%%%%%%%%
hdop_fmt    = '%7.3f';
vdop_fmt    = '%7.3f   ';
%%%%%%%%%%%%%%%%%%%%%%%%
Vbat_fmt    = '%6d ';
minV_fmt    = '%6d   ';
%%%%%%%%%%%%%%%%%%%%%%%%
Pint_fmt    = '%6d';
Pext_fmt    = '%6d';
Prange_fmt  = '%5d   ';
%%%%%%%%%%%%%%%%%%%%%%%%
cmdrcd_fmt  = '%3d ';
f2up_fmt    = '%3d ';
% Last one gets a closure
fupl_fmt    = '%3d\n';

% Combine all the formats, the current result is:
% '%s %s %11.6f %11.6f %8.3f %8.3f %5i %5i %5i %12i %5i %3i %3i %3i\n'
fmt = [stname_fmt, ...
       stdt_fmt,   ...
       STLA_fmt,   ...
       STLO_fmt,   ...
       hdop_fmt,   ...
       vdop_fmt,   ...
       Vbat_fmt,   ...
       minV_fmt,   ...
       Pint_fmt,   ...
       Pext_fmt,   ...
       Prange_fmt, ...
       cmdrcd_fmt, ...
       f2up_fmt,   ...
       fupl_fmt];
