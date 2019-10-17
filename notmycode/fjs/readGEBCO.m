function varargout=readGEBCO(vers,npc)
% [mname,sname,up,dn,lt,rt,dxdy,NxNy,vers,npc]=readGEBCO(vers,npc)
%
% Reads a GEBCO bathymetry grid, stored in NETCDF format, and splits it
% into manageable MAT files each containing a chunk.
%
% INPUT:
%
% vers     2014 or '2014' version (30 arc seconds)
%          2008 or '2008' version (30 arc seconds, deprecated)
%         '1MIN' version (1 arc minute, deprecated)
%         'WMS' version (maps to the 2014 parameters)
% npc     sqrt(number) of fitting pieces to split the data into
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
% Last modified by fjsimons-at-alum.mit.edu. 01/25/2019

% Default value
defval('vers',2014)

% sqrt(number) of fitting pieces that we will split the data into
defval('npc',10);

% Make sure you have these various directories and data files
gebcodir=fullfile(getenv('IFILES'),'TOPOGRAPHY','EARTH','GEBCO');

switch vers
 case {2014,'2014','WMS'}
   % The directory name for storage and retrieval
  dname=fullfile(gebcodir,'GEBCO2014');
  % The full path to the 'GEBCO_2014 Grid' source '20150318'
  fname=fullfile(dname,'GEBCO_2014_1D.nc');
  % The root filename under which the pieces will be saved
  sname='GEBCO2014';
 case {2008,'2008'}
   % The directory name for storage and retrieval
  dname=fullfile(gebcodir,'GEBCO2008');
  % The full path to the 'GEBCO_08\ Grid' source '20100927'
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

% Assign spacing, this should be 1/60/2 for 30 arc seconds
dxdy=ncread(fname,'spacing');
NxNy=ncread(fname,'dimension');

% Check BLOCKISOLATE, BLOCKMEAN, BLOCKTILE, PCHAVE, PAULI, etc
% but really, this here is quite efficient already...

% Make the 'across' indices into the global matrix
rt=[0:NxNy(1)/npc:NxNy(1)]; lt=rt+1; 
rt=rt(2:end); lt=lt(1:end-1);

% Make the 'down' indices into the global matrix
dn=[0:NxNy(2)/npc:NxNy(2)]; up=dn+1;
dn=dn(2:end); up=up(1:end-1);

% If no output is requested, will just split the files
if nargout==0
    % Make it if it doesn't exist it
  if exist(mname)~=7;  mkdir(mname); end
  
  % Display some info on the file itself
  ncdisp(fname)
  
  xran=ncread(fname,'x_range');
  yran=ncread(fname,'y_range');
  
  % Read the actual elevation data
  z=ncread(fname,'z');
  
  % Double-check the size
  diferm(length(z)-prod(double(NxNy)))
  
  % Split it into pieces and resave
  zr=reshape(z,NxNy(:)')';
  
  % Double-check the dimensions
  diferm(size(zr,2)-NxNy(1))
  diferm(size(zr,1)-NxNy(2))
  
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


  
