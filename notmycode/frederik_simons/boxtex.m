function varargout=boxtex...
    (posi,handel,index,fs,kees,hitmul,widmul,posxmul,posymul,xver)
% [bcor,tcor]=BOXTEX(posi,handel)
% BOXTEX(posi,handel,index,fs)
% [bhan,than]=BOXTEX...
%   (posi,handel,index,fs,kees,hitmul,widmul,posxmul,posymul,xver)
%
% Puts a smart text box on a plot
%
% INPUT:
%
% posi      'll','lr','ul','ur','um','lm', OR (x,y) coordinates
% handel    Axis handle on which you want to put the textbox
% index     And scalar index into the alphabet, OR, a string with text
% fs        Label font size [default: 20]
% kees      1 Upper-case [default] alphabet will be indexed
%           0 or anything else: Lower case
%           2 Actual numbers instead of letters from the alphabet
% hitmul    Box height multiplier [default: 1]
% widmul    Box width multiplier [default: 1]
% posxmul   Distance from x-axis margin multiplier [default: dataaspectratio]
% posymul   Distance from y-axis margin multiplier [default: dataaspectratio]
% xver      1 Excessive verification, produces some extra output
%           0 None of that
%
% OUTPUT:
%
% bcor      Coordinates of box, and
% tcor      Coordinates of text, OR (depending on the number of INPUT variables)
% bhan      Handle to box, and
% than      Handle to text
% 
% EXAMPLE I:
%
% plot([-2:10],[-4:8])
% boxtex('lr',gca,3,10)
%
% EXAMPLE II:
%
% load clown; image(X)
% b=boxtex('ul',gca,'This is a clown',12)
% set(b,'FaceColor','y','EdgeColor','b')
% 
% See also: LABEL, FILLBOX
%
% Tested on 8.3.0.532 (R2014a) and 9.0.0.341360 (R2016a)
% Last modified by fjsimons-at-alum.mit.edu, 07/05/2017

defval('posi','ll')
defval('index',1)
defval('fs',20)
defval('handel',gca)
defval('kees',1)
defval('hitmul',1)
defval('widmul',1)
defval('xver',0)

axes(handel)
xl=get(handel,'xlim');
yl=get(handel,'ylim');
%rxl=range(xl);
rxl=max(xl)-min(xl);
%ryl=range(yl);
ryl=max(xl)-min(xl);

%-----------------------------------------------
% Specify height and width of box and margins
% in proportion of the FS (default 20)
if isstr(index)
  watis=index;
else
  watis= 'M';
end
a=text(0,0,watis,'FontSize',fs); 
% FJS Note that the EXTENT function is buggy... for huge dataaspectratios
% etc, so you better work in scaled coordinates. Watch if it's off
ext=get(a,'Extent'); delete(a)
[wid,hit]=deal(ext(3),ext(4));
if xver==1
  disp(sprintf('%s Property ''extent'' width and height are %f and %f',...
               upper(mfilename),wid,hit))
end

hit=hit*hitmul;
wid=wid*widmul;
% Margin as ratio of xlim
xmrg=0.025; 
% Margin as ratio of ylim
ymrg=0.025;

% Actually, this needs to be updated depending on the data aspect ratio
da=get(handel,'dataaspectratio'); 
if da(1)>da(2)
  defval('posxmul',da(2)/da(1)*2)
  defval('posymul',1)
elseif da(2)>da(2)
  defval('posxmul',1)
  defval('posymul',da(1)/da(2)*2)
else
  defval('posxmul',1)
  defval('posymul',1)
end
% But not always... FORCE to 1 sometimes

% Make these adjustments
xmrg=xmrg*posxmul;
ymrg=ymrg*posymul;
%-----------------------------------------------

% Define mirroring operators
Mx=[ 1,-1];
My=[-1, 1];

% Define one box in upper right relative to midpoint
mid=boxmid([xl yl]);
% Define Left and Top corner, shifted by MID
X1=[xl(2)-rxl*xmrg-wid yl(2)-ryl*ymrg        ]-mid;
% Define Right and Bottom corner, shifted by MID
X2=[xl(2)-rxl*xmrg         yl(2)-ryl*ymrg-hit]-mid;

if isstr(posi)
  switch posi
   case 'ur'
    [B1,B2]=deal(X1,X2);
   case 'lr'
    [B1,B2]=deal(Mx.*X1,Mx.*X2);
   case 'ul'
    [B1,B2]=deal(My.*X1,My.*X2);
   case 'll'
    [B1,B2]=deal(My.*Mx.*X1,My.*Mx.*X2);
   case 'um'
    [B1,B2]=deal([-wid/2 X1(2)],[wid/2  X2(2)]);
   case 'lm'
    [B1,B2]=deal([-wid/2 -X1(2)],[wid/2  -X2(2)]);
  end      
else
  B1=[posi(1)-wid/2 posi(2)+hit/2];
  B2=[posi(1)+wid/2 posi(2)-hit/2];
  mid=0;
end

% Shift the MID back in
B1=B1+mid;
B2=B2+mid;
bcor=[B1(1) B2(1) B1(2) B2(2)];
tcor=boxmid(bcor);

if nargin>2
  hold on
  bhan=fillbox(bcor,[1 1 1],1);  
  if isstr(index)
    than=text(tcor(1),tcor(2),1.1,index,'FontSize',fs,...
	'HorizontalAlignment','Center');
  else
    if kees>=2
      than=text(tcor(1),tcor(2),1.1,num2str(index),...
		'FontSize',fs,'HorizontalAlignment','Center'); 
    else
      than=text(tcor(1),tcor(2),1.1,letter(index,kees),...
		'FontSize',fs,'HorizontalAlignment','Center'); 
    end
  end
  if nargout
    varargout{1}=bhan;
    varargout{2}=than;
  end
else
    if nargout
      varargout{1}=bcor;
      varargout{2}=tcor;
    end
end


