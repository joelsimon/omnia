function [eq_idx, ci_idx] = verify_pt0
% [eq_idx, ci_idx] = VERIFY_PT0
% 
% Verifies EQ.TaupTimes.pt0 == CP.inputs.pt0 == h.B (time assigned for
% first sample in SAC header) for SAC file.  See notes at bottom of
% function for reason this occurred.
%
% Rematches the offending SAC files with cpsac2evt.m (resulting in
% overwriting raw.evt and, after review, .evt files) and overwrites
% the offending .cp files with writechangepoint.m.
%
% On 22-Jul-2019: 5 total SAC files where modified and now had h.B
% times that differed with EQ.TaupTimes.pt0.  The issue was resolved
% over these two commits.
%
% By 22-Jul-2019 the issue (remove and rematch raw and reviewed .evt
% files) was resolved with these two commits in $MERMAID/events:
%
% 26_Jul-2019: e0b81e769959239937f13bf6b3edc9aa1616e77e (update 2 .evt)
% 25-Jul-2019: 1673e2751c4272c84eb584e39a57ffa6f6d369cf (update 3 .evt)
%
% 01-Aug-2019: Added checking of changepoint structures, and updated
% the .cp files associated with the same 5 SAC files as before:
%
% !!      ecc1f49d3279e7e4618008a01f28ed38f87c0b5e                !!
%
% That commit is the most up-to-date and includes corrections for both
% .evt and .cp files.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 01-Aug-2019, Version 2017b
% Documented pp. 43-44 2017.2

% Check all SAC files because they may be unidentified and thus their
% revEQ is [] but their rawEQ is not and is populated with the
% outdated information. DO NOT USE REVSAC.m!
s = fullsac;

eq_idx = [];
ci_idx = [];
for i = 1:length(s)
    i

    [~, h] = readsac(s{i});

    % Raw and reviewed EQ structures, and rawCP structure (with 2 indices,
    % the second corresponding to the changepoint associated with a
    % windowed segment of the seismogram..
    [revEQ, rawEQ, rawCP] = getevt(s{i});
    
    % Saved changepoint structs, with confidence intervals.
    ciCP = getcp(s{i});


    %% Earthquake structures.
    
    if isstruct(revEQ)
        for j = 1:length(revEQ)
            for k = 1:length(revEQ(j).TaupTimes)
                if ~isequal(revEQ(j).TaupTimes(k).pt0, h.B)
                    eq_idx = [eq_idx i];
                    warning(num2str(i))

                end
            end
        end
    end

    if isstruct(rawEQ)
        for j = 1:length(rawEQ)
            for k = 1:length(rawEQ(j).TaupTimes)
                if ~isequal(rawEQ(j).TaupTimes(k).pt0, h.B)
                    eq_idx = [eq_idx i];
                    warning(num2str(i))

                end
            end
        end
    end

    %% Changepoint structures.
    
    % rawCP is of length 2: the second index is windowed CP structure with
    % an offset x-axis. As long as CP(1) has the correct pt0 then
    % CP(2) will also be correct.
    if ~isequal(rawCP(1).inputs.pt0, h.B)
        % This can be included in the eq_idx count because rawCP will be
        % overwritten with cpsac2evt.
        eq_idx = [eq_idx i];
        warning(num2str(i))

    end

    % ciCP (the saved CP structure of the entire time series) is only of
    % length 1; no 2nd, windowed CP index.
    if ~isequal(ciCP.inputs.pt0, h.B)
        % This requires its own index because cpsac2evt.m will not update the
        % changepoint files; must use writechangepoint.m.
        ci_idx = [ci_idx i];
        warning(num2str(i))

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

return

%_____________________________________________________________________%

% Why this happened: I took processed files from FJS and 5 SAC files
% where modified in $MERMAID/processed git commit Mon Jul 22 12:27:21
% 2019 -0400
%
% 0b6ab2666d2cbc0110568f162eb56b18be30e997
% 
% 20180824T090654.06_5C928D65.MER.REQ.WLT5.sac | Bin 24568 -> 24568 bytes
% 20190105T194208.06_5CDB0CDC.MER.REQ.WLT5.sac | Bin 24568 -> 24568 bytes
% 20190120T014917.06_5CDB0CDC.MER.REQ.WLT5.sac | Bin 24568 -> 24568 bytes
% 20190222T103416.06_5CDB0CDC.MER.REQ.WLT5.sac | Bin 24568 -> 24568 bytes
% 20190301T090747.06_5CDB0CDC.MER.REQ.WLT5.sac | Bin 24568 -> 24568 bytes
%
% Apparently FJS' system wrote a slightly different h.B with main.py

% Let's have a look by jumping between the two versions using the git
% log in $MERMAID/processed.

s = {'20180824T090654.06_5C928D65.MER.REQ.WLT5.sac', ...
     '20190105T194208.06_5CDB0CDC.MER.REQ.WLT5.sac', ... 
     '20190120T014917.06_5CDB0CDC.MER.REQ.WLT5.sac', ... 
     '20190222T103416.06_5CDB0CDC.MER.REQ.WLT5.sac', ...
     '20190301T090747.06_5CDB0CDC.MER.REQ.WLT5.sac'}

for i = 1:length(s)
    [~, h] = readsac(fullsac(s{i}));
    h.B

end

% In current commit on master branch: Wed Jul 24 16:07:45 2019 -0400
%
% a676712c156365bbdd69678616faba15335f259
%
% 7.1400e-04
% 5.1600e-04
% 4.9000e-05
% 9.1300e-04
% 9.2100e-04

% In commit immediately before those 5 SAC files were modified, by running:
%
% git co -b h.B 0b6ab2666d2cbc0110568f162eb56b18be30e997^
%
% 8.0200e-04
% 3.7900e-04
% 6.6700e-04
% 4.1400e-04
% 8.7000e-05

% So all 5 SAC files had their h.B times modified.
