function [qual,sncal]=bft(Bl10,F,T,T0,T1,F1,F2,F3,F4)
% [qual,sncal]=bft(Bl10,F,T,T0,T1,F1,F2,F3,F4)
%
% Analyses the time-dependent spectral density of a data segment, 
% calculated by SPECTROGRAM, to come up with a quality indicator
% of the selection
%
% INPUT:
%
% Bl10    10*log10 of the spectral density Ba(UNIT^2/Hz)
% F       Frequency axis (Hz)
% T       Time axis (s)
% T0      Triggered time (s)
% T1      Detriggered time (s)
% F1,...  Frequency-domain boxes given as FN=[f1<f2], N=1->4
%         Time-domain boxes are calculated from the time picks.
%
% OUTPUT:
%
% qual    0 Definitely not a good selection
%         1 Clear waveform, low noise
%         2 Might be a good selection, but not great
% sncal   Estimate of the signal-to-noise ratio
%
% SEE ALSO: BST.
%
% Last modified by fjsimons-at-alum.mit.edu, 05/24/2010

% Intercept undefined time picks (SAC defaults)
if T0==-12345 | T1==-12345
  qual=NaN;
  sncal=0;
  return
end

BOR=Bl10;

defval('F1',[0.3  3]);
defval('F2',[  3  5]);
defval('F3',[  5  7]);
defval('F4',[  7 10]);

TB1=find(T>T0 & T<T1);
TB2=find(T>T1 & T<(T1+(T1-T0)));
TB3=find(T<(T1+(T1-T0)) & T<(T1+2*(T1-T0)));
TB4=find(T>(T0-(T1-T0)) & T<T0);

FB0=find(F>F1(1) & F<F2(2));
FB1=find(F>F1(1) & F<F1(2));
FB2=find(F>F2(1) & F<F2(2));
FB3=find(F>F3(1) & F<F3(2));
FB4=find(F>F4(1) & F<F4(2));

B0=Bl10(FB0,:);
B1=Bl10(FB1,TB1);
B2=Bl10(FB2,TB1);
B3=Bl10(FB3,TB1);
B4=Bl10(FB4,TB1);
B5=Bl10(FB1,TB2);
B6=Bl10(FB2,TB2);
B7=Bl10(FB1,TB3);
B8=Bl10(FB2,TB3);
B9=Bl10(FB1,TB4);

warning off MATLAB:divideByZero
% Take mean and round up - this is important
bmean=[mean(B1(:)) mean(B2(:)) mean(B3(:)) mean(B4(:)) ...
       mean(B5(:)) mean(B6(:)) mean(B7(:)) mean(B8(:)) ...
       mean(B9(:))];
bmean=ceil(bmean);
warning off MATLAB:divideByZero

% Now try to come up with some estimate of S/N ratio
% What is the ratio of the "ideal" triangular pulse to the total?
% Go back to energy definition - 10log10 of the energy ratio
Eall=mean(10.^(B0(:)/10));
Ereg=mean(10.^([B1(:) ; B2(:) ; B5(:)]/10));
sncal=10*log10(Ereg/Eall);

% Almost definite sign of crap; unless shipnoise
% obscures it, or if there are infinite values or NaNs
if any(~isfinite(Bl10(:))) ...
      |  any(isnan(Bl10(:))) ...
      |  (bmean(2)>bmean(1) ...
	  & bmean(3)>bmean(1) ...
	  & bmean(4)>bmean(1))
  bmean=0;
else
  % This might be a positive identification
  if (bmean(6)<=bmean(2) &  bmean(6)<=bmean(1) ...
      & bmean(6)<=bmean(5) & bmean(8)<=bmean(7))
    % But if the onset is unclear, don't take it
    if (bmean(9)>=bmean(1))
      bmean=0;
    else
      bmean=1;
    end
  else
    % Call this the second quality event
    bmean=2;  
  end
end

qual=bmean;

