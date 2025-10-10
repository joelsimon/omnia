function ploteqdet(EQ, idx, diro)
% PLOTEQDET(EQ, idx, diro)
%
% Wrapper to for plotfirstarrival using those defaults for specific EQ index.
%
% If output figure empty that means either AIC did not identify changepoint
% (SNR<1), and/or EQ does not generate phase arrivals within SAC time window.
%
% Input:
% EQ       Earthquake structure
% idx      Earthquake structure index
% diro     1: $MERMAID/processed/ & $MERMAID/events/
%          2: $MERMAID/processed_everyone/ & $MERMAID/events_everyone/
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 09-Oct-2025, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

merdir = fullfile(getenv('MERMAID'));
switch diro
  case 1
    procdir = fullfile(merdir, 'processed');
    evtdir = fullfile(merdir, 'events');

  case 2
    procdir = fullfile(merdir, 'processed_everyone');
    evtdir = fullfile(merdir, 'events_everyone');

  otherwise
    % Add as necessary
    error('Unrecognized directory option\n')

end

plotfirstarrival(EQ(idx).Filename, [], [], EQ(idx), [], [], [], procdir, evtdir);
