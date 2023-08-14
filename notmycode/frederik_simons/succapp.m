function varargout=succapp(tipe,nvm,nd,x0,pph,intel)
% SUCCAPP(tipe,nvm,nd,x0,pph,intel)
% [a,d,an,dn,x1]=SUCCAPP
% 
% 'tipe': 'Daubechies' or 'CDF'
% 'nvm': Number of vanishing (primal & dual) moments 
% 'nd' : number of decompositions
% 'x0' : signal
%
% Illustrates the use of my functions 'wt' and 'iwt'
% for the SUCCESSIVE approximation of a signal
%
% Only for even-length signals
%
% EXAMPLE:
%

%%%%%%%%%%%%%%%
% Last modified by jdsimon-at-princeton.edu so that the example
% with noisdopp has the correct dimensions 
%
% Notes to self; seems like the plots only work when you don't ask
% for outputs; and it's a little buggy if you supply the last two
% possible inputs (pph, intel) of the functions. The examples below work
%%%%%%%%%%%%%%



% load('noisdopp'); x0=noisdopp(:)';
% x0=real(dopnoise(500,200,60,10,70,128));
% succapp('CDF',[1 1],5,x0)
% succapp('CDF',[1 3],5,x0)
% succapp('CDF',[2 2],5,x0)
% succapp('CDF',[2 4],5,x0)
% succapp('CDF',[4 2],5,x0)

defval('tipe','Daubechies')
defval('nvm',2)
defval('nd',3)
defval('pph',4)
defval('intel',4)
% load('noisdopp');
% defval('x0',noisdopp(:));

tph{1}='Time-Domain Full Rate';
tph{2}='Time-Domain Polyphase';
tph{3}='Z-Domain Polyphase';
tph{4}='Lifting Implementation';

if mod(length(x0),2)
  error('Not for odd-length signals (SBANK)')
end

% Wavelet decomposition
[a,d,an,dn,tsa]=wt(x0,tipe,nvm,nd,pph,intel);
% Compression factor
nuco=cumsum([an(end) fliplr(dn)]);
cf=100*nuco/length(x0);

% Wavelet reconstruction
[x1,tss]=iwt(a,d,an,dn,tipe,nvm,pph,intel);

% Make into matrix
x1=[x1{:}];

if ~nargout
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  figure(1)
  clf
  ah=krijetem(subnum(size(x1,2)+1,1));
  
  mmy=minmax(x0);
  mmx=[1 length(x0)];
  tloc=[mmx(2)-diff(mmx)/25 mmy(1)+diff(mmy)/10];
  tloc2=[mmx(2)-diff(mmx)/25 mmy(1)+3*diff(mmy)/10];

  axes(ah(1))
  p(1)=plot(x0,'Color','k');
  title(sprintf('%s ; %s ; %8.4f s +  %8.4f s',...
		'Successive approximation',...
		tph{pph},tsa,tss))
  yl(1)=ylabel(sprintf('N= %i',length(x0)));
  
  for index=2:length(ah)
    axes(ah(index))
    [p(index),l(index-1),c(index-1)]=...
	plotc(x0,sum(x1(:,1:index-1),2),tloc,...
	      tloc2,cf(index-1));
    yl(index-1)=ylabel(sprintf('N= %i',nuco(index-1)));
  end
  set(ah,'ylim',mmy,'xlim',mmx)
  nolabels(ah(1:end-1),1)
  set([l c],'HorizontalA','Right')
  xlabel(sprintf('%s %i,%i',tipe,nvm))


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  figure(2)
  clf
  subplot(411)
  p(1)=plot(x0,'Color','k');
  axis tight
  title(sprintf('%s ; %s ; %8.4f s +  %8.4f s',...
		'Signal and Wavelet Coefficients',...
		tph{pph},tsa,tss))
  subplot('Position',[0.13 0.11 0.775 0.5781])
  p=dyadplot(x0,a,d,an,dn,[],1);
  ac=colorbar('hor');axes(ac)
  xlabel(sprintf('%s %i,%i',tipe,nvm))
			
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  figure(3)
  clf
  p=dyadplot(x0,a,d,an,dn,[],0);
  t(3)=title(sprintf('%s ; %s ; %8.4f s +  %8.4f s',...
		     'Signal, Scaling and Wavelet Coefficients',...
		     tph{pph},tsa,tss));
  axis tight
  grid on
  set(gca,'TickDir','out','TickLength',[0.02 0.025]/2)
  xlim([1 length(x0)])
  xlabel(sprintf('%s %i,%i',tipe,nvm))
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  figure(4)
  clf
  ah=krijetem(subnum(size(x1,2)+1,1));
  
  mmy=minmax(x0);
  mmx=[1 length(x0)];
  tloc=[mmx(2)-diff(mmx)/25 mmy(1)+diff(mmy)/10];
  tloc2=[mmx(2)-diff(mmx)/25 mmy(1)+3*diff(mmy)/10];
  
  axes(ah(1))
  p(1)=plot(x0,'Color','k');
  title(sprintf('%s ; %s ; %8.4f s +  %8.4f s',...
		'Successive approximation',...
		tph{pph},tsa,tss))
  yl(1)=ylabel(sprintf('N= %i',length(x0)));
  
  x1=fliplr(x1); 
  nuco=cumsum([dn an(end)]);
  cf=100*nuco/length(x0);
  for index=2:length(ah)
    axes(ah(index))
    [p(index),l(index-1),c(index-1)]=...
	plotc(x0,sum(x1(:,1:index-1),2),tloc,...
	      tloc2,cf(index-1));
    yl(index-1)=ylabel(sprintf('N= %i',nuco(index-1)));
  end
  x1=fliplr(x1);
  xlabel(sprintf('%s %i,%i',tipe,nvm))
  set(ah,'ylim',mmy,'xlim',mmx)
  nolabels(ah(1:end-1),1)
  set([l c],'HorizontalA','Right')


%
%  %------------------------------------------
%  disp(['figure(1); print(''-depsc'',''/home/fjsimons/GifPix/EPS/SA-1-' ...
%	'X'')'])
%  disp(['figure(2); print(''-depsc'',''/home/fjsimons/GifPix/EPS/SA-2-' ...
%	'X'')'])
%  disp(['figure(3); print(''-depsc'',''/home/fjsimons/GifPix/EPS/SA-3-' ...
%	'X'')'])
%  disp(['figure(4); print(''-depsc'',''/home/fjsimons/GifPix/EPS/SA-4-' ...
%	'X'')'])
%  


end
%------------------------------------------
varnam={ 'a' 'd' 'an' 'dn' 'x1'};
for index=1:nargout
  varargout{index}=eval(varnam{index});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [p,l,c,yl]=plotc(x0,x1,tloc,tloc2,cf)
p=plot(x1);
l=text(tloc(1),tloc(2),...
    sprintf('Recovered for %.2f%s',...
    100-(rms(x1(:)-x0(:))/rms(x0)*100),mat2str(37)));
c=text(tloc2(1),tloc2(2),...
    sprintf('Compressed to %.2f%s',cf,mat2str(37)));



