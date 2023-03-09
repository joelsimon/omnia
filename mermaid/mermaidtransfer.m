function [x, h, xraw] = mermaidtransfer(s, fl, sacpz, rflexa, R)
% [x, h, xraw] = MERMAIDTRANSFER(s, fl, sacpz, rflexa, R)
%
% Remove MERMAID instrument response.
%
% Requires `transfer` and its dependencies, from Alex Burky's "rflexa" github -
% https://github.com/alexburky/rflexa/
%
% Input:
% s         SAC filename
% fl        1x4 array of array of corner freqs for deconvolution
%               (def: [1/10 1/5 fs/4 fs/2], where `fs` is sampling freq)
% sacpz     SACPZ filename (def: $MERMAID/response/MH.pz)
% rflexa    Local path to Alex Burky's cloned rflexa repository
%               (def: $RFLEXA; from https://github.com/alexburky/rflexa/)
% R         Tukey taper ratio (to be applied before removing the response),
%               or NaN if tapering not requested (def: 0.1)
%
% Output:
% x         SAC trace data with instrument response removed
% h         SAC header
% xraw      Raw SAC data
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 06-Mar-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults
defval('fl', []) % defaulted later based on sampling freq
defval('sacpz', fullfile(getenv('MERMAID'), 'response', 'MH.pz'))
defval('rflexa', fullfile(getenv('RFLEXA'), 'transfer', 'matlab'))
defval('R', 0.1)

%% <Temporary solution until I decide how to integrate Alex Burky's code
addpath(rflexa)
%% Temporary/>

% Read SAC file and determine default frequency limits based on sampling
% frequency.
[xraw, h] = readsac(s);
fs = 1/h.DELTA;
if isempty(fl)
    % These are very important; must be in pass band?
    fl = [1/10 1/5 fs/4 fs/2];

end

% Precondition data for instrument response removal.
x = detrend(xraw, 'constant');
x = detrend(x, 'linear');
if ~isnan(R)
    x = x .* tukeywin(length(x), R);

end

% Actually remove the instrument response (SAC-software equivalent `transfer`)
x = transfer(x, h.DELTA, fl, 'mermaid', sacpz, 'sacpz');

%% <Temporary solution until I decide how to integrate Alex Burky's code
rmpath(rflexa)
%% Temporary/>
