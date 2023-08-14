function [c,cnz]=threshold(d,dn,kind,div)
% [c,cnz]=threshold(d,dn,kind,div)
%
% Thresholds wavelet or scaling coefficients
% by selection WITHIN EACH SCALE (see Mallat p. 437 ff)
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
% Last modified by jdsimon-at-princeton.edu, 05/07/2019 to remove
%      screen printout

defval('kind','soft')
defval('div',1)

if div==999
  c=d;
  cnz=[];
else
  % Mallat Equation 10.53, Donoho and Johnstone 1994

  for index=1:length(dn)    
    % I think 25.04.2006 that this is good. It is SCALE-DEPENDENT
    % THRESHOLDING where the VARIABILITY at every scale is determined by
    % the MEDIAN absolute deviation from the MEDIAN of the coefficients
    % at every scale. See Johnstone and Silverman.
    % Calculate location estimate
    % Calculate different scale estimate for coefficients at ALL
    % resolution scales 
    % Use median absolute deviation from the median, DJ p 446
    % But they do this only at the smallest scale;
    % We do it at all scales
    % Also, not all coefficients should be shrunk - only the number of
    % vanishing moments... those have an expectation zero
    
    % On second thought, it's sort of keeping with the philosophy, to use
    % one threshold across ALL scales. Should provide this here, too.
    dloc(index)=median(d{index});
    dscal(index)=median(abs(d{index}-dloc(index)))/0.6745;
    T(index)=dscal(index)*sqrt(2*log(dn(index)))/div;
    switch kind
     case 'hard'
      dist=abs(d{index})>T(index);
      c{index}=d{index}.*dist;
      if index==1 ; %disp('Hard thresholding') ;
      end
     case 'soft'
      dist=abs(d{index})-T(index);
      dist=(dist+abs(dist))/2;
      c{index}=sign(d{index}).*dist;
      if index==1 ; %disp('Soft thresholding') ;
      end
    end
    % Return effective number of (nonzero) coefficients
    cnz(index)=sum(~~dist);
  end
end

