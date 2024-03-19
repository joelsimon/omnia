function varargout=gebco(lon,lat,vers,npc,method,xver,jig,gt)
% [z,lon,lat,A,R,jig]=gebco(lon,lat,vers,npc,method,xver,jig,gt)
%
% Returns the GEBCO bathymetry interpolated to the requested location
%
% INPUT:
%
% lon      Requested longitudes, in decimal degrees, ideally -180<=lon<180
% lat      Requested latitudes, in decimal degrees, ideally -90<=lat<=90
% vers     2019  version (15 arc seconds)
%          2014  version (30 arc seconds) [default]
%          2008  version (30 arc seconds, deprecated)
%          '1MIN' version (1 arc minute, deprecated)
%          'WMS' uses the GEBCO Web Map Service request server
% npc      sqrt(number) of split pieces [default: 10]
% method   'nearest' (default), 'linear', etc, for the interpolation
% xver     Extra verification [1] or not [0]
% jig      A rejigging factor to cover up for a bad request [default: none]
% gt       0 the actual data [default] 
%          1 the source identifier grid (SID), if applicable
%          2 the data type identifier grid (TID), if applicable
%
% OUTPUT:
%
% z        The elevation/bathymetry at the requested point
% lon,lat  The longitude and latitude of the requested point
% A,R      A map and its raster, in case you went with 'WMS' and xver==1
% jig      The rejigging factor to cover up for a bad request
%
% EXAMPLES:
%
%% Some random locations with varying methods compared
% gebco('demo1')
%% A whole grid that should LOOK like the original data set
% gebco('demo2')
%% A whole grid that should BE like the original data set around somewhere
% gebco('demo3')
%% A log of a MERMAID float
% gebco('demo4','P006')
%% A grid of data and a grid of data provenance
% gebco('demo5')
%
% SEE ALSO:
%
% https://www.gebco.net/, POLYNESIA
%
% TESTED ON:
%
% 9.0.0.341360 (R2016a)
%
% Last modified by fjsimons-at-alum.mit.edu, 03/12/2020

