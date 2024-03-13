function [lat,dlon,refarea,nmr]=authalic(c11,cmn,dlat,dlon)
% [lat,dlon,refarea,nmr]=AUTHALIC(c11,cmn,dlat,dlon)
%
% Calculates an equal-area grid for a regional tomography experiment
%
% INPUT:
%
% c11       [x,y]/[lon,lat]-coordinates of the upper left grid corner
% [degrees]
% cmn       [x,y]/[lon,lat]-coordinates of the bottom right corner [degrees]
% dlat      latitude interval, maintained throughout [degrees]
% dlon      longitude interval at the equator [degrees]
%
% OUTPUT:
%
% lat       latitudes describing the grid, column vector [degrees]
% dlon      longitudes describing the grid, column vector [degrees]
% refarea   reference area, size of one grid cell at the equator
% nmr       the number of cells per row in the grid
%
% Only needs to calculate DLON at every LAT to have a complete
% representation of the grid. Out comes a column vector, in degrees. For
% a given latitude, gives the longitude interval so the area spanned by
% that latitude and the next one in the row is conserved. Because we give
% C11 and CMN, the 'next' latitude is always the more meridional one. So
% the outcoming LAT should always have LAT(1)>LAT(end). Also calculates
% the number of columns in each row. Even the not finished cells count as
% one,  ie those at the end of the row that cannot have the full width
%
% EXAMPLE I:
%
%  [lat,dlon,c,nmr]=authalic([110 0],[180 -50],1,0.5);
%  latsup=lat(1:end-1); latsdwn=lat(2:end);
%  lonslft=zeros(size(latsup)); lonsrgt=dlon;
% % This should be the reference area again
%  difer(spharea([lonslft latsup],[lonsrgt latsdwn])*4*pi*6371^2-c,9);
%
% EXAMPLE II:
%
%% A grid for isotropic inversions, one parameter per cell
% [lat,dlon,c,nmr1]=authalic([60 15],[200 -65],2/sqrt(3),2/sqrt(3)-0.0047);
%% A coarser grid for azimuthal anisotropy, three parameters per cell
% [lat,dlon,c,nmr2]=authalic([60 15],[200 -65],2,2);
%% Check that both grids yield the same number of parameters
% difer(sum(nmr1)-sum(nmr2)*3)
%
% Last modified by fjsimons-at-alum.mit.edu, 05/30/2022
%
% Compute reference area on Earth (in km^2)
refarea=spharea([0 dlat/2],[dlon -dlat/2])*4*pi*(fralmanac('Radius')/1000)^2;
disp(['Reference area is ',num2str(fround(refarea,0)),' square km'])

% Adjust longitudinal intervals
lat=c11(2):-abs(dlat):cmn(2);
lat=lat';

% Conversion to radians
lat=lat*pi/180;
dlat=dlat*pi/180;

% Output (in degrees)
dlon=dlon.*abs(2*sin(dlat/2))./abs(sin(lat(1:end-1))-sin(lat(2:end)));
lat=lat/pi*180;

% Number of cells per row
nmr=ceil(abs([cmn(1)-c11(1)])./dlon);
