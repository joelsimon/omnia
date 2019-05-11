function updateevtall(porg)
% UPDATEEVTALL(porg)
%
% Function to update all raw and reviewed .evt files associated with
% MERMAID (from Princeton and/or GeoAzur) SAC files assuming JDS'
% system defaults. Edit internally if local paths differ.
%
% Input:
% porg     1: Princeton SAC files (generation 3 buoy)
%          2: GeoAzur SAC files (generation 2 buoy)
%          3: Both Princeton and GeoAzur
%
% Output:
% N/A      Saves updated raw and reviewed .evt files
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 03-Apr-2019, Version 2017b

%% Recursive.
    
% Princeton.
if porg == 1
diro = fullfile(getenv('MERMAID'), 'events');
s = fullsac;
for i = 1:length(s);
    [revEQ, rawEQ, rawCP, ~, rev_evt, raw_evt] = getevt(s{i}, diro, false);
    
    EQ = updateevt(rawEQ);
    CP = rawCP;
    save(raw_evt, 'EQ', 'CP', '-mat')

    EQ = updateevt(revEQ);
    save(rev_evt, 'EQ', '-mat')

end

% GeoAzur.
if porg == 2
diro = fullfile(getenv('MERMAID'), 'geoazur', 'rematch');
s = mermaid_sacf('id');
for i = 1:length(s);
    [revEQ, rawEQ, rawCP, ~, rev_evt, raw_evt] = getevt(s{i}, diro, false);
    
    EQ = updateevt(rawEQ);
    CP = rawCP;
    save(raw_evt, 'EQ', 'CP', '-mat')

    EQ = updateevt(revEQ);
    save(rev_evt, 'EQ', '-mat')

end

% Both.
if porg == 3
    
    %% Recursion.

    updateevtall(1);
    updateevtall(2)

end
