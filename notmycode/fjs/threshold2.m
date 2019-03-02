function [c,cnz]=threshold2(d,dn,kind,div)
% [c,cnz]=threshold2(d,dn,kind,div)
%
% Thresholds wavelet or scaling coefficients
% by selection ACROSS ALL SCALES (see Mallat p. 437 ff).
%
% INPUT:
%
% d       Coefficient cell array
% dn      Length of the cell array
% kind    'hard' or 'soft' [default]
%         (May need to look into halving T for soft thresholding.)
% div     Divides threshold level, if at all needed [default: 1]
%         Higher values means lower threshold [div=999: no thresholding] 
%
% OUTPUT:
%
% c       Thresholded coefficients
% cnz     Number of nonzero coefficients in every cell
%
% SEE ALSO: THRESHOLD2
%
% Last modified by fjsimons-at-alum.mit.edu, 09/19/2007

defval('kind','soft')
defval('div',1)

if div==999
  c=d;
  cnz=[];
else
  % Mallat Equation 10.53, Donoho and Johnstone 1994

  % On second thought, it's sort of keeping with the philosophy, to use
  % one threshold across ALL scales. Should provide this here, too.
  evrising=cat(1,d{:});
  dloc=median(evrising);
  dscal=median(abs(evrising-dloc))/0.6745;
  T=dscal*sqrt(2*log(sum(dn)))/div;

  for index=1:length(dn)    
    switch kind
     case 'hard'
      dist=abs(d{index})>T;
      c{index}=d{index}.*dist;
      if index==1 ; disp('Hard thresholding using THRESHOLD2') ; end
     case 'soft'
      dist=abs(d{index})-T;
      dist=(dist+abs(dist))/2;
      c{index}=sign(d{index}).*dist;
      if index==1 ; disp('Soft thresholding using THRESHOLD2') ; end
    end
    % Return effective number of (nonzero) coefficients
    cnz(index)=sum(~~dist);
  end
end

