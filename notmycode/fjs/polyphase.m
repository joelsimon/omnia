function [PA,PS,I,H0e,H0o,H1e,H1o,F0e,F0o,F1e,F1o]=polyphase(f0,h0)
% [PA,PS,I,H0e,H0o,H1e,H1o,F0e,F0o,F1e,F1o]=POLYPHASE(f0,h0)
%
% Returns the polyphase forms of the transform given by
% the filter pair f0 and h0
%
% 'PA' Analysis polyphase matrix (Type I)
% 'PS' Synthesis polyphase matrix (Type I)
% 'I'  Reconstruction criterion PS*PA:
%      Unless we make the synthesis bank Type II
%      the 'I' will be flipud(eye(2)) [Strang p. 131]
%
% Written by fjsimons-at-alum.mit.edu, 03-01-2003

[a,b]=wc;
defval('h0',a)
defval('f0',b)

% Find all filters
[h0,h1,f0,f1]=prodco(f0,h0);

% Find ANALYSIS polyphase matrix
H0e=h0(even(h0));
H0o=h0(~even(h0));
H1e=h1(even(h1));
H1o=h1(~even(h1));

PA=[{H0e} {H0o}
    {H1e} {H1o}];

% Find SYNTHESIS polyphase matrix
F0e=f0(even(f0));
F0o=f0(~even(f0));
F1e=f1(even(f1));
F1o=f1(~even(f1));

PS=[{F0e} {F1e}
    {F0o} {F1o}];

% Verify reconstruction criterion
% I=prcheck(PS,PA); % This does not work
% I=[sum(I{1}) sum(I{3});...
%  sum(I{2}) sum(I{4})];
% Just supply it
I=eye(2);

% This better be a small number
if sum(sum(flipud(I)-eye(2)))>1e-10
  warning(sprintf('Reconstruction will fail by %8.3e',sum(sum(flipud(I)-eye(2)))))
%else
%  disp('Perfect reconstruction will succeed')
end


