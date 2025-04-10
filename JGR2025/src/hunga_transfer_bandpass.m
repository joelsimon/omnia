function [x, h, gap] = hunga_transfer_bandpass(sac, lohi, popas)
% [x, h, gap] = hunga_transfer_bandpass(sac, lohi, popas)
%
% Remove instrument response (counts -> PA) and maybe filter.
%
% Input:
% sac        SAC filename
% lohi       Bandpass corners, or NaN to not bandpaass (def: [2.5 10])
% popas      Bandpass poles and passes (def: [4 1])
%
% Output:
% x          Filtered time series in Pa
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 21-Mar-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

if exist('gap', 'var') == 1
    error('`gap` option not yet coded')

end

% Default bandpass corner frequencies.
defval('lohi', [2.5 10])
defval('popas', [4 1])

% Percentrage of total gap length consider before/after for interpolation.
interpgap_perc = 25;

% Transfer corner frequencies and Tukey taper ratio.
trans_freq20 = [1/10 1/5 5 9.9];
%% This is dumb: should only double upper corners (last two).
trans_freq40 = 2 * trans_freq20;
R = 0.1;

%% This is dumb cont: e.g.,
%% trans_freq40  = trans_freq20;
%% trans_freq40(end-1:end) = 2*trans_freq40(end-1:end);

% `fillgap` buffer percentage (0 means only fill gap with zeros; don't allow
% zeros to extend beyond gap).
fillgap_perc = 0;

% Determine sampling frequency.
[x, h] = readsac(sac);
len_x = length(x);
if len_x ~= h.NPTS
    error('Number of samples mismatch')

end
if efes(h, true) == 20
    trans_freq = trans_freq20;

elseif efes(h, true) == 40
    trans_freq = trans_freq40;

else
    error('Unexpected sampling frequency')

end

% Read gap file and interpolate gaps created during SAC merge.
gap = readgap(sac);
x = interpgap(x, gap, interpgap_perc);

% Remove instrument response (now overwriting x).
x = mermaidtransferx(x, h, trans_freq, [], [], R);

% Bandpass, maybe (no need to re-taper or remove mean/trend; that's already been
% done in `mermaidtransfer`).
if ~isnan(lohi)
    x = bandpass(x, efes(h), lohi(1), lohi(2), popas(1), popas(2));

end

% Read gaps generated during previous sacworkflow merges and fill them with zeros.
x = fillgap(x, gap, 0, fillgap_perc);

% Ensure no goofiness occurred.
if length(x) ~= len_x;
    error('Length of transfered and filtered trace differs from original')

end