if ~isstr(lon)
  % Default lon and lat, for good measure, take those from the examples of 
  % https://www.gebco.net/data_and_products/gebco_web_services/web_map_service/
  % for comparison with WMS GetFeatureInfo requests
  defval('lon',-19.979167)
  defval('lat', 50.9625)
  defval('gt',0)
  
  % Check size
  if any(size(lon)~=size(lat)); error('Inconsistent input data size'); end
  
  % Default version
  defval('vers',2014)
  % Default tiling
  defval('npc',20);
  % Default method
  defval('method','nearest');
  % Default server
  defstruct('wms','srv','http://www.gebco.net/data_and_products/gebco_web_services/web_map_service/mapserv?');
  
  % Extra verification, after a long while, have been turning it off!
  defval('xver',0)
  
  % Default outputs
  defval('A',NaN)
  defval('R',NaN)
  
  % If it is a WMS request, skip ahead
  if strcmp(vers,'WMS')
    % Fudge factor for difficult cases
    defval('jig',0)

    % Execute this sequentially if the inputs are manifold
    if length(lon)~=1 || length(lat)~=1
      [zz,lonz,latz]=deal(nan(size(lon)));
      % Should probably take advantage of the parallellization here
      parfor index=1:prod(size(lon))
	if xver==1; disp(sprintf('Making WMS request %3.3i/%3.3i',index,prod(size(lon)))); end
	[zz(index),lonz(index),latz(index)]=gebco(lon(index),lat(index),vers,[],[],xver);
      end
      % And then leave, because you are finished, output
      varns={zz,lonz,latz,A,R,jig};  
      varargout=varns(1:nargout);
      return
    else
      % Make a little bounding box around the request, inspired by the known 2014 resolution
      % latlim and lonlim must be ascending and between what the WMS layer can support
      latlim=lat+[-1 +1]/60/2+(-1)^randi(2)*jig*1e-3;
      lonlim=lon+[-1 +1]/60/2+(-1)^randi(2)*jig*1e-3;
      
      if xver==1
	% Access the data base of all WMS servers, return a WMSLayer object
	wmsl=wmsfind('GEBCO_2014_Grid','SearchField','LayerTitle');
	
	if min(latlim)<min(wmsl.Latlim) ||  max(latlim)>max(wmsl.Latlim) ...
	      || min(lonlim)<min(wmsl.Lonlim) ||  max(lonlim)>max(wmsl.Lonlim)
	  error(sprintf('Latitude and longitude request out of bounds [%g %g] and [%g %g]',...
			wmsl.Latlim,wmsl.Lonlim))
        end
 
	% Supplant the server if you came this far
	wms.srv=wmsl.ServerURL;
	
	% Stuff that could have, but didn't work:

	% [Not needed] Gets more info! And collects a whole bunch of other stuff. See "refine".
	% [wms.inf,wms.inq]=wmsinfo(wmsl.ServerURL);
	% [Not needed] Gets the webmap server capabilities, or do XMLREAD
	% wms.cap=urlread(wms.inq); 
	% [Not needed] Gets the webmap server proxy
	% wms.spr=WebMapServer(wmsl.ServerURL);
	
	% [Not working] Gets a webmap request (template?)
	% wms.mpr=WMSMapRequest(wmsl,wms.spr);
	% [Not working] Direct read, or getting a template request
	% [A,R,wms.mpr]=wmsread(wmsl,'Latlim',latlim,'Lonlim',lonlim,'ImageHeight',2,'ImageWidth',2);
      end
      % Just to make sure for later
      latlim=sort(latlim); lonlim=sort(lonlim);
      
      % Instead, we prepare for making our own damn request,  adding some
      % things, in a new variable wms, that (from gebco.net or from wmsc
      % properties) I know are necessary to make a direct url request
      
      % Coordinate Reference System, see, e.g. https://epsg.io/4326 or http://spatialreference.org/ref/epsg/wgs-84/
      wms.crs='EPSG:4326';
      % Version
      wms.ver='1.3.0';
      % Service
      wms.ser='wms';
      % Info_format
      wms.iff='text/plain';
      
      % Layer titles also 'gebco_south_polar_view', 'gebco_north_polar_view' but those go with EPSG:3031 and different
      % bounding box specifications, see https://www.gebco.net/data_and_products/gebco_web_services/web_map_service/
      % You might think that 'GEBCO_2014_Grid' would be acceptable, but
      % apparently it is not even wmsl.LayerName if you had that from above
      wms.lyr='gebco_latest_2';
      
      % Integer width and height of the map (when requesting a feature, keep it small!)
      wms.pxw=5;
      wms.pxh=5;
      
      % Integer pixel count inside the map where you want to extract the
      % point, X is column measured from upper left map corner and Y ir row
      % measured from upper left corner of the map
      wms.pxx=2;
      wms.pxy=2;
      
      % Make a map request, to take a look...
      if xver==1
	wms.rqt='GetMap';
	wms.fmt='image/png';
	
	% Construct the direct request myself from the gebco.net website example
	wms.mpr=sprintf(...
	    '%srequest=%s&service=%s&crs=%s&version=%s&format=%s&layers=%s&query_layers=%s&BBOX=%s,%s,%s,%s&width=%i&height=%i',...
	    wms.srv,...
	    wms.rqt,wms.ser,wms.crs,wms.ver,wms.fmt,wms.lyr,wms.lyr,...
	    num2str(latlim(1)),num2str(lonlim(1)),num2str(latlim(2)),num2str(lonlim(2)),...
	    wms.pxw,wms.pxh);
	% Get the output, use wmsread only for GetMap request... 
	% first output is image, second output is the raster used
	[A,R,r]=wmsread(wms.mpr);
      end
      
      % For a point, need 'GetFeatureinfo', not 'GetCapabilities' or 'GetMap'
      wms.rqt='GetFeatureInfo';
      
      % Construct the direct request myself from the gebco.net website example
      wms.req=sprintf(...
	  '%srequest=%s&service=%s&crs=%s&version=%s&info_format=%s&layers=%s&query_layers=%s&BBOX=%s,%s,%s,%s&x=%i&y=%i&width=%i&height=%i',...
	  wms.srv,...
	  wms.rqt,wms.ser,wms.crs,wms.ver,wms.iff,wms.lyr,wms.lyr,...
	  num2str(latlim(1)),num2str(lonlim(1)),num2str(latlim(2)),num2str(lonlim(2)),...
	  wms.pxx,wms.pxy,wms.pxw,wms.pxh);
      
      % Get the output, cannot use WMSREAD if it isn't a GetMap request...
      % [wmsu,R,U]=wmsread(wmsr);
      % So, need to parse the output
      wms.out=parse(urlread(wms.req));
      % Get the lon and lat out that you have actually received and
      % the bathymetry at that point, which is what you really wanted
      try 
	lon=sscanf(strtrim(wms.out(4,:)),'x = ''%f''');
	lat=sscanf(strtrim(wms.out(5,:)),'y = ''%f''');
	z=  sscanf(strtrim(wms.out(6,:)),'value_list = ''%i''');
      catch
	% Sometimes there are no data being returned, still the webmap
	% would contain colors (but not values that we can work with, so
	% rejig the request by nudging the requested location a bit! 
	warning(sprintf('Failed lon %f lat %f, nudging requested location along',lon,lat))
	% In which case we force an xver
	[z,lon,lat,~,~,jig]=gebco(lon,lat,vers,[],[],1,jig+1);
      end

      % And then leave, because you are finished, output
      varns={z,lon,lat,A,R,jig};
      varargout=varns(1:nargout);
      return
    end
  end
  
  % Now it's NOT a WMS request but we interpolate our presaved data files

  % Here I will put in Pete's direct solution
  % https://github.com/sirpipat/MERMAIDS_work/blob/master/bathymetry.m

  % Get information on where the data files are being kept
  [mname,sname,up,dn,lt,rt,dxdy,NxNy]=readGEBCO(vers,npc,gt);

  % Grid (0) or pixel (1) registration? See below.
  if strcmp(vers,'1MIN')
    flg=0; else ; flg=1;
  end
  
  % We know that the data were pixel-centered, see at the bottom of this
  % function. So here are the matrix corner pixel centers of the global map.
  c11=[-180+dxdy(1)/2*flg  90-dxdy(2)/2*flg];
  cmn=[ 180-dxdy(1)/2*flg -90+dxdy(2)/2*flg];
  
  % In which of the tiles have we landed? We know that the original global
  % grid was quoted from -180 across in lon and from 90 down in lat..
  cindep=max(1,ceil(    [lon+180]/[360/npc]));
  rindep=max(1,ceil(npc-[lat+90 ]/[180/npc]));
  cindex=unique(cindep);
  rindex=unique(rindep);

  % If you are spread across multiple tiles you're in trouble
  if length(cindex)~=1 || length(rindex)~=1
    % What are the running tile numbers?
    wtile=sub2ind([npc npc],rindep,cindep);
    % What are the unique running tile numbers?
    utile=unique(wtile);
    % Now we recursively apply this algorithm for the unique pairs!
    witsj=cellnan(length(utile),size(lon,1),size(lon,2));
    witsz=    nan(length(utile),1);
    
    % Initialize final output
    z=nan(size(lon));
    
    % Where are those that these unique tiles refer to, and their sizes?
    for index=1:length(utile)
      witsj{index}=wtile==utile(index);
      witsz(index)=sum(sum(witsj{index}));
    end
    
    % Initialize intermediate output
    zz=cellnan([length(utile) 1],witsz(:),ones(length(witsz)));
    
    % Loop over the unique tiles
    parfor index=1:length(utile)
      % If you are doing this right, you NOW end up in unique tiles
      zz{index}=gebco(lon(witsj{index}),lat(witsj{index}),vers,npc,method,xver,[],gt);
    end
    
    % And then stick in the output at the right place
    for index=1:length(utile)
      z(witsj{index})=zz{index};
    end

    % If you hadn't yet by now
    defval('jig',NaN)

    % And then leave, because you are finished, output
    varns={z,lon,lat,A,R,jig};
    varargout=varns(1:nargout);
    return
  end
  
  % So which file should we load? By the way, The stored variable is 'zpc'.
  loadit=fullfile(mname,sprintf('%s_%2.2i_%2.2i',sname,rindex,cindex));
  if xver==1; disp(sprintf('Loading %s',loadit)) ; end
  load(loadit)
  
  % The pixel-centers of the longitudes in the global grid, alternatively:
  lons =linspace(c11(1),         cmn(1),NxNy(1));
  % The pixel-centers of the latitudes in the global grid, alternatively:
  lats =linspace(c11(2),         cmn(2),NxNy(2));
  
  % Being extra careful here
  if xver==1
    lons2=       c11(1): dxdy(1):cmn(1);
    diferm(lons,lons2,9)
    lats2=       c11(2):-dxdy(2):cmn(2);
    diferm(lats,lats2,9)
  end
  
  % Assign a local grid to the data in the tile loaded, see readGEBCO
  latpc=lats(up(rindex):dn(rindex));
  lonpc=lons(lt(cindex):rt(cindex));
  
  % Then interpolate from what you've just loaded to what you want
  % Make sure you use a rule that can extrapolate... if it comes out as a NaN
  z=interp2(lonpc,latpc,zpc,lon,lat,method);
  % Fix any and all of the NaN
  
  % Note that "any" needs a vector input to do this job
  if any(isnan(z(:)))
    % Need a different interpolation, it's an extrapolation in a sense
    % If it's only one number, give a simple reason
    if length(lon)*length(lat)==1
      disp(sprintf('Longitude given %g to %g wanted %g',min(lonpc),max(lonpc),lon))
      disp(sprintf('Latitude given %g to %g wanted %g',min(latpc), max(latpc),lat))
    end
    % This is a bit of a pain, I suppose
    F=griddedInterpolant({flipud(latpc(:)) lonpc(:)},flipud(zpc),method);
    % Re-apply the interpolation for the whole set, make sure there are no surprises
    if xver==1
      zi=F(lat,lon);
      % Compare to the ones that you didn't think needed special attention
      diferm(zi(~isnan(z))-z(~isnan(z)))
      z=zi;
    else
      % Just use the new interpolant
      z=F(lat,lon);
    end
  end
  
  % If you hadn't yet by now
  defval('jig',NaN)

  % Output
  varns={z,lon,lat,A,R,jig};
  varargout=varns(1:nargout);
  
  % Grid documentation for 2008 and 2014 (and 2019) it's pixel-registered.
  % https://www.bodc.ac.uk/data/documents/nodb/301801/#6_format
  %
  % The grid is stored as a two-dimensional array of 2-byte signed integer ...
  %     values of elevation in metres, with negative values for bathymetric ...
  %     depths and positive values for topographic heights.
  %
  % The complete data set gives global coverage, spanning 89° 59' 45''N, 179° ...
  %     59' 45''W to 89° 59' 45''S, 179° 59' 45''E on a 30 arc-second grid. ...
  % It consists of 21,600 rows x 43,200 columns, giving 933,120,000 data points. ...
  % The netCDF storage is arranged as contiguous latitudinal bands. The data ...
  %     values are pixel-centre registered i.e. they refer to elevations at ...
  %     the centre of grid cells.
  %
  % The complete data set gives global coverage. The grid consists of 21,600 ...
  %     rows x 43,200 columns, resulting in 933,120,000 data points. The data ...
  %     start at the Northwest corner of the file and are arranged in latitudinal ...
  %     bands of 360 degrees x 120 points per degree = 43,200 values. The data ...
  %     range eastward from 179° 59' 45'' W to 179° 59' 45'' E. Thus, the first ...
  %     band contains 43,200 values for 89° 59' 45'' N, then followed by a ...
  %     band of 43,200 values at 89° 59' 15'' N and so on at 30 arc second ...
  %     latitude intervals down to 89° 59' 45'' S. The data values are pixel ...
  %     centre registered i.e. they refer to elevations at the centre of grid ...
  %     cells.
  %
  %
  % NOTE: FOR '1MIN' it's grid registered. The complete data set gives global
  % coverage, spanning 90° N, 180° W to 90° S, 180° E on a one arc-minute
  % grid. The grid consists of 10,801 rows x 21,601 columns giving a total of
  % 233,312,401 points. The data values are grid line registered i.e. they
  % refer to elevations centred on the intersection of the grid lines.
  
  % ETOPO1 vs GEBCO2014
  % http://www.oceanpotential.com/pre-assessment/datasets/bathymetry/index.html
  
elseif strcmp(lon,'demo1')
  mn=randij(210); lons=-180+rand(mn)*360; lats=-90+rand(mn)*180;
  tic ; [z1,lon1,lat1]=gebco(lons,lats,2014); tt(1)=toc;
  tic ; [z2,lon2,lat2]=gebco(lons,lats,2008); tt(2)=toc;
  tic ; [z3,lon3,lat3]=gebco(lons,lats,'1MIN'); tt(3)=toc;
  tic ; [z4,lon4,lat4]=gebco(lons,lats,'WMS'); tt(4)=toc;
  
  clf ; ah=krijetem(subnum(2,2)); divs=20;

  axes(ah(1)); hist(z1(:)-z2(:),26); 
  t(1)=title(sprintf('GEBCO 2014 (%4.2f s) minus 2008 (%4.2f s)',tt(1),tt(2)));
  movev(t(1),range(get(ah(1),'ylim'))/divs); grid on; 
  [tx(1),txx(1)]=boxtex('ul',ah(1),sprintf('N = %i',prod(mn)),11,[],1,1.2);
  [tx(2),txx(2)]=boxtex('ll',ah(1),sprintf('min = %4i\nmax = %4i',min(z1(:)-z2(:)),max(z1(:)-z2(:))),11,[],1,1.2,[],2);

  axes(ah(2)); hist(z1(:)-z4(:),26);
  t(2)=title(sprintf('GEBCO 2014 (%4.2f s) minus WMS (%4.2f s)',tt(1),tt(4))); 
  movev(t(2),range(get(ah(2),'ylim'))/divs); grid on
  [tx(3),txx(3)]=boxtex('ll',ah(2),sprintf('min = %4i\nmax = %4i',min(z1(:)-z4(:)),max(z1(:)-z4(:))),11,[],1,1.2,[],2);

  axes(ah(3)); hist(z1(:)-z3(:),26); 
  t(3)=title(sprintf('GEBCO 2014 (%4.2f s) minus 1MIN (%4.2f s)',tt(1),tt(3)));
  movev(t(3),range(get(ah(3),'ylim'))/divs); grid on
  [tx(4),txx(4)]=boxtex('ll',ah(3),sprintf('min = %4i\nmax = %4i',min(z1(:)-z3(:)),max(z1(:)-z3(:))),11,[],1,1.2,[],2);

  axes(ah(4)); hist([lon1(:) ; lat1(:)]-[lon4(:) ; lat4(:)],26); 
  t(4)=title('difference in GEBCO 2014 vs WMS coordinates'); 
  movev(t(4),range(get(ah(4),'ylim'))/divs)
  longticks(ah); ff=findobj('FaceColor','flat'); set(ff(2:4),'FaceColor',grey)
elseif strcmp(lon,'demo2')
  [LO,LA]=meshgrid(-180:3:180,90:-3:-90);
  [z,lon,lat]=gebco(LO,LA); imagefnan([-180 90],[180 -90],z)
elseif strcmp(lon,'demo3')
  c11=[100 -10]; cmn=[140 -40]; spc=1/10;
  [LO,LA]=meshgrid(c11(1):spc:cmn(1),c11(2):-spc:cmn(2));
  ver=2019;
  [z,lon,lat]=gebco(LO,LA,ver); imagefnan(c11,cmn,z,'demmap',[-7473 5731])
  title(sprintf('%i',ver))
elseif strcmp(lon,'demo4')
  % Go grab a float's log from this directory
  dname='/u/fjsimons/MERMAID/serverdata/locdata';
  % Construct te filename from the number given after the 'demo4' input
  defval('lat','P006')
  fname=sprintf('%s_all.txt',lat);
  % Extracts the longitudes and latitudes out of a particular float's log
  % Look up the format codes in VIT2TBL, do not confuse latitude and longitude
  cname=sprintf('awk ''{printf "%%12.6f %%11.6f\\n",$5,$4}'' %s',...
		fullfile(dname,fname));
  % Read, then parse
  [~,lolas]=system(cname); C=textscan(lolas,'%12.6f %11.6f');
  lola=[C{1} C{2}]; clear lolas C
  % Now run the GEBCO identification in some incarnations
  [z2014,lon2014,lat2014]=gebco(lola(:,1),lola(:,2),2014);
  [zWMS ,lonWMS  ,latWMS]=gebco(lola(:,1),lola(:,2),'WMS');
  % And reprint the file to a new destination
  fid=fopen(fullfile(dname,sprintf('%s.bat',pref(fname))),'w+');
  % Look up the format for the bathymetry itself rigt here in GEBCO
  fprintf(fid,'%12.6f %11.6f %12.6f %11.6f %12.6f %11.6f %i %i\n',...
	 [lola' ; lon2014' ; lat2014' ; lonWMS' ; latWMS' ; z2014' ; zWMS'])
  fclose(fid)
elseif strcmp(lon,'demo5')
  % Modification of demo3 to give us provenance also
  % Global view
  %c11=[-180 90]; cmn=[180 -90];
  %[LO,LA]=meshgrid(-180:1/10:180,90:-1/10:-90);
  % c11=[-150 15]; cmn=[-130 -5]; spc=1/20;
  % c11=[-107 15]; cmn=[-97 5]; spc=1/60/2;
  c11=[-100 12]; cmn=[-91 3]; spc=1/60/2;
  [LO,LA]=meshgrid(c11(1):spc:cmn(1),c11(2):-spc:cmn(2));
  % plotcont; hold on; 
  % plot([c11(1) cmn(1) cmn(1) c11(1) c11(1)]+360,[c11(2) c11(2) cmn(2) cmn(2) c11(2)])
  % The actual data
  [z,lon,lat]=gebco(LO,LA,[],[],[],[],[],0); 
  % The provenance data
  [zp,lon,lat]=gebco(LO,LA,[],[],[],[],[],1); 
  subplot(121)
  imagefnan(c11,cmn,z,'demmap',[-7473 5731])
  subplot(122)
  imagefnan(c11,cmn,zp,'demmap',[-7473 5731])
end
