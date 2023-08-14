function [p,xl,yl,pt01,rgp]=scalogramplot(x,h,tipo,nvm,nd,pph,intel,thresh,div)
% [p,xl,yl,pt01,rgp]=SCALOGRAMPLOT(x,h,tipo,nvm,nd,pph,intel,thresh,div)
%
% Plots a time-scale wavelet representation of a signal
%
% INPUT:
% x, h                   The signal and its header structure, as given,
%                        e.g. from READSAC
% tipo,nvm,nd,pph,intel  Parameters for WT, see there
% thresh                 1 Uses THRESHOLD of the wavelet coefficients
%                        2 Uses THRESHOLD2 on the wavelet coefficients
%                        0 No thresholding at all
% div                    A parameter used by THRESHOLD/THRESHOLD2, see there
% 
% OUTPUT:
%
% p,xl,yl    Axis handle(s) to the plot and labels, respectively
% pt01       Axis handle to any seismic arrival times being plotted
% rgp        Range of all the coefficients plotted
%
% Last modified by fjsimons-at-alum.mit.edu, 05/24/2010

defval('tipo','CDF')
defval('nvm',[2 4])
defval('nd',5)
defval('pph',3)
defval('intel',0)
defval('thresh',2)
defval('div',999)

ochk=1*mod(length(x),2);
% Why don't we simply use wt here?
% [a,d,an,dn,xs]=succapp(tipo,nvm,nd,x(1:end-ochk),pph,intel);
[a,d,an,dn]=wt(x(1:end-ochk),tipo,nvm,nd,pph,intel);
if thresh==1
  disp('Thresholding of the first kind!!')
  [d,dn]=threshold(d,dn,'soft',div);
elseif thresh==2
  disp('Thresholding of the second kind!!')
  [d,dn]=threshold2(d,dn,'soft',div);
end

meth=1;
col='bw';
% Always use the 3-times saturation here
[p,stp,rgp]=dyadplot(x(1:end-ochk),a,d,an,dn,meth,[h.B h.E],col,3);


if h.T0~=-12345 & h.T1~=-12345
  hold on
  yli=ylim;
  pt01=plot(repmat([h.T0 h.T1],2,1),[yli(1) yli(2)],'k--');
  hold off
else 
  pt01=NaN;
end

if meth==1 & col ~= 'bw'
  colormap(flipud(gray(128)))
  caxis([0 3*stp])
end
set(gca,'Xlim',[h.B h.E])
yl=ylabel('Scale');
xl=xlabel('Time (s)');



