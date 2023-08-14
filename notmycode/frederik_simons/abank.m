function [a,d]=abank(x,h0,f0,Pa,Ua,Kp,Ku,pph,intel)
% [a,d]=ABANK(x,h0,f0,Pa,Ua,Kp,Ku,pph,intel)
%
% Filter bank: ANALYSIS, one iteration.
% No boundary effects are taken into account.
% Signal need not be of length power-of-two.
%
% INPUT:
% 
% x             input signal
% h0,f0         the filter coefficients
% Pa,Ua,Kp,Ku   the lifting operators
% pph           1 Time-domain full bitrate (inefficient);
%               2 Time-domain polyphase (inefficient);  
%               3 Z-domain polyphase (fast, default)
%               4 Lifting
%
% OUTPUT:
%
% a             Approximation (lowpass, scaling) coefficients
% d             Detail (highpass, wavelet) coefficients
%
% See also SBANK, FBANK, WT, IWT, WTLIFT, SUCCAPP
%
% Last modified by fjsimons-at-alum.mit.edu, 05/22/2012

defval('pph',3)
defval('intel',0)
defval('deb',0) % Debugging output

if intel==1 & pph~=4
  disp('Integer-to-integer only available for lifting algorithm')
  intel=0;
end

if pph~=4
  % Get filter coefficients
  [h0,h1,f0,f1,l,lf0,lh0]=prodco(f0,h0);
  % Get downsampling arrays.
  [d2fx,d2hx,lx,lxout]=landd(f0,h0,x);
  % Get z-domain polyphase representation
  [PA,PS,I,...
   H0even,H0odd,H1even,H1odd,...
   F0even,F0odd,F1even,F1odd]=polyphase(f0,h0);
end

switch pph
 case 4
  if deb==1; disp('Lifting implementation'); end
  % SPLIT -----------------------------------------
  d=x(even(x)); % Even
  a=x(~even(x)); % Odd

  % Number of lifting steps------------------------
  M=1;
  
  if iscell(Pa); M=length(Pa); end

  % Loop over lifting steps------------------------
  for index=1:M
    if deb==1; disp(sprintf('Lifting step %i',index)) ; end
    if iscell(Pa)
      P=Pa{index};
      U=Ua{index};
    else
      P=Pa;
      U=Ua;
    end
    Pl=length(P);
    Ul=length(U);

    % Initialize Lp and Lu with empties for the debugging message
    [Lp,Lu]=deal([]);

    % HERE YOU COULD CHECK IF YOU HAVEN'T RUN INTO AN EDGE, BECAUSE IF
    % YOU DO, THE NUMBER L WON't BE VALID ETC.

    % PREDICT ---------------------------------------
    % The last condition only when the prediction operator
    % is of length unity and when the a's and d's have
    % unequal length. Prediction based on odds (left neighbor).
    for l=ceil(Pl/2):ceil(length(x)/2)-floor(Pl/2)-(Pl==1)*mod(length(x),2)
      Lp=l+[(1-ceil(Pl/2)):1:floor(Pl/2)];
      if intel==1; d(l)=d(l)-floor(P(:)'*a(Lp)+1/2); end
      if intel==0; d(l)=d(l)-P(:)'*a(Lp); end
    end
    if deb==1
      disp(sprintf(['Last Predict %i /%i with ',...
		    repmat('%i ',size(Lp)),'/%i'],...
		   l,length(d),Lp,length(a)))
    end
  
    % UPDATE ----------------------------------------
    for l=1+floor(Ul/2):floor(length(x)/2)-ceil(Ul/2)+1
      Lu=l-[floor(Ul/2):-1:(1-ceil(Ul/2))];
      if intel==1; a(l)=a(l)+floor(U(:)'*d(Lu)+1/2); end
      if intel==0; a(l)=a(l)+U(:)'*d(Lu); end
    end
    
    if deb==1
      disp(sprintf(['Last Update  %i /%i with ',...
		    repmat('%i ',size(Lu)),'/%i'],...
		   l,length(a),Lu,length(d)))
    end
  end

  % SCALE -----------------------------------------
  d=d*Ku;
  a=a*Kp;  
 case 3
  if deb==1; disp('Z-domain polyphase implementation'); end
  Xeven=x(even(x));
  Xodd=x(~even(x));
  % Always need to offset them, but, depending on the length of the
  % input series, may need to add an extra zero or not.
  lh0lxe=length(H0even)+length(Xeven);
  lh0lxo=length(H0odd)+length(Xodd);
  lh1lxe=length(H1even)+length(Xeven);
  lh1lxo=length(H1odd)+length(Xodd);
  
  % This is tricky business, but it works
  % -> for even- and odd length signals
  % -> for even- and odd length filters
  a=repmat(0,max(lh0lxe,lh0lxo-1),1);
  d=repmat(0,max(lh1lxe,lh1lxo-1),1);
  
  a(2:lh0lxe)=conv(H0even(:),Xeven(:));  
  a(1:lh0lxo-1)=a(1:lh0lxo-1)+conv(H0odd(:),Xodd(:));
  
  d(2:lh1lxe)=conv(H1even(:),Xeven(:));
  d(1:lh1lxo-1)=d(1:lh1lxo-1)+conv(H1odd(:),Xodd(:));
 case 2
  if deb==1; disp('Time-domain polyphase implementation'); end
  % Filter Toeplitz matrices
  % Size of H0 is (lx+lh0-1) by (lx)
  % Size of H1 is (lx+lf0-1) by (lx)
  % and element (1,1) is h0(1)
  H0=convmtx(h0(:),lx);
  H1=convmtx(h1(:),lx);
  % Downsample: delete rows: keep these
  AL=H0(d2hx,:);
  AB=H1(d2fx,:);
  % Polyphase form
  % Split signal in even and odd
  % Note that this is dependent on your first sample:
  % do you call it x(0) or x(1)
  % The Matlab convention differs from the others,
  % so our even is their odd.
  X=[x(even(x)) ; x(~even(x))];
  % Construct the polyphase ANALYSIS matrix (Toeplitz)
  H0even=AL(:,even(x));
  H0odd=AL(:,~even(x));
  H1even=AB(:,even(x));
  H1odd=AB(:,~even(x));
  % Implement filters by multiplication
  % This is the polyphase applied to the samples in the time domain
  PA=[H0even H0odd ;
      H1even H1odd];
  ad=PA*X;
  % This is the intermediate vector; split up if you want
  a=ad(1:sum(d2hx));
  d=ad(sum(d2hx)+1:end);
 case 1
  if deb==1; disp('Toeplitz implementation'); end
  % Filter and downsample
  H0=convmtx(h0(:),lx);
  H1=convmtx(h1(:),lx);
  AL=H0(d2hx,:);
  AB=H1(d2fx,:);
  a=AL*x(:);
  d=AB*x(:);
 otherwise
  error('Specify valid option')
end


