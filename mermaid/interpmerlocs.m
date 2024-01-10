function [ilat, ilon, warn, warn_str] = interpmerlocs(mer_structs, ilocdate)
% [ilat, ilon, warn, warn_str] = INTERPMERLOCS(mer_structs, ilocdate)
%
% Wrapper for interpmerloc.m to accept parent structure from, e.g., readgps.m,
% and loop over all individual float directories as input for `interpmerloc.`
%
% If requested date out-of-range (e.g., float is dead), ilat & ilon returned as NaN.
%
% See also: interpmerloc (I/O)
%
% Ex: Interpolate location of floats on Jan. 30, 2023
%    mer_structs = readgps([], false); % important to set input `rm23` to false
%    [ilat, ilon, warn, warn_str] ...
%        = INTERPMERLOCS(mer_structs, datetime('2023-Jan-30', 'TimeZone', 'UTC'))
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 09-Jan-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

fn = fieldnames(mer_structs);
for i = 1:length(fn)
    [a, b, warn(i), warn_str{i}] = interpmerloc(mer_structs.(fn{i}), ilocdate);
    if ~isempty(a)
        ilat(i) = a;
        ilon(i) = b;

    else
        ilat(i) = NaN;
        ilon(i) = NaN;

    end
end
