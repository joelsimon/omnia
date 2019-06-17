function [tres_time, tres_phase, tres_EQ, tres_TaupTime] = tres(EQ, CP, multi, fml, ph)
% [tres_time, tres_phase, tres_EQ, tres_TaupTime] = TRES(EQ, CP, multi, fml, ph)
%
% Returns the minimum of the multiscale travel time residuals between
% changepoint estimates, recorded in CP, and theoretical arrival
% times, recorded in EQ.  Use input 'ph' to specify phases against
% which residuals may be computed; i.e., you may ignore some phases in
% the EQ.PhasesConsidered list if you wish.
%
% The residual at each scale is defined as:
%
% AIC-based arrival time estimate - theoretical arrival time (TauP)
%
% Input:
% EQ            Event structure, EQ, returned from cpsac2evt.m
% CP            Changepoint structure, from changepoint.m
% multi         logical true to consider all phases for all earthquakes 
%               logical false only to consider EQ(1) (def: false)
% fml           For 'time-scale' domain only:
%               'first': tres w.r.t to start of dabe smear
%               'middle: tres w.r.t.to middle of dabe smear (def)
%               'last': tres w.r.t end of dabe smear
% ph            Comma-separated phase list to consider 
%                   (def: EQ.PhasesConsidered)
%
% Output:
% tres_time     Minimum travel time residual (seconds) 
% tres_phase    Phase associated with minimum travel time residual
% tres_EQ       EQ index associated with tres_phase
% tres_TaupTime TaupTime index associated with tres_EQ
%
% Before running the examples below, first run the Ex1 in cpsac2evt.m
% and the examples in getevt.m and getcp.m.
%
% Ex1: (minimum residual using reviewed [single] event)
%    sac = '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac';
%    diro = '~/cpsac2evt_example';
%    EQ  = getevt(sac, diro);
%    CP = getcp(sac, diro);
%    [tres_time, tres_phase, tres_EQ, tres_TaupTime] = TRES(EQ, CP, false)
%
% Ex2: (minimum residual at scale 5 associated with EQ(12) phase 'PcP.
%       This example uses rawEQ, clearly not a match, to illustrate
%       locating the minimum residual across multiple events).
%    sac = '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac';
%    diro = '~/cpsac2evt_example';
%    [~, rawEQ]  = getevt(sac, diro);
%    CP = getcp(sac, diro);
%    [tres_time, tres_phase, tres_EQ, tres_TaupTime] = TRES(rawEQ, CP, true)
%
% Ex3: (Ex2, except we only allow residuals w.r.t. to 'p', and not 'PcP')
%    sac = '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac';
%    diro = '~/cpsac2evt_example';
%    [~, rawEQ]  = getevt(sac, diro);
%    CP = getcp(sac, diro);
%    [tres_time, tres_phase, tres_EQ, tres_TaupTime] = TRES(rawEQ, CP, true, [], 'p')
%
% See also: getevt.m, getcp.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 17-Jun-2019, Version 2017b

%  Wish list: TaupTimes index if multi = true. Should be relatively
%  simple; have not gotten around to it.

%% Recursive.

% Default.
defval('multi', false)
defval('fml', 'middle')

% Return empty if either input is empty.
if isempty(EQ) || isempty(CP)
    tres_time = [];
    tres_phase = [];
    tres_EQ = [];
    tres_TaupTime = [];
    return
    
end
    
