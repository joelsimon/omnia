function tc=truecourse(lon1lat1,lon2lat2)
% tc=TRUECOURSE([lon1 lat1],[lon2 lat2]) 
%
% Calculates the true course at the first point between great-circle points
%
% INPUT:
%
% [lon1 lat1]  longitude and latitude of the start points [degrees]
% [lon2 lat2]  longitude and latitude of the end points [degrees]
%
% OUTPUT:
%
% tc           the requested true course
%
% (True course is the angle between the local meridian and the course line
% measured anticlockwise.) Everything in degrees. Input may be two arrays
% of (mx2) coordinates. From http://www.best.com/~williams/avform.htm
%
% EXAMPLE:
%
% plot([110 100],[-4 -10]); truecourse([110 -4],[100 -10])
% truecourse([100 -10],[110 -4])
%
% Last modified by fjsimons-at-alum.mit.edu, 06/13/2007

% For longitudes close together, get minus signs for
% both the cosine and the sine of the different angles.
% Once you take the double angle, the cos and sine
% are the same (if the longitudes are very close together)

% Conversion to radians
lon1lat1=lon1lat1*pi/180;
lon2lat2=lon2lat2*pi/180;

[lon1,lat1]=deal(lon1lat1(:,1),lon1lat1(:,2));
[lon2,lat2]=deal(lon2lat2(:,1),lon2lat2(:,2));

tc=mod(atan2(sin(lon1-lon2).*cos(lat2),...
    cos(lat1).*sin(lat2)-sin(lat1).*cos(lat2).*cos(lon1-lon2)), 2*pi);

% Special case: course should be 
% pi starting from N-pole and 0 starting from S-pole
checkmat=cos(lat1) < eps;
tc(checkmat)=0;
tc(checkmat & lat1>0)=pi;

% Conversion to degrees
tc=tc*180/pi;
