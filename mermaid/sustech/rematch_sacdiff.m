function rematch_sacdiff()
% REMATCH_SACDIFF
%
% The idea is that if the SAC files are bad (bad data, bad locations etc.)  then
% the matches or lack thereof may also be bad (e.g., bad interpolation causing
% match to wrong earthquake.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 08-Sep-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

merdir = getenv('MERMAID');
sacdir = fullfile(merdir, 'sustech_on_mac', 'processed')
evtdir = fullfile(merdir, 'sustech_on_mac', 'events')

matchall(false, sacdir, evtdir);
