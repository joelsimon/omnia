function varargout=graphs(tipe,nvm,dual)
% [phix,phi,wx,w,philim,wlim,err]=GRAPHS(tipe,nvm,dual)
%
% Computes graphs of wavelets and scaling functions.
%
% INPUT:
%
% tipe      'Daubechies', 'CDF', or 'CDFI' [default: 'CDF']
% nvm       Number of vanishing (primal & dual) moments [default: [2 4]]
% dual      0 Return standard wavelets and scaling functions [default]
%           1 Return the dual wavelets and scaling functions
%
% OUTPUT:
%
% phix,phi     The scaling function 
% wx,w         The wavelet function
% philim,wlim  The scaling and wavelet function limits
% err          The orthogonality error
%
% See Mallat (1998), p258
%
% See also: TENLECTURES63, WAVETOUR710, WAVETOUR714
%
% COMMENTS:
%
% To get duals, switch (f0,f1) and (h0,h1)
%
% EXAMPLES:
%
% graphs('demo1') % Plots CDF [2,4]
% graphs('demo2') % Plots CDF [3,5]
% graphs('demo3',nvm,skeel) % for a certain CDF at a certain scale.
% Instructive are at skeel=1: nvm=[1 1], [1 3], [1 5], [2 2], [2 4], [2 6]
% 
% Last modified by fjsimons-at-alum.mit.edu, 01/26/2011

defval('tipe','CDF')

if isempty(strmatch('demo',tipe))
  defval('nvm',[2 4])
  defval('dual',0)
  defval('tol',1e-14)
  
  % Get the filter coefficients
  [h0,f0]=wc(tipe,nvm);
  
  % Number of vanishing moments is equal to (l+1)/2
  [h0,h1,f0,f1,l]=prodco(f0,h0);
  
  if dual==1
    [h0,f0]=deal(f0,h0);
    [h0,h1,f0,f1,l]=prodco(f0,h0);
  end

  % Number of iterations, just pick some number that is high
  %j=7;
  j = 1;
  % Number of points warranted
  N=2^(j+5);
  % See Research Notebook 8 page 5... must make this dependent on the sum
  % of primal and dual moments minus 1.
  
  % Calculate number of coefficients  
  [an,dn,a,d]=dnums(N,h0,f0,j);
  % Specify shift (not on the edge)
  % Needs to be somewhere in the middle
  
  % Influences the position of the return
  n=ceil(an(end)/2);
  
  % Centered unstretched unshifted time axis
  tax=linspace(-floor((N+1)/2)+1,N-floor((N+1)/2),N)/2^j;
  
  % Compute scaling function by inverse wavelet transform
  a(n)=1;
  % Must go by polyphase if using DNUMS
  [x,phi]=iwt(a,d,an,dn,tipe,nvm,3,dual);
  
  % Compute wavelet at scale 2^j and shift n
  d{j}(n)=1;
  [x,w]=iwt(zeros(1,an(end)),d,an,dn,tipe,nvm,3,dual);

  % Figure out the finite support of both
  supp1=find(abs(w)>tol);
  supp2=find(abs(phi)>tol);
  supp=min(supp1(1),supp2(1)):max(supp1(end),supp2(end));
  
  % Time axis where supported
  phix=indeks(tax,supp);
  % Scaling function corrected to zeroth level ('father')
  phi=indeks(phi,supp)*sqrt(2^j);
  % Theoretical support
  philim=[0 l];
  
  % Time axis where supported
  wx=indeks(tax,supp);
  % Wavelet corrected to zeroth level ('mother')
  w=indeks(w,supp)*sqrt(2^j);
  % Theoretical support
  wlim=[(1-l)/2 (l+1)/2];
  
  % Inner product to make sure they're normalized
  err=phi(:)'*w(:);

  % Output
  varns={phix,phi,wx,w,philim,wlim,err};
  varargout=varns(1:nargout);
elseif strcmp(tipe,'demo1')
  % Some thoughts... play with this a bit
   [h0,f0,P,U,Kp,Ku]=wc('CDF',[2 4]);
   skel=9;
   pos=6;
   [an,dn,a,d]=dnums(2^skel*(2+4-1),h0,f0,skel);
   d{skel}(pos)=1; % Use polyphase
   [x,xr,ts]=iwt(a,d,an,dn,'CDF',[2 4],3);
   plot(xr) % Should not be affected by a boundary
