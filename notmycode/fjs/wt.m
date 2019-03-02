function [a,d,an,dn,ts,cf]=wt(x,tipe,nvm,n,pph,intel)
% [a,d,an,dn,ts,cf]=wt(x,tipe,nvm,n,pph,intel)
% 
%% Known issue:  short length time series break on abank (e.g.,
%% [a,d] = wt(1,'CDF',[2 4],5,4,0)).  Need error handling.
%
% Forward wavelet transform. This is the main routine.
% No boundary effects are taken into account.
% Signal need not be of length power-of-two.
%
% INPUT:
%
% x      The signal to be analyzed
% tipe   'Daubechies', 'CDF', or 'CDFI'
% nvm    Number of vanishing (primal & dual) moments 
% n      Number of filter bank iterations (levels)
% pph    Method of calculation
%        1 Time-domain full bitrate (inefficient);
%        2 Time-domain polyphase (inefficient);  
%        3 Z-domain polyphase (fast, default)
%        4 Lifting (only for biorthogonal ones)
% intel  1 With integer rounding (for lifting only)
%        0 Without integer rounding
%
% OUTPUT:
%
% a      Approximation/scaling coefficients (after 'n' lowpasses)
% d      Details/wavelet coefficients in cell (after successive highpasses)
% an     Number of approximation coefficients at each level
% dn     Number of detailed coefficients at each level
% ts     How long it took to calculate this (s)
% cf     Compression factors (by the cumulative number of coefficients)
% 
% Returns cell arrays with the detail coefficients.
%
% See also IWT, WC, MAKEWC
%
% Last modified by fjsimons-at-alum.mit.edu, 05/22/2012
% Last modified in Ver. 2017a by jdsimon@princeton.edu, 15-Jan-2019

% SHOULD BUILD IN A CORRECTION FOR EDGE-EFFECTS a la Mallat Book, 1dt
% ed. p290. But see the whole cubed-sphere business. To verify:
% Check polynomial cancellation. Check perfect reconstruction. Check norm
% preservation. 

% jdsimon changelog --
%
% 14-Feb-2019: Moved defval(x) to rand.
%
% 15-Jan-2019: Added error throw if pph=4 and tipe='Daubechies'
%
% 03-Sep-2018: Noted that with short time series, long filters, and
% many scales of decomposition abank fails.  E.g.,
%
% wt(1,'CDF',[2 4],5,4,0)
%
% Needs updated error handling.

t0=clock;

% % Default is the 5-scale CDF 2/4 construction on Doppler noise
% defval('x',real(dopnoise(500,200,60,10,70,128)))
defval('x', rand(1, 1000));
defval('tipe','CDF')
defval('nvm',[2 4])
defval('n',4)
defval('pph',3)
defval('intel',0)

% JDS edit.
if pph == 4  && strcmp(tipe,'Daubechies')
    error('pph = 4 (lifting) only allowed for tipe = ''CDF''')

end

x=x(:);

if intel==1 
    disp('Integer-to-integer reconstruction not possible with IWT')
  if pph~=4
    disp('Integer-to-integer only available for lifting algorithm')
    intel=0;
  end
end
if mod(length(x),2)
  warning('Odd length array reconstruction not possible with IWT')
end

% Get the wavelet coefficients
[h0,f0,P,U,Kp,Ku]=wc(tipe,nvm);

% If using integer lifting, must have scale factors as lifting steps
if intel==1 & ~strcmp(tipe,'CDFI')
  disp('No precomputed lifting steps stored; attempt to reconstruct') 
  % Here we now need to absorb the scaling as four more lifting steps
  % If indeed Ku equals 1/Kp, see Daubechies and Sweldens, 1998, Delft
  % book p 145
  % disp('Extra lifting steps, may use CDFI instead')
  % This only works so far for those transforms that have only one
  % lifting step... not really worth making more general at this point.
  Pc=P; Uc=U;
  clear P U
  P{1}=Pc;
  U{1}=Uc;
  P{2}=-1;
  P{3}=Ku;
  U{2}=Kp-1;
  U{3}=Kp-Kp^2;
  % Verify that this whole thing works here:
  difer([Kp 0 ; 0 Ku]-[1 U{3} ; 0 1]*[1 0 ; -P{3} 1]*...
	[1 U{2} ; 0 1]*[1 0 ; -P{2} 1]);
  Ku=1;
  Kp=1;
end

% Need to figure out how to do this recursively...
a=x(:);

% This is the iteration on the lowpass branch
try
    for index=1:n
        [a,d{index}]=abank(a,h0,f0,P,U,Kp,Ku,pph,intel);
        an(index)=length(a);
    end
catch ME
    
    warning(['\Input x may be too short to iterate lowpass branch to ' ...
             '%i scales.\nNeeds updated error handling.\nPaused wt.m for ' ...
             'inspection.'], n)
    keyboard
end
    
% Know in advance what the lengths are; except the top level,
% which you'll have to assume is EVEN and given by 2*dn{1}.
dn=cellfun('size',d,1);

ts=etime(clock,t0);
%disp(sprintf(' Analysis took %8.4f s',ts))

% Cumulative compression rate ending at 100 
nuco=cumsum([an(end) fliplr(dn)]);
cf=100*nuco/length(x);

