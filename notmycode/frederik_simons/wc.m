function [h0,f0,P,U,Kp,Ku]=wc(tipe,nvm)
% [h0,f0,P,U,Kp,Ku]=WC(tipe,nvm)
%
% Gets wavelet filter coefficients from my
% personal data base. Gives the two factors
% of the product filter. Use PRODCO to give full set.
% Also gives the lifting operators.
%
% INPUT:
%
% tipe     'Daubechies' - Orthogonal set from Daubechies
%          'CDF'  - Biorthogonal set from Cohen-Daubechies-Feauveau
%          'CDFI' - Biorthogonal set from Cohen-Daubechies-Feauveau 
%                   with integer scaling
%
% nvm      Number of vanishing moments. 
%          This is a single number for Daubechies but [N M] for CDF.
%
% OUTPUT:
%
% h0,f0     Low- and highpass analysis filters
% P,U       Predict and update lifting steps, vectors or cell arrays
% Kp,Ku     Scaling factors
%
% Note that Haar is Daubechies.p1 or CDF{1,1}.
% Note that the Cubic B-spline is CDF(4,2)
%
% From a database saved by MAKEWC.
%
% Last modified by fjsimons-at-alum.mit.edu, 11/03/2010

defval('tipe','CDF')
defval('nvm',[1 1])

switch tipe
 case 'Daubechies'
  % If you were wrong, and gave two numbers, only takes the first
  nvm=nvm(1);
  load(fullfile(getenv('IFILES'),'WAVELETS','Daubechies'));
  h0=eval(sprintf('Daubechies.p%i',nvm));
  f0=fliplr(h0);
  [P,U,Kp,Ku]=deal([]);
 case 'CDF'
  load(fullfile(getenv('IFILES'),'WAVELETS','CDF'));
  h0=eval(sprintf('CDF.H0{%i,%i}',nvm(1),nvm(2)));
  f0=eval(sprintf('CDF.F0{%i,%i}',nvm(1),nvm(2)));
  if length(CDF.P)>=nvm(1) & length(CDF.U)>=nvm(2)
    P=eval(sprintf('CDF.P{%i}',nvm(1)));
    U=eval(sprintf('CDF.U{%i,%i}',nvm(1),nvm(2)));
    Kp=eval(sprintf('CDF.Kp{%i}',nvm(1)));
    Ku=eval(sprintf('CDF.Ku{%i,%i}',nvm(1),nvm(2)));
  else
    [P,U,Kp,Ku]=deal([]);
  end
 case 'CDFI'
  load(fullfile(getenv('IFILES'),'WAVELETS','CDF'));
  h0=eval(sprintf('CDF.H0{%i,%i}',nvm(1),nvm(2)));
  f0=eval(sprintf('CDF.F0{%i,%i}',nvm(1),nvm(2)));
  load(fullfile(getenv('IFILES'),'WAVELETS','CDFI'));
  if length(CDFI.P)>=nvm(1) & length(CDFI.U)>=nvm(2)
    P=eval(sprintf('CDFI.P{%i}',nvm(1)));
    U=eval(sprintf('CDFI.U{%i,%i}',nvm(1),nvm(2)));
    Kp=eval(sprintf('CDFI.Kp{%i}',nvm(1)));
    Ku=eval(sprintf('CDFI.Ku{%i,%i}',nvm(1),nvm(2)));
  else
    [P,U,Kp,Ku]=deal([]);
  end
 otherwise
  error('Specify filterbank system and save coefficients using MAKEWC!')
end

