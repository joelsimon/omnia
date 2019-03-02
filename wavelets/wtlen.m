function [asupp, dsupp, lift] = wtlen(tipe,nvm)
% [asupp, dsupp, lift] = WTLEN(tipe,nvm)
%
% WTLEN returns scaling function and wavelet filter lengths, e.g., the
% support of the father and mother wavelets, respectively.
%
% Currently only returns the length of the PRIMAL wavelets in
% biorthogonal ('CDF', 'CDFI') case.  Does not return DUAL support.
%
% Inputs:
% tipe                 'Daubechies', 'CDF', or 'CDFI'
% nvm                   Number of vanishing (primal & dual) moments 
%
% Outputs:
% a/dsupp              Length of lowpass (highpass) filters
%                      Alternatively, the support of scaling (wavelet) functions
% lift                 1 if lifting steps exist
%                      0 if no stored lifting steps
%
% Ex:
%    [asupp, dsupp, lift] = WTLEN('CDF', [2 4])
%
% See also wt.m, wc.m, prodco.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 12-Jul-2018, Version 2017b

[h0,f0,P,U,Kp,Ku]=wc(tipe,nvm);
asupp=length(h0);
dsupp=length(f0);
lift=(~isempty(P) & ~isempty(U));




