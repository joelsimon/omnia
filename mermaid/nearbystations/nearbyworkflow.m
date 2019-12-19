function nearbyworkflow
% Fetches nearby traces, removes their instrument response, writes
% their corresponding event files, and updates all nearby and MERMAID
% event files assuming JDS system defaults
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 18-Dec-2019, Version 2017b on GLNXA64

clc
fetchnearbytracesall;
rmnearbyrespall;
nearbysac2evtall;
updateidall;