elseif strcmp(tipe,'demo2')
   % New example
   tipe='CDF'; n=3; m=5;
   % And the support is the entire signal
   [h0,f0,P,U,Kp,Ku]=wc(tipe,[n m]);
   skel=9;
   pos=6;
   [an,dn,a,d]=dnums(2^skel*(2+4-1+2),h0,f0,skel);
   d{skel}(pos)=1; % Use polyphase
   [x,xr,ts]=iwt(a,d,an,dn,tipe,[n m],3);
   plot(xr) % Should not be affected by a boundary
   [an,dn,a,d]=dnums(2^skel*(2+4-1+2),h0,f0,skel);
   d{skel}(pos+1)=1; % Use polyphase
   hold on
   [x,xr2,ts]=iwt(a,d,an,dn,tipe,[n m],3);
   plot(xr2,'r') % Should not be affected by a boundary
   % And the support is the 2^j*(2+4)
   % And every single shift is 2^j
   % And both should be orthogonal if Daubechies
   xr'*xr2
   hold off
   % But wavelets are orthogonal to scalings if biorthogonal!
   % See Strang p 213.
elseif strcmp(tipe,'demo3')
  defval('nvm',[2 4])
  cdfnvm=nvm;
  defval('dual',3)
  skeel=dual;

  % Compute the functions in time
  [phix,phi,wx,w,philim,wlim,err]=graphs('CDF',cdfnvm,0);

  % Convert to physical space at the required scale
  phix=scale(phix,[0 range(philim)*skeel]);
  wx=scale(phix,[0 range(wlim)*skeel]);
  
  % What is the sampling rate?
  sphi=phix(end)/(length(phix)-1);
  sw=wx(end)/(length(wx)-1);
  
  % Compute an approximation to the spectrum
  fphi=abs(fft(phi)).^2;
  fw=abs(fft(w)).^2;
  
  % With every scale you go up one level
  [faxphi,selektphi]=fftaxis1D(phi,length(fphi),skeel*range(philim));
  [faxw,selektw]=fftaxis1D(w,length(fw),skeel*range(wlim));
  
  % What is the Nyquist?
  nyqs=1/2/sphi;
  nyqw=1/2/sw;

  % What does Matlab think of this? At scale one:
  figure(2); clf
  zwav=sprintf('bior%i.%i',cdfnvm(1),cdfnvm(2));
  Fc=centfrq(zwav,7,'plot');

  blurb=sprintf('Matlabs center at scale %i is %6.3f Hz',...
		skeel,Fc);

  % And at scale skeel: note that we must supply DELTA=1 for this to make
  % sense 
  Fa=scal2frq(skeel,zwav);

  figure(1); clf
  [ah,ha]=krijetem(subnum(2,2));
  axes(ah(1))
  p(1)=plot(phix,phi); 
  t(1)=ylabel('scaling function');
  xl(1)=xlabel(sprintf('time (s) %sx = %8.3f s','\Delta',sphi));
  t(1)=title(zwav);
  axes(ah(2))
  p(2)=plot(wx,w); t(2)=ylabel('wavelet');
  % Plot "center-frequency approximation of this function"
  hold on
  ps(1)=plot(wx,sin(2*pi*Fa*wx),'r');
  hold off
  t(2)=title(blurb);
  
  xl(2)=xlabel(sprintf('time (s) %sx = %8.3f s','\Delta',sw));
  
  axes(ah(3))
  p(3)=plot(faxphi,decibel(fphi(selektphi))); 
  t(3)=ylabel('scaling function');
  xl(3)=xlabel('frequency (Hz)');
  axes(ah(4))
  p(4)=plot(faxw,decibel(fw(selektw))); t(4)=ylabel('wavelet');
  xl(4)=xlabel('frequency (Hz)');

  set(ah(1:2),'xlim',[-1/10 max(phix(end),wx(end))+1/10],...
		      'ylim',[-2 2],'xgrid','on','ygrid','on')
  set(ah(3:4),'xlim',[0 nyqw/6],'ylim',[-20 0],'xgrid','on','ygrid','on')
  
  % Now use Matlab to plot the center frequency of the wavelet
  axes(ah(4))
  hold on; po(2)=plot([Fa Fa],ylim,'r','LineW',2); hold off
else
  error('Specify valid option')
end

