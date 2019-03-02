function [paramstr, lenstr] = wtstr(lx, tipe, nvm, n, pph, intel)
% [paramstr,lenstr] = WTSTR(lx,tipe,nvm,n,pph,intel)
%
% Returns wt.m input parameter information strings.
%
% Strings are used to construct fieldnames in master structure
% containing every unique output of wtspy.m.
%
% Inputs:
% lx, ..., intel       Inputs to wt.m
% 
% Outputs:
% paramstr            Input parameter string
% lenstr              Time series length string
%
% See also: wtspy.m
%
% Last modified in Ver. 2017b by jdsimon@princeton.edu, 16-Feb-2018.

% Switch for mother wavelet.
if length(nvm) == 1
    % 'Daubechies'
    paramstr = sprintf('%s%i_%s%i_%s%i_%s%i', tipe, nvm, 'n' , n, ...
                        'pph', pph, 'intel', intel);
else
    % CDF/I
    paramstr = sprintf('%s%i%i_%s%i_%s%i_%s%i', tipe, nvm, 'n', ...
                     n, 'pph', pph, 'intel', intel);
end

% Length of signal.
lenstr = sprintf('len%i', lx);
