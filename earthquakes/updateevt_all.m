% Script to update all .evt files associated with MERMAID (Princeton
% and GeoAzuR) SAC files assuming JDS' system defaults.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 23-Mar-2019, Version 2017b


% Princeton first.
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

% Then GeoAzur.
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

