function dax = datexaxis(lx, delta, start)
% dax = DATEXAXIS(lx, delta, start)
%
% Return datetime array given number of samples and sampling interval.
%
% Input:
% lx        Length of time series, in samples
% delta     Sampling interval in seconds
%               (e.g, h.DELTA in SAC header)
% start     Datetime of first sample
%
% Output:
% xax       x-axis in seconds
%
% Ex: Generate 1-minute long x-axis
%    start = datetime('now');
%    lx = 60*40 + 1;  % 1 minute at 40 Hz
%    delta = 1/40;    % 40 Hz sampling
%    dax = DATEXAXIS(lx, delta, start)
%    seconds(dax(end) - dax(1))
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 10-Feb-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

dax = start + seconds(delta*[0:lx-1])';
