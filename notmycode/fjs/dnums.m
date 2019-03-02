function [an,dn,a,d]=dnums(N,h0,f0,nd)
% [an,dn,a,d]=DNUMS(N,h0,f0,nd)
%
% Figures out the number of scaling and wavelet
% coefficients (and returns arrays initialized
% with zeros) for a filter pair (h0,f0) and a
% number of iterations 'nd'.
%
% Last modified by fjsimons-at-alum.mit.edu, 05/23/2010

lh0=length(h0);
lf0=length(f0);

for index=1:nd
  if index==1
    an(1)=ceil((N+lh0-1)/2);
    dn(1)=ceil((N+lf0-1)/2);
  else
    an(index)=ceil((an(index-1)+lh0-1)/2);
    dn(index)=ceil((an(index-1)+lf0-1)/2);
  end
end

a=zeros(an(end),1);
for index=1:length(dn)
  d{index}=zeros(dn(index),1);
end

