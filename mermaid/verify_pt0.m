function [eq_idx, ci_idx, s] = verify_pt0(incl_raw)
% [eq_idx, ci_idx, s] = VERIFY_PT0(incl_raw)
%
% Verifies EQ.TaupTimes.pt0 == CP.inputs.pt0 == h.B (time assigned for first
% sample in SAC header) for SAC file.  Assumes SAC file timing is the reference
% (correct) timing against which the others should be compared.
%
% Paths to .sac and .evt files assuming JDS' system defaults. Modify internally
% if required.
%
% Rematches the offending SAC files with cpsac2evt.m (resulting in overwriting
% raw.evt and, after review, .evt files) and overwrites the offending .cp files
% with writechangepoint.m.
%
% Input:
% incl_raw*   true: check both raw and reviewed .evt and .cp files
%             false: check only reviewed .evt and .cp files (def)
%
% Output:
% eq_idx      Index to (raw and/or reviewed) .evt files updated
% ci_idx      Index to (raw and/or reviewed) .cp files updated
% s           List of SAC files corresponding to indices above
%
% *For the purposes of this function the "raw" CP structures are those saved
%  with the preliminarily-matched EQ structures in .../events/raw/evt/*raw.evt
%  'mat' files, while the "reviewed" CP structures are those saved in
%  .../events/changepoints/*.cp files.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 28-Jan-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64
% Documented pp. 43-44 2017.2

% Default to ONLY check reviewed .evt and .cp files.
defval('incl_raw', true)

% Check all SAC files because they may be unidentified and thus their
% revEQ is [] but their rawEQ is not and is populated with the
% outdated information. DO NOT USE REVSAC.m!
s = fullsac;

eq_idx = [];
ci_idx = [];
for i = 1:length(s)
    sac = s{i};
    fprintf('Checking: %s (index %i)\n', sac, i)

    [~, h] = readsac(sac);

    % Raw and reviewed EQ structures, and rawCP structure (with 2 indices,
    % the second corresponding to the changepoint associated with a
    % windowed segment of the seismogram..
    [revEQ, rawEQ, rawCP] = getevt(sac);

    % Saved ("reviewed") changepoint structs, with confidence intervals.
    ciCP = getcp(sac);


    %% Earthquake structures.

    if isstruct(revEQ)
        for j = 1:length(revEQ)
            for k = 1:length(revEQ(j).TaupTimes)
                if ~isequal(revEQ(j).TaupTimes(k).pt0, h.B)
                    eq_idx = [eq_idx i];
                    %warning(sac)

                end
            end
        end
    end

    if incl_raw && isstruct(rawEQ)
        for j = 1:length(rawEQ)
            for k = 1:length(rawEQ(j).TaupTimes)
                if ~isequal(rawEQ(j).TaupTimes(k).pt0, h.B)
                    eq_idx = [eq_idx i];
                    %warning(sac)

                end
            end
        end
    end

    %% Changepoint structures.

    % rawCP is of length 2: the second index is windowed CP structure with
    % an offset x-axis. As long as CP(1) has the correct pt0 then
    % CP(2) will also be correct.
    if incl_raw && ~isequal(rawCP(1).inputs.pt0, h.B)
        % This can be included in the eq_idx count because rawCP will be
        % overwritten with cpsac2evt.
        eq_idx = [eq_idx i];
        %warning(sac)

    end

    % ciCP (the saved CP structure of the entire time series) is only of
    % length 1; no 2nd, windowed CP index.
    if ~isequal(ciCP.inputs.pt0, h.B)
        % This requires its own index because cpsac2evt.m will not update the
        % changepoint files; must use writechangepoint.m.
        ci_idx = [ci_idx i];
        %warning(sac)

    end

end

eq_idx = unique(eq_idx);
ci_idx = unique(ci_idx);

%% Rematch seismograms (rewrite raw.evt and reviewed .evt files).

% N.B.: Do not use `for i = eq_idx' because MATLAB enters loops with
% empty loop arrays... weird.

for i = 1:length(eq_idx)
    cpsac2evt(s{eq_idx(i)}, true, 'time', 5)
    close all

end

for i = 1:length(eq_idx)
    clc
    reviewevt(s{eq_idx(i)}, true)

end

%% Rewrite changepoint (.cp files).

cpdir = fullfile(getenv('MERMAID'), 'events', 'changepoints');
for i = 1:length(ci_idx)
    % The data itself may differ slightly too, so don't use ciCPi.x -- use
    % the actual data from readsac.m.
    sac = s{ci_idx(i)};
    [x, h] = readsac(sac);
    sans_sac = strrep(strippath(sac), '.sac', '');
    writechangepoint(sans_sac, cpdir, 'time', x, 5, h.DELTA, h.B, 1, cpinputs, 1);

end
