function varargout=readGEBCO(vers,npc,gt)
% [mname,sname,up,dn,lt,rt,dxdy,NxNy,vers,npc]=readGEBCO(vers,npc,gt)
%
% Reads a GEBCO bathymetry grid, stored in NETCDF format, and splits it into
% manageable MAT files each containing a chunk.
%
% INPUT:
%
% vers     2019 or '2019' version (15 arc seconds)
%          2014 or '2014' version (30 arc seconds)
%          2008 or '2008' version (30 arc seconds, deprecated)
%          '1MIN' version (1 arc minute, deprecated)
%          'WMS' version (maps to the 2014 parameters)
% npc      sqrt(number) of fitting pieces to split the data into
% gt       0 the actual data [default] 
%          1 the source identifier grid (SID), if applicable
%          2 the data type identifier grid (TID), if applicable
%
% OUTPUT: IF NONE REQUESTED, WILL READ, SPLIT & SAVE THE FILES,
% OTHERWISE, IT WILL ASSUME THAT THAT HAS BEEN DONE AND RETURNS:
% 
% mname    The directory name where the split *.mat files are kept
% sname    The root filename under which the pieces are being kept
% up,dn    The top/down (first dimension) indices into the global grid for every tile
% lt,rt    The left/right (second dimension) indices into the global grid for every tile
% dxdy     The grid spacing in decimal degrees
% NxNy     The size of the complete global grid 
% vers     The version used, a replicate of what's input, or a default 
% npc      The number of pieces used, a replicate or the default
% 
% SEE ALSO:
%
% https://www.gebco.net/
%
% TESTED ON:
%
% 9.0.0.341360 (R2016a)
%
% Last modified by fjsimons-at-alum.mit.edu. 03/12/2020

% Default values
defval('vers',2014)
defval('gt',0)

% sqrt(number) of fitting pieces that we will split the data into
defval('npc',20);

% Make sure you have these various directories and data files
gebcodir=fullfile(getenv('IFILES'),'TOPOGRAPHY','EARTH','GEBCO');

switch vers
 case {2019,'2019'}
  % The directory name for storage and retrieval
  dname=fullfile(gebcodir,'GEBCO2019');
  % The full path to the 'GEBCO_2019 Grid'  doi: 10/c33m
  fname=fullfile(dname,'GEBCO_2019.nc');
  % The root filename under which the pieces will be saved
  sname='GEBCO2019';
 case {2014,'2014','WMS'}
  % The directory name for storage and retrieval
  dname=fullfile(gebcodir,'GEBCO2014');
  % The full path to the 'GEBCO_2014 Grid' source '20150318'
  fname=fullfile(dname,'GEBCO_2014_1D.nc');
  % The root filename under which the pieces will be saved
  sname='GEBCO2014';
  if gt>0; 
    fname=fullfile(dname,'GEBCO_2014_SID_2D.nc');
    sname='GEBCO2014_SID';
  end
 case {2008,'2008'}
  % The directory name for storage and retrieval
  dname=fullfile(gebcodir,'GEBCO2008');
  % The full path to the 'GEBCO_08 Grid' source '20100927'
  fname=fullfile(dname,'gebco_08.nc');
  % The root filename under which the pieces will be saved
  sname='GEBCO_08';
 case '1MIN'
  % The directory name for storage and retrieval
  dname=fullfile(gebcodir,'GEBCO1MIN');
  % The full path to the 'GEBCO One Minute Grid' source '233312401'
  fname=fullfile(dname,'GRIDONE_1D.nc');
  % The root filename under which the pieces will be saved
  sname='GRIDONE';
 otherwise
  error('Specify the proper version of the GEBCO grid')
end

% The directory in which the pieces will be saved
mname=fullfile(dname,sprintf('MATFILES_%i_%i',npc,npc));

% The metadata save file so you can get rid of the NETCDF file
hname=sprintf('%s.mat',pref(fname));

defval('varname','z')

% I need to remake the 1MIN files, but never mind for now
if exist(hname)~=2
  % Display some info on the file itself
  ncdisp(fname)

  if gt==0
    if strfind(fname,'2019')
      gt0=ncinfo(fname); 
      %gt0.Variables(1:3).Name
      NxNy=cat(2,gt0.Dimensions(1:2).Length);
      dxdy=[360 180]./NxNy;
      % varname=gt0.Variables(3).Name
    else
      % Assign spacing, this should be 1/60/2 for 30 arc seconds
      % gt0=ncinfo(fname); gt0.Variables(4:5).Name
      % xran=ncread(fname,'x_range');
      % yran=ncread(fname,'y_range');
      dxdy=ncread(fname,'spacing');
      NxNy=ncread(fname,'dimension');
    end
  else
    gt1=ncinfo(fname);
    % NxNy=cat(1,gt1.Dimensions(2:-1:1).Length);
    NxNy=gt1.Variables(1).Size(:);
    dxdy=[360 ; 180]./NxNy;
  end

  % Check BLOCKISOLATE, BLOCKMEAN, BLOCKTILE, PCHAVE, PAULI, etc
  % but really, this here is quite efficient already...

  % Make the 'across' indices into the global matrix
  rt=[0:NxNy(1)/npc:NxNy(1)]; lt=rt+1; 
  rt=rt(2:end); lt=lt(1:end-1);

  % Make the 'down' indices into the global matrix
  dn=[0:NxNy(2)/npc:NxNy(2)]; up=dn+1;
  dn=dn(2:end); up=up(1:end-1);
  save(hname,'up','dn','lt','rt','dxdy','NxNy')
else
  load(hname)
end

% If no output is requested, will just split the files
if nargout==0
  % Make it if it doesn't exist it
  if exist(mname)~=7; mkdir(mname); end

  if gt==0
    
    % Split it into pieces and resave
    if strfind(fname,'2019')
      varname='elevation';
      zr=flipud(ncread(fname,varname)');
    else
      % Read the actual elevation data
      z=ncread(fname,varname);
      % Double-check the size
      diferm(length(z)-prod(double(NxNy)))
      % Reformat
      zr=reshape(z,NxNy(:)')';
      clear z
    end
  
    % Double-check the dimensions
    diferm(size(zr,2)-NxNy(1))
    diferm(size(zr,1)-NxNy(2))
  elseif gt==1
    % Read the actual data
    zr=flipud(ncread(fname,'sid')');
    % You could read longitude and latitude directly also...
  end
  
  % Segment patches and resave
  for rindex=1:npc
    for cindex=1:npc
      % Watch this indexing, it will serve us again in GEBCO
      zpc=zr(up(rindex):dn(rindex),lt(cindex):rt(cindex));
      % Compare with the equivalent BLOCKISOLATE call
      % zpcp=blockisolate(zr,double([NxNy(2) NxNy(1)])/npc,1);
      % Save those pieces to individual files
      save(fullfile(mname,sprintf('%s_%2.2i_%2.2i',sname,rindex,cindex)),'zpc')
      % Talk about progress
      display(sprintf('Saving tile %3.3i / %3.3i',(rindex-1)*npc+cindex,npc*npc))
    end
  end
else
  % If you ask for output you just get some basic information back
  varns={mname,sname,up,dn,lt,rt,dxdy,NxNy,vers,npc};
  varargout=varns(1:nargout);
end