if multi 
    % Initialize arrays.
    all_tres_time = NaN(length(EQ), length(CP.arsecs));
    all_tres_phase = cell(1, length(EQ));
    all_tres_time = NaN(length(EQ), length(CP.arsecs));

    % Find minimum residuals (at every scale) for every earthquake,
    % individually, and write them as a single row.  E.g., EQ indices
    % are the rows and scales are the columns: 
    % 
    % all_tres_time(EQ, scale)
    
    for i = 1:length(EQ)
        % Default to use 'PhasesConsidered' field as possible phases to allow
        % travel-time residual computation if no input phase list
        % supplied.
        if ~exist('ph')
            ph = EQ(i).PhasesConsidered;

        end

        %% Recursion.

        [all_tres_time(i, :), all_tres_phase{i}, ~, all_tres_TaupTime(i, :)] = tres(EQ(i), CP, false, fml, ph);

    end

    % 'minidx' is the EQ index representing the minimum residual for each
    % scale (min.m works along the columns).
    [~, minidx] = min(abs(all_tres_time), [], 1);

    % Initialize arrays with NaNs.
    tres_time = NaN(1, length(CP.arsecs));
    tres_EQ = NaN(1, length(CP.arsecs));
    tres_TaupTime = NaN(1, length(CP.arsecs));
    tres_phase = celldeal(CP.arsecs, NaN);
    
    % Find minimum residual for every scale considering minimum residual
    % for every earthquake.
    for j = 1:length(minidx)
        % Check that the tres_time actually exists at this scale (minidx = 1
        % if the array is all NaNs).
        tres_time(j) = all_tres_time(minidx(j), j);

        % Overwrite the default NaN values, if an arrival exists at this scale.
        if ~isnan(tres_time(j))
            tres_phase(j) = all_tres_phase{minidx(j)}(j);
            tres_EQ(j) = minidx(j);
            tres_TaupTime(j) = all_tres_TaupTime(minidx(j), j);
            
        end
    end

    %% Function return.
    return

else
    % Consider only the first event in the EQ structure (which, if run
    % recursively above, might not truly be the first index; it may be
    % be EQ(i)).
    EQ = EQ(1);
    tres_EQ = ones(1, length(CP.arsecs));

    if ~exist('ph')
        ph = EQ.PhasesConsidered;
        
    end
end

% Tack the arrival time-smear to a single time; note that if it has
% already been smoothed with smoothscale.m this will not change
% anything.
if strcmp(CP.domain, 'time-scale') 
    arsamp = smoothscale(CP.arsamp, fml);

else
    arsamp = CP.arsamp;
end

% Initialize cells and arrays with NaNs.
all_tres = celldeal(CP.arsecs, NaN);

tres_phase = celldeal(CP.arsecs, NaN);
tres_time = NaN(1, length(CP.arsecs));
tres_TaupTime = NaN(1, length(CP.arsecs));

% We only allow the computation of travel time residuals w.r.t. the
% input phase list (which is, by default) all phases
% considered.  Compare the two lists and knock off any
% arrivals whose phases we wish to ignore.
phases_allowed = strtrim(strsplit(ph, ','));
phases_arrivin = {EQ.TaupTimes.phaseName};
idx_allowed = find(ismember(phases_arrivin, phases_allowed));

if isempty(idx_allowed)
    % No arriving phases match the requested input list.  Overwrite the
    % matching EQ structure from 1 (set above) to NaN, for all.
    tres_EQ = NaN(1, length(CP.arsecs));

else
    % Matches do exist.
    TaupTimes_allowed = EQ.TaupTimes(idx_allowed);
    
    % Travel time residuals considering a single EQ.
    for j = 1:length(CP.arsecs)
        if ~isnan(CP.arsecs{j})
            % Find arrival time using arrival sample index.
            arsecs{j} = CP.outputs.xax(arsamp{j}); % * See note at bottom.

            % Convert both arrival times to offsets from 0 seconds (set the first
            % sample of the seismogram to 0 seconds).
            jds_time = arsecs{j} - CP.inputs.pt0; 
            tt_time = [TaupTimes_allowed.truearsecs] - [TaupTimes_allowed.pt0];
            all_tres{j} = arsecs{j} - [tt_time]; 
            [~, minidx] = min(abs(all_tres{j}));
            tres_time(j) = all_tres{j}(minidx);
            tres_phase{j} =  TaupTimes_allowed(minidx).phaseName;
            tres_TaupTime(j) = minidx;

        else
            tres_EQ(j) = NaN;

        end
    end
end

% This is always true:
%
% CP.arsecs == CP.outputs.xax(arsamp)    
%
% But in 'time-scale' domain the arrival may be a time-smear and not a
% single sample -- hence we must assign the arrival to a single sample
% via smoothscale.m and then find that arrival time by pulling its
% corresponding value on the x-xaxis (time axis).  For 'time' domain,
% this step would be unnecessary and would could just use CP.arsecs.
