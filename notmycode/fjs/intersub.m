function varargout=intersub(x,xi,y)
% c=INTERSUB(x,xi)
% [yi,P]=INTERSUB(x,xi,y)
%
% Interpolation subdivision for (among other things)
% boundary implementation of fast wavelet transform
% by the lifting scheme.
%
% Can (only) use this to find prediction coefficients of
% increasingly higher-order INTERPOLATING wavelet
% transforms with Deslauriers-Dubuc SCALING FUNCTIONS.
%
% USE I: Give locations only
% For a set of points 'x' and a location 'xi'
% finds the length(x) filter coefficients
% necessary for the lifting wavelet transform
% with polynomial cancellation of order length(x)-1.
%
% USE II: Give locations and values
% Returns the interpolated values and the coefficients of
% the polynomial. Like POLYFIT/POLYVAL.
%
% Then, later on, if you want to compute yi given xi
% from x and y, all you do is c(:)'*y(:) and you've got it.
% This works even outside the domain of x, unlike INTERP1.
%
% If the samples spacings are integer, and the relative location
% of xi with respect to its neighbours is unchanged, you only need
% to calculate these coefficients once and the "stencil" can be
% used subsequently in all levels of successive refinement.
%
% Related terms: refinement, pyramid scheme, Neville's
% algorithm, Deslauriers-Lubuc scheme.
%
% Example I: (from Fernandez et al. (1996) Proc. SPIE 2825)
%
% x=[1 3 5 7];  % Figure 4 and Table 2
% intersub(x,8) % (exterior point)
% intersub(x,6) % 
% intersub(x,4) % (Case a; interior point)
% intersub(x,2) % (Case b; boundary point)
% intersub(x,0) % (exterior point)
%
% Example II:
%
% x=[1 3];
% intersub(x,2) % (Case a; regularly sampled)
% x=[1.4 2.8];
% intersub(x,2) % (Case a; regularly sampled)
%
% Example III:
%
%% The so-called 4-point scheme "stencil" is given by
% c=intersub([1 3 5 7],4)
%
% Example IV:
%
% x=sort(rand(4,1)*10);
% y=polyval([4 -3 1 0],x);
% xi=linspace(min(x),max(x),100);
% [yi,P]=intersub(x,xi,y);
% plot(x,y,'s-'); hold on
% plot(xi,yi,'b-')
% xii=mean(x);
% c=intersub(x,xii);
% hold on
% plot(xii,c(:)'*y(:),'*')
% hold off
%
% Example V:
%
% Note that by definition, the interpolated curve goes through the sample
% point: intersub([1 2 3 4],2) is what you expect in that case.
%
% Last modified by fjsimons-at-alum.mit.edu, 2/27/2003


if nargin==2
  % Only work with locations and calculate interpolating coefficients
  % Note that this is NOT Neville's algorithm... that'd work too, I guess.
  c=xi.^[length(x)-1:-1:0]*inv(vander(x(:)'))*eye(length(x));
  varargout{1}=c;
elseif nargin==3
  % This is really nothing but POLYFIT and POLYVAL
  % Work with locations and values, and calculate interpolated
  % values and polynomial coefficients. Except POLYFIT inverts the
  % Vandermonde matrix by least squares, in case it is tough, I guess.
  P=inv(vander(x(:)'))*y(:);
  varargout{2}=P(:)';
  if length(xi(:))==1
    yi=P(:)'*(xi.^[length(x)-1:-1:0])';
  else
    yi=polyval(P,xi);
  end
  varargout{1}=yi(:);
end

