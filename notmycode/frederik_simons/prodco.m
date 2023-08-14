function varargout=prodco(f0,h0)
% [h0,h1,f0,f1,l,lf0,lh0,a0,a1]=PRODCO(f0,h0)
%
% Check normalization of the product filter.
% Returns the full set of (normalized) filter
% bank coefficients and the delay 'l', 
% as well as the length of both input filters.
%
% Note the order of the coefficients! 
% Separated by direction, not branch.
%
% Last modified by fjsimons-at-alum.mit.edu, 06/30/2009

lf0=length(f0);
lh0=length(h0);

% Alternating sign arrays
% Matlab convention of first sample being zero
a0=(-1).^(1:lf0);
a1=(-1).^(2:lh0+1);

P0=conv(f0,h0);
l=(length(P0)-1)/2;
cenval=indeks(P0,ceil((lf0+lh0-1)/2));
if abs(cenval-1)>1e-10
  disp('Filters are now normalized')
  h0=h0/sqrt(cenval);
  f0=f0/sqrt(cenval);
end

% Create synthesis coefficients from the analysis ones:
% conjugate mirror filters with alternating signs to satisfy
% the no-alias condition
% This is not exactly according to Strang and Nguyen p105
% given Matlab's choice of 1 as the first element;
% but you're free to put a minus sign in front of h0 or h1
% as long as you have one.
h1=f0.*a0;
f1=h0.*a1;

% Prepare output
varns={h0,h1,f0,f1,l,lf0,lh0,a0,a1};
varargout=varns(1:nargout);


