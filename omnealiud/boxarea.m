function [area, perc] = boxarea(minlat, minlon, maxlat, maxlon, refellip, units)
% [area, perc] = BOXAREA(minlat, minlon, maxlat, maxlon, refellip, units)
%
% Computes the surface area of a box on the reference ellipsoid.
%
% N.B.: Be very careful about mixing (+) and (-) lat and lon.
% Latitude wrapping on itself: 
%    [area, perc] = BOXAREA(0, -180,  90, 180) % Northern Hemisphere
%    [area, perc] = BOXAREA(0, -180, 180, 180) % line at equator
%    [area, perc] = BOXAREA(0, -180, 270, 180) % Southern Hemisphere
% 
% Longitude wrapping on itself --
%    [area, perc] = BOXAREA(-90,   0, 90, 180) % Eastern Hemisphere
%    [area, perc] = BOXAREA(-90, 180, 90, 360) % Western hemisphere
%    [area, perc] = BOXAREA(-90,   0, 90, 360) % entire world
%
% Input:
% minlat      Minimum latitude (def: -33)
% minlon      Minimum longitude (def: 176)
% maxlat      Maximum latitude (def: 4)
% maxlon      Maximum longitude (def: 251)
% refellip    Reference ellipsoid* (def: 'wgs84')
% units       Units of surface area (def: 'kilometers')
%
% Output:
% area        Area in units^2
% perc        Area in percentage of total Earth's surface
% 
% *See also: referenceEllipsoid.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 24-Aug-2019, Version 2017b

% Defaults.
defval('minlat', -33)
defval('minlon', 176)
defval('maxlat', 4)
defval('maxlon', 251)
defval('refellip', 'wgs84')
defval('units', 'kilometers')

% Compute the area.
earthellipsoid = referenceEllipsoid(refellip, units);
area = areaquad(minlat, minlon, maxlat, maxlon, earthellipsoid);
perc = (area / earthellipsoid.SurfaceArea) * 100;

%% SOME NOTES:

% Note the odd convention of defining the box: 
%
%    area = areaquad(-90, -179, 90, 179)
%
% Does not cross the +-180 longitude line from west to east (defining
% just a narrow sliver in the Pacific) but rather goes all the way
% around the world and thus encompasses the area of nearly the entire
% globe.
%
% In August 2019 the floats that were min/max in each direction where:
%
%    lat,  lon
% N:   2, -143
% W: -21, -111
% S: -31, -148
% E: -15,  178
%
% So the bounding box (with a 2 degree buffer) is defined as 
%
% 4 N, -109 W, -33 S, 176 E
%
% BUT: That as input does not work because it loops around the world
% the wrong direction.  Hence you see the change I made in the query:
% using east as the direction I define: the 
%
% minlon = 176
% maxlon = (180 - 109) + 180 = 251.
%
% areaE = areaquad(-33, 176, 4, 251) or areaE = areaquad(-33, 251, 4, 176) 
%
% Alternatively, from the west it could be:
%
% minlon = (180 - 176) - 180 = -184
% minlon = -109
%
% areaW = areaquad(-33, -184, 4, -109) or areaW = areaquad(-33, -109, 4, -184)
%
% These all are equivalent: areaE - areaW = 1.37e-17 (percent)
%
% TLDR; 176 E == 184 W; 109 W == 251 E
%
% I.e., if you want to cross +-180 you must stay in same E/W reference
% frame, don't mix (+) and (-): 176 E to 251 E, or 109 W to 184 W 

return

% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%
% Joel note pertaining to nearbystations.txt
%
% This does not work if you draw the box on http://ds.iris.edu/gmap
% per the warning above about mixing + and - longitude values.  Ergo
% hand code in bounding box.
%
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

% Parse the values in the 'minlat=????&minlong=???&' strings in nearbystations.txt.
defval('filename', fullfile(getenv('MERMAID'), 'events', 'nearbystations', ...
                            'nearbystations.txt'))
boundary = {'minlat', 'minlon', 'maxlat', 'maxlon'};
for i = 1:4
    [~, lyne, idx] = mgrep(filename, boundary{i}, 1);
    lyne = lyne{:}; 
    idx = idx{:};
    lyne = lyne(idx+7:end);   % +7 to skip minlat=
    splits = strfind(lyne, '&');
    box.(boundary{i}) = str2double(lyne(1:splits(1)-1));
    
end

% Compute the area.
earthellipsoid = referenceEllipsoid('wgs84','kilometers');
area = areaquad(box.minlat, box.minlon, box.maxlat, box.maxlon, earthellipsoid);
perc = (area / earthellipsoid.SurfaceArea) * 100;
