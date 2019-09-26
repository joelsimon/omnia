function idx = firstnearbyphase(mer_EQ, nearby_EQ)
% idx = FIRSTNEARBYPHASE(mer_EQ, nearby_EQ)
%
% FIRSTNEARBYPHASE returns the phase index, idx, such that
% nearby_EQ.TaupTimes(idx) is the earliest-arriving phase in
% nearby_EQ.TaupTimes whose phase name also a first-arriving phase in
% mer_EQ.
%
% E.g., every first-arrival in mer_EQ is tallied and searched for in
% nearby_EQ.  For every nearby_EQ, the earliest-arriving phase
% considering all mer_EQ first-arrivals is returned.
%
% The index-array idx is returned in the same order as nearby_EQ.  If
% the first phase(s) in mer_EQ is not contained in nearby_EQ, NaN is
% returned.
%
% The vast majority of cases will return ones(length(nearby_EQ), 1)
% because generally the first-arriving phase in a MERMAID seismogram
% is P-wave which has not traversed the core and thus has no
% precursors.
%
% In the example below the first-arriving phase identified in the
% MERMAID data is the PKIKP wave, though the first arriving-phase in
% the 'nearby' SAC files are various precursors, e.g., Pdiff.  We
% don't want to compare Pdiff with PKIKP so we must identify in
% nearby_EQ{:}.TaupTimes(idx) the indices which correspond to the
% first phase(s) present in the MERMAID data, in this case, PKIKP.
%
% Input:
% mer_EQ    Cell array of MERMAID EQ structures from getnearbysacevt.m
% nearby_EQ Cell array of 'nearby' EQ structures from getnearbysacevt.m
%
% Output:
% idx       Indices of nearby_EQ(idx_index).TaupTimes(idx) whose .phaseName
%               matches that of a first-arriving phase contained in mer_EQ
%
% Ex:
%    [~, mer_EQ, ~, nearby_EQ] = getnearbysacevt('10964158', [], [], [], [], 'DET');
%    idx = FIRSTNEARBYPHASE(mer_EQ, nearby_EQ)
%    fprintf('\nThe first phase in all mer_EQ is PKIKP\n\n')
%    for i = 1:length(idx)
%        fprintf('The phase at index  1 in nearby_EQ{%i} is %s...\n', ...
%            i, nearby_EQ{i}.TaupTimes(1).phaseName)
%        fprintf('...and the phase at index %i in nearby_EQ{%i} is %s\n\n', ...
%            idx(i), i, nearby_EQ{i}.TaupTimes(idx(i)).phaseName)
%    end
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 26-Sep-2019, Version 2017b on GLNXA64

% Collect all first-arriving phase names in the MERMAID data.
first_mer_phase{length(mer_EQ)} = [];
for i = length(mer_EQ):-1:1;
    first_mer_phase{i} = mer_EQ{i}(1).TaupTimes(1).phaseName;

end
first_mer_phase = unique(first_mer_phase);

% First phase in MERMAID data may be upgoing phase (lowercase 'p'),
% but more distant first-arrival may be downgoing phase (uppercase
% 'P'), per phase-naming of Crotwell+1999.
if strcmpi(first_mer_phase, 'p')
    first_mer_phase = {'p' 'P'};

end

idx = NaN(length(nearby_EQ), 1);
for i = 1:length(nearby_EQ)
    for j = 1:length(nearby_EQ{i}.TaupTimes)
        if any(strcmp(nearby_EQ{i}.TaupTimes(j).phaseName, first_mer_phase))
            idx(i) = j;
            break

        end
    end
end
