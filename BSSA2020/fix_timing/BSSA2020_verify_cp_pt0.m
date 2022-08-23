function BSSA2020_verify_cp_pt0
% BSSA2020_verify_cp_pt0
%
% Single use script to verify that pt0 in all timings are equal between SAC
% header, EQ structure, and CP structure.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 23-Aug-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('sac_diro', getenv('MERAZUR'));
defval('rematch_diro', fullfile(getenv('MERAZUR'), 'rematch'));
defval('evt_diro', fullfile(rematch_diro))
defval('cp_diro', fullfile(rematch_diro, 'changepoints'))

s = mermaid_sacf('id', sac_diro);

for i = 1:length(s)
    i
    [~, h] = readsac(s{i});

    EQ = getevt(s{i}, evt_diro);
    CP = getcp(s{i}, evt_diro);

    if all(h.B ~= [EQ.TaupTimes.pt0])
        error()

    end
    if h.B ~= CP.outputs.xax(1)
        error()

    end
end
