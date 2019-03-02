function varargout=iwt(a,d,an,dn,tipe,nvm,pph,dual)
% [x,xr,ts]=iwt(a,d,an,dn,tipe,nvm,pph,dual)
% 
% Performs a wavelet reconstruction.
% No boundary effects are taken into account.
% Signal need not be of length power-of-two.
%
% INPUT :
%
% a         approximation coefficients (after n lowpass)
% d         details (after each of n highpasses)
% an        number of approximation coefficients at each level
% dn        number of detailed coefficients at each level
% tipe      'Daubechies' or 'CDF'
% nvm       number of vanishing (primal & dual) moments 
% pph       Method of calculation
%           1 Time-domain full bitrate (inefficient);
%           2 Time-domain polyphase (inefficient);  
%           3 Z-domain polyphase (fast, default)
%           4 Lifting
% dual      [For use with GRAPHS only]:
%           0 Return standard wavelets and scaling functions [default]
%           1 Return the dual wavelets and scaling functions
%
% OUTPUT:
%
% x         Cell array with reconstruction at different scales.
%           In Daubechies' notation:
%           x{1}=f^J, the projection at the coarsest scale
%           x{2}=\delta^J, and x{1}+x{2}=f^(J-1)
%           ...
%           x{J}=\delta^1, and x{1}+x{2}+...+x{J}=f^0, i.e. the signal
% xr        The inverse wavelet transform, i.e. sum([x{:}],2)
% ts        Time it took to do this.
%
% EXAMPLES:
%
% iwt('demo1') through iwt('demo6')
%
% COMMENT:
%
% The multiresolution implies that: f^4=f^5+\delta^5, in other words:
% [a,d,an,dn]=wt(x,'CDF',[2 4],5,4); fd5=iwt(a,d,an,dn,'CDF',[2 4],4);
% [a,d,an,dn]=wt(x,'CDF',[2 4],4,4); fd4=iwt(a,d,an,dn,'CDF',[2 4],4);
% difer(fd5{1}+fd5{2}-fd4{1}) % If all is well, which it is.
% 
% See also IWT, WC, MAKEWC, GRAPHS
%
% Last modified by fjsimons-at-alum.mit.edu, 05/22/2012

if ~isstr(a)
  t0=clock;
  
  % Default is the CDF 2/4 construction
  defval('tipe','CDF')
  defval('nvm',[1 1])
  defval('pph',3)
  defval('dual',0)
  if dual==1 & pph~=3
    error('Dual option only supported with the polyphase method')
  end

  % Note that in this reconstruction, we are doing too much work. We are
  % mounting up the multiresolution tree one branch at a time without
  % taking into account the coefficients on adjacent branches until the
  % very end, where we sum the total result. While this guarantees
  % perfect reconstruction in all cases, it is not the most efficient way
  % of doing things. In particular, it implies the lifting algorithm is
  % not run exactly backwards. The result is that integer reconstruction
  % is not possible. For an alternative, however, see the functions
  % FMERMAID and IMERMAID.  

  [h0,f0,P,U,Kp,Ku]=wc(tipe,nvm);

  if dual==1
    [h0,f0]=deal(f0,h0);
  end

  % The number of iterations in the cascade
  n=length(d);
  
  % See Research Notebook IV page 109
  % Reconstruct the approximation coefficients up the branch
  x{1}=sbank(a,h0,f0,P,U,Kp,Ku,'a',n,an,dn,pph);
  % Reconstruct the detail coefficients up the branch
  for index=1:n
    x{n+1-index+1}=sbank(d{index},h0,f0,P,U,Kp,Ku,'d',index,...
			 an,dn,pph);
  end
  xr=sum([x{:}],2);
  ts=etime(clock,t0);
  % disp(sprintf('Synthesis took %8.4f s',ts))
  varnames={'x' 'xr' 'ts'};
  for index=1:nargout
    varargout{index}=eval(varnames{index});
  end
else
  load('noisdopp'); x0=noisdopp(:);
  switch a
   case 'demo1'
    x0=real(dopnoise(500,200,60,10,70,128));
    [a,d,an,dn]=wt(x0,'CDF',[1 1],5); 
    x=iwt(a,d,an,dn,'CDF',[1 1]);
    clf; plot(x{1}+x{2}+x{3}+x{4}+x{5}+x{6}-x0,'o'); ylim(minmax(x0))
    title('Reconstruction error for 5-level CDF(1,1) on Doppler noise')
   case 'demo2'   
    [a,d,an,dn]=wt(x0,'CDF',[1 3],5); 
    x=iwt(a,d,an,dn,'CDF',[1 3]);
    clf; plot(x{1}+x{2}+x{3}+x{4}+x{5}+x{6}-x0,'o'); ylim(minmax(x0))
    title('Reconstruction error for 5-level CDF(1,3) on Doppler noise')
   case 'demo3'   
    [a,d,an,dn]=wt(x0,'CDF',[2 2],5); 
    x=iwt(a,d,an,dn,'CDF',[2 2]);
    clf; plot(x{1}+x{2}+x{3}+x{4}+x{5}+x{6}-x0,'o'); ylim(minmax(x0))
    title('Reconstruction error for 5-level CDF(2,2) on Doppler noise')
   case 'demo4'   
    [a,d,an,dn]=wt(x0,'CDF',[2 4],5); 
    x=iwt(a,d,an,dn,'CDF',[2 4]);
    clf; plot(x{1}+x{2}+x{3}+x{4}+x{5}+x{6}-x0,'o'); ylim(minmax(x0))
    title('Reconstruction error for 5-level CDF(2,4) on Doppler noise')
   case 'demo5'   
    [a,d,an,dn]=wt(x0,'CDF',[4 2],5); 
    x=iwt(a,d,an,dn,'CDF',[4 2]);
    clf; plot(x{1}+x{2}+x{3}+x{4}+x{5}+x{6}-x0,'o'); ylim(minmax(x0))
    title('Reconstruction error for 5-level CDF(4,2) on Doppler noise')
   case 'demo6'   
    [a,d,an,dn]=wt(x0,'CDF',[6 8],5); 
    x=iwt(a,d,an,dn,'CDF',[6 8]);
    clf; plot(x{1}+x{2}+x{3}+x{4}+x{5}+x{6}-x0,'o'); ylim(minmax(x0))
    title('Reconstruction error for 5-level CDF(6,8) on Doppler noise')
   otherwise
    error('No such demo')
  end
end

