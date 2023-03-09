function [x, h] = mermaidtransferx(x, h, fl, sacpz, rflexa, R)
% [x, h] = MERMAIDTRANSFERX(x, h, fl, sacpz, rflexa, R)
%
% `mermaidtransfer`, but taking time-series data (`x`) and SAC header (`h`) as input.
% (NB, `xraw` from there is not returned here; here that is just the input `x`)
%
% See also (docstring/defaults): mermaidtransfer
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
fs = 1/h.DELTA;
if isempty(fl)
    % These are very important; must be in pass band?
    fl = [1/10 1/5 fs/4 fs/2];

end

% Precondition data for instrument response removal.
x = detrend(x, 'constant');
x = detrend(x, 'linear');
if ~isnan(R)
    x = x .* tukeywin(length(x), R);

end

% Actually remove the instrument response (SAC-software equivalent `transfer`)
x = transfer(x, h.DELTA, fl, 'mermaid', sacpz, 'sacpz');

%% <Temporary solution until I decide how to integrate Alex Burky's code
rmpath(rflexa)
%% Temporary/>
