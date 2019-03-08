function varargout = wtrmedge(domain, x, tipe, nvm, n, pph, intel, rmedge)
% [a, abe, iabe, d, dbe, idbe, ae1, ae2, de1, de2, an, dn] = ...
%      WTRMEDGE(domain, x, tipe, nvm, n, pph, intel, rmedge)
%
% WTRMEDGE performs a wavelet transform of the input time series 'x'
% and possibly removes samples sensitive to the edges.  See wtedge.m,
% especially Ex3 for a discussion of the process.
%
% Inputs:
% domain        'time-scale' (wt.m) -OR- 'time' (iwt.m)
% x,...,intel   Inputs to wt.m (see there)
% rmedge        logical true to set edges to NaN (def: true)
%               logical false to report their indices, 
%                   but not remove them
%
% Outputs:
% a         Approximation (scaling) coefficients from wt.m 
%                -OR- their partially reconstructed time domain
%                samples from iwt.m, with edges set to NaN
% abe       Scaling coefficient time smear from wtspy.m
% d         Detail (wavelet) coefficients from wt.m -OR-
%               their partially reconstructed time domain 
%               samples from iwt.m, with edges set to NaN
% dbe       Detail coefficient time smear from wtspy.m
% ae1/2*    Scaling indices that see sample 1, lx
% de1/2*    Detail indices that see sample 1, lx
% an/dn     Number of approximation/detail coefficients at each scale
%
% *returned as empty, [], if rmedge is false or if domain = 'time'
%
% For both examples below first run:
%    x = readsac('20180819T042909.08_5B7A4C26.MER.DET.WLT5.sac');
%    plot(x); title('unfiltered seismogram');
%
% Ex1: Plotting partial reconstructions in time
%    [xja, ~, ~, xjd] = WTRMEDGE('time', x, 'CDF', [2 4], 5, 4, 0);
%    figure; plot(xja);
%    title('time domain reconstruction: approximation')
%    figure; plot(xjd{end});
%    title('time domain reconstruction: coarsest details')
%    figure; plot(xjd{1});
%    title('time domain reconstruction: finest details')
%
% Ex2: Plot raw approximation and detail coefficients in time-scale
%      domain (see also plotwtspy.m to map these back to time domain)
%    [a, ~, ~, d] = WTRMEDGE('time-scale', x, 'CDF', [2 4], 5, 4, 0);
%    figure; plot(abs(a));
%    title('time-scale domain: abs. approximation')
%    figure; plot(abs(d{end}));
%    title('time-scale domain: abs. coarsest details')
%    figure; plot(abs(d{1}));
%    title('time-scale domain: abs. finest details')
%
% See also: wt.m, iwt.m, wtspy.m, wtedge.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 16-Jan-2019, Version 2017b

% Wish list: thresholding option.

% Defaults to wt.m.
defval('tipe', 'CDF')
defval('nvm', [2 4])
defval('n', 5)
defval('pph', 4)
defval('intel',0)
defval('rmedge', true)
defval('thresh', 0)

% Sanity.
if ~any(strcmp(domain, {'time', 'time-scale'}))
    error('Specify either ''time'' or ''time-scale'' for input: domain')

end

% Wavelet transform input and find its time domain to time-scale
% domain mapping.
lx = length(x);
[a, d, an, dn] = wt(x, tipe, nvm, n, pph, intel);
[abe, dbe] = wtspy(lx, tipe, nvm, n, pph, intel);

% Compute subspace projection of x at every scale if domain = 'time'.
if strcmp(domain, 'time')
    xj = iwt(a, d, an, dn, tipe, nvm, pph);
    [a, d] = iwtj2wtj(xj);
    
    % Find the inverse (reconstruction) filter lengths.
    [iabe, idbe] = iwtspy(lx, tipe, nvm, n, pph, intel);

else
    iabe = [];
    idbe = [];

end

% Set domain-dependent edges to NaN, maybe.
if rmedge
    [a, d, ae1, ae2, de1, de2] = wtedge(domain, lx, a, abe, iabe, d, dbe, idbe, true);

else
    ae1 = [];
    ae2 = []; 
    de1 = [];
    de2 = [];

end

outargs = {a, abe, iabe, d, dbe, idbe, ae1, ae2, de1, de2, an, dn};
varargout = outargs(1:nargout);
