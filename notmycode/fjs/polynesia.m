function varargout=polynesia(c11,cmn,cax,mult)
% [z,lon,lat]=POLYNESIA(c11,cmn,cax,mult)
%
% Collects data and makes a map of, well, you guessed it
%
% INPUT:
%
% c11       lon,lat of the top left of the box
% cmn       lon,lat of the bottom right of the box
% mult      an integere multiplicative resolution degrader [default: 1]
%
% OUTPUT:
%
% z         the requested elevation
% lon       the longitudes
% lat       the latitudes
%
% EXAMPLE:
%
% Defaults work best; just Tahiti and Moorea require adjustment
% polynesia([208 -16],[212 -19])
%
% Last modified by fjsimons-at-alum.mit.edu, 03/12/2020

load(fullfile(getenv('IFILES'),'TOPOGRAPHY','POLYNESIA','732c10d12f3c1ff02b85522b39bfd9ee1aa42244.mat'))

% Should I explore Ocean Data View?

% This from Joel Simon
% http://ds.iris.edu/gmap/#network=*&starttime=2018-06-01&maxlat=4&maxlon=251&minlat=-33&minlon=176&drawingmode=box&planet=earth
defval('c11',[176   4])
defval('cmn',[251 -33])
% Get the topography parameters
defval('vers',2019);
defval('npc',20);
%[~,~,~,~,~,~,dxdy,NxNy]=readGEBCO(vers,npc);

defval('mult',1); mult=round(mult);
%dxdy=dxdy*mult;

% % Make the save file
% defval('savefile',fullfile(getenv('IFILES'),'TOPOGRAPHY','POLYNESIA',...
%                            sprintf('%s.mat',hash([c11 cmn vers npc dxdy NxNy],'SHA-1'))))


% % Make the grid of longitudes and latitudes
% lons=c11(1):+dxdy(1):cmn(1);
% % Watch the conventions for GEBCO below
% lons=lons-(lons>180)*360;
% lats=c11(2):-dxdy(2):cmn(2);
% [LON,LAT]=meshgrid(lons,lats);

% % Get the elevation!
% if exist(savefile)~=2
%     z=gebco(LON,LAT,vers,npc);
%     save(savefile,'z')
% else
%     load(savefile)
% end

% And now make the plot if there is no output requested
if nargout==0
    % Begin with a new figure, minimize it right away
    defval('fs',6);
    % Color limits
    % The reference global color rendition would be
    % imagefnan(c11,cmn,z,'demmap',[-7473 5731])
    % cax=[-4000 0.75*max(z(:))];
    % cax=halverange(minmax(z),75);
    defval('cax',[-7000 1500]);
    printit(z,cax,c11,cmn,fs,vers,mfilename,mult)
end

% Or maybe just do output
varns={z};
varargout=varns(1:nargout);


% Subfunction for faster prototyping
function printit(z,cax,c11,cmn,fs,vers,nem,mult)
% Note that the print resolution for large images is worse than the
% detail in the data themselves. One could force print with more dpi.
clf
% Color bar first...
[cb,cm]=cax2dem(cax,'hor');
% then map
imagefnan(c11,cmn,z,cm,cax)
% then colorbar again for adequate rendering
[cb,cm]=cax2dem(cax,'hor');
% Cosmetics
% plotplates(c11,cmn) is just not good enough
longticks(gca,2)
deggies(gca)
set(gca,'FontSize',fs)
xlabel('longitude')
ylabel('latitude')
cb.XLabel.String=sprintf('GEBCO %i elevation (m)',vers);
cb.XTick=unique([cb.XTick minmax(cax)]);
warning off MATLAB:hg:shaped_arrays:ColorbarTickLengthScalar
longticks(cb,2)
warning on MATLAB:hg:shaped_arrays:ColorbarTickLengthScalar
shrink(cb,1,1.5)
movev(cb,-0.08)
% Print it
figdisp(nem,sprintf('%3.3i',mult),[],2)
