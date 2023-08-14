function [p,xl,yl,pt01,rgp,a,d,an,dn]=scaloplot(x,h,tipo,nvm,nd,pph,intel,thresh,div);
% [p,xl,yl,pt01,rgp,a,d,an,dn]=scaloplot(x,h,tipo,nvm,nd,pph,intel,thresh,div);
%
% Modified SCALOGRAMPLOT to return wavelet information
% 
% Plots a time-scale wavelet representation of a signal.  
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
% a          Approximation/scaling coefficients (after 'n' lowpasses)
% d          Details/wavelet coefficients in cell (after successive highpasses)
% an         Number of approximation coefficients at each level
% dn         Number of detailed coefficients at each level
%
% See also SPECTROGRAMPLOT
% 
% Last modified by fjsimons-at-alum.mit.edu, 05/24/2010
% Last modified by jdsimon-at-princeton.edu 2-Mar-2016 to allow
% feeding of empty header

defval('h',makehdr)

ochk=1*mod(length(x),2);
[a,d,an,dn]=wt(x(1:end-ochk),tipo,nvm,nd,pph,intel);
if thresh==1
  disp('Thresholding of the first kind!!')
  [c,cnz]=threshold(d,dn,'soft',div);
elseif thresh==2
  disp('Thresholding of the second kind!!')
  [c,cnz]=threshold2(d,dn,'soft',div);
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


