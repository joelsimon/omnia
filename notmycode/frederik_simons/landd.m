function [d2fx,d2hx,lx,lxout]=landd(f0,h0,x)
% [d2fx,d2hx,lx,lxout]=LANDD(f0,h0,x)
%
% Lengths and downsampling arrays
%
% Returns downsampling arrays:
%
% 'd2fx' for the convolution product of x with f0 or h1
% 'd2hx' for the convolution product of x and h0 or f1
%
% and
%
% 'lx' the length of the input array 'x'  
% 'lxout' the length of the output array after filtering
%
% Last modified by fjsimons-at-alum.mit.edu, 03/01/2002

defval('x',1)

lx=length(x);
lf0=length(f0);
lh0=length(h0);

d2fx=logical(1/2-1/2*(-1).^(1:lx+lf0-1))';
d2hx=logical(1/2-1/2*(-1).^(1:lx+lh0-1))';
lxout=lx+lh0+lf0-2;


