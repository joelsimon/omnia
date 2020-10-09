function [f, ax, tx, pl, FA] = plotarrival(s, ax, FontSize, EQ, idx, ci, wlen, ...
                                            lohi, sacdir, evtdir, bathy, wlen2, ...
                                            fs, popas, hardcode_twosd) % last input hidden
% [f, ax, tx, pl, FA] = PLOTARRIVAL(s, ax, FontSize, EQ, idx, ci, wlen, lohi, ...
%                                   sacdir, evtdir, bathy, wlen2, fs, popas)
%
% Same as plotfirstarrival.m (of which this is simply a wrapper) except that the
% theoretical arrival time upon which the window is centered is not necessarily
% the first arrival time, but rather the index ('idx') of the phase of interest,
% EQ.TaupTimes(idx) (firstarrival.m automatically chooses EQ.TaupTimes(1)).
%
% Input / Output: (same as firstarrival.m, leave for...)
% idx            EQ structure index, EQ(idx), to center AIC-picking window
%
%
% *AIC picker and uncertainty estimator from
% Simon, J. D. et al., (2020), BSSA, doi: 10.1785/0120190173
%
% See also: firstarrival.m
%
% Author: Dr. Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 14-Sep-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults.
defval('s', '20180819T042909.08_5B7A4C26.MER.DET.WLT5.sac')
defval('ax', [])
defval('FontSize', [14 12])
defval('EQ', [])
defval('ci', true)
defval('wlen', 30)
defval('lohi', [1 5])
defval('sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('bathy', true)
defval('wlen2', 1)
defval('fs', [])
defval('popas', [4 1])
defval('hardcode_twosd', []) % hidden input -- see note at bottom

% Generate new axis if one not supplied.
if isempty(ax)
    f = figure;
    ax = gca;

else
    f = ax.Parent;

end
hold(ax, 'on')

% Sanity.
if length(EQ) > 1
    error(sprintf(['Length EQ > 1. Unlike firstarrival.m, where it is explicit ' ...
                   'that EQ(1) will be used, %s requires that a single, ' ...
                   'specific EQ structure be input'], mfilename))

end

len_idx = length(EQ.TaupTimes);
if idx > len_idx
    error(sprintf(['Index exceeds matrix dimensions.\nRequested EQ.TaupTimes ' ...
                   'phase index is %i, but only %i phases are present.'], idx, ...
                  len_idx))

end

% Overwrite the phase list so that only the requested phase remains.
EQ.TaupTimes = EQ.TaupTimes(idx);
[f, ax, tx, pl, FA] = plotfirstarrival(s, ax, FontSize, EQ, ci, wlen, ...
                                       lohi, sacdir, evtdir, bathy, wlen2, ...
                                       fs, popas, hardcode_twosd); % last input hidden
