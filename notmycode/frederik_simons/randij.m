function siz=randij(nup)
% siz=RANDIJ(nup)
%
% INPUT:
%
% nup       A certain total number of elements
% 
% OUTPUT:
%
% siz       A nontrivial random size of a matrix with nup elements
%
% Last modified by fjsimons-at-alum.mit.edu, 01/06/2019

defval('nup',180); 

if nup==1
  siz=[1 1];
elseif isprime(nup)
  siz=shuffle([1 nup]);
else
  siz=shuffle(factor(nup)');
end

% Generate a random row/column size
rnp=randi(length(siz)-1);
siz=[prod(siz(1:rnp)) prod(siz(rnp+1:end))];

