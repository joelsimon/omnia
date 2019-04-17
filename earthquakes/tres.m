function [tres_time, tres_phase, tres_EQ, tres_TaupTime] = tres(EQ, CP, multi)
% [tres_time, tres_phase, tres_EQ, tres_TaupTime] = TRES(EQ, CP, multi)
%
% Returns the minimum of the multiscale travel time residuals between
% changepoint estimates, recorded in CP, and theoretical arrival
% times, recorded in EQ.
%
% Input:
% EQ            Event structure, EQ, returned from cpsac2evt.m
% CP            Changepoint structure, from changepoint.m
% multi         logical true to consider all phases for all earthquakes 
%               logical false only to consider EQ(1) (def: false)
%
% Output:
% tres_time     Minimum travel time residual (seconds) 
% tres_phase    Phase associated with minimum travel time residual
% tres_EQ       EQ index associated with tres_phase
% tres_TaupTime TaupTime index associated with tres_EQ*
%
% *currently not supported if multi == true
%
% Before running the examples below, first run the Ex1 in cpsac2evt.m
% and the examples in getevt.m and getcp.m.
%
% Ex1: (minimum residual using reviewed [single] event)
%    sac = '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac';
%    diro = '~/cpsac2evt_example';
%    EQ  = getevt(sac, diro);
%    CP = getcp(sac, diro);
%    [tres_time, tres_phase, tres_EQ] = TRES(EQ, CP, false)
%
% Ex2: (minimum residual at scale 5 associated with EQ(12) phase 'PcP.
%       This example uses rawEQ, clearly not a match, to illustrate
%       locating the minimum residual across multiple events).
%    sac = '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac';
%    diro = '~/cpsac2evt_example';
%    [~, rawEQ]  = getevt(sac, diro);
%    CP = getcp(sac, diro);
%    [tres_time, tres_phase, tres_EQ] = TRES(rawEQ, CP, true)
%
% See also: getevt.m, getcp.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 03-Apr-2019, Version 2017b

%  Wish list: TaupTimes index if multi = true. Should be relatively
%  simple; haven't gotten around to it.

%% Recursive.

% Default.
defval('multi', false)

% Return empty if either input is empty.
if isempty(EQ) || isempty(CP)
    tres_time = [];
    tres_phase = [];
    tres_EQ = [];
    return
    
end
    
if multi 
    % Initialize arrays.
    all_tres_time = NaN(length(EQ), length(CP.arsecs));
    all_tres_phase = cell(1, length(EQ));

    % Find minimum residuals (at every scale) for every earthquake,
    % individually, and write them as a single row.  E.g., EQ indices
    % are the rows and scales are the columns: 
    % 
    % all_tres_time(EQ, scale)
    
    for i = 1:length(EQ)

        %% Recursion.
        if nargout > 3
            error('Have not yet programmed fourth output if ''multi'' = true')

        end
        [all_tres_time(i, :), all_tres_phase{i}] = tres(EQ(i), CP);

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

        end
    end

    return

else
    % Consider only the first event in the EQ structure and do not run
    % tres.m recursively.
    EQ = EQ(1);
    tres_EQ = ones(1, length(CP.arsecs));

end

% Initialize cells and arrays with NaNs.
all_tres = celldeal(CP.arsecs, NaN);
tres_phase = celldeal(CP.arsecs, NaN);
tres_time = NaN(1, length(CP.arsecs));
tres_TaupTime = NaN(1, length(CP.arsecs));

% Travel time residuals considering a single EQ.
for j = 1:length(CP.arsecs)
    if ~isnan(CP.arsecs{j})
        % Convert both arrival times to offsets from 0 seconds (set the first
        % sample of the seismogram to 0 seconds).
        jds_time = CP.arsecs{j} - CP.inputs.pt0; 
        tt_time = [EQ.TaupTimes.truearsecs] - [EQ.TaupTimes.pt0];
        all_tres{j} = CP.arsecs{j} - [tt_time]; 
        [~, minidx] = min(abs(all_tres{j}));
        tres_time(j) = all_tres{j}(minidx);
        tres_phase{j} =  EQ.TaupTimes(minidx).phaseName;
        tres_TaupTime(j) = minidx;

    else
        tres_EQ(j) = NaN;

    end
end
