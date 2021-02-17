function tt = arrivaltime(h, evtdate, evtloc, mod, evdp, phases, pt0)
% tt = ARRIVALTIME(h, evtdate, [evla evlo], mod, evdp, phases, pt0)
%
% ARRIVALTIME returns the theoretical arrival time(s) of seismic phase(s) in a
% seismogram.
%
% All travel times (that exist) are computed for every phase
% requested, though only those phase arrivals which fall within the
% time window of the seismogram are returned.
%
% Dependency: ARRIVALTIME requires the MatTaup package,
%             specifically the function taupTime.m,
%             written by Qin Li, dated November 2002.
%
% Input:
% h             SAC header from readsac.m (FJS function)
% evtdate       Earthquake rupture time in datetime format in UTC timezone
% [evla evlo]*  Event location as [latitude longitude] (def: [h.EVLA h.EVLO])
% mod           TauP velocity model (def: 'ak135')
% evdp*         Event depth in km (def: h.EVDP)
% phases        Comma separated phase list (def: 'P')
% pt0           Time in seconds assigned to first sample (def: 0 s)
%                  (another good choice: h.B, see example 2)
%
% * may be left empty if SAC header is populated with event info
%
% Output: (def: [])
% tt            Extended output struct from taupTime with extra fields:
%   .arrivaldatetime: absolute arrival time in datetime format
%   .arrivaldatenum: absolute arrival time in datenum format
%   .truearsecs: the true arrival in seconds on the x-axis
%                when x-axis = xaxis(length(x), delta, pt0)
%   .arsecs: time in seconds at sample nearest to the .truearsecs
%   .arsamp: sample index whose corresponding time is nearest .truearsecs
%   .model: velocity model use
%   .pt0: time in seconds assigned to first sample
%
% Ex1: (load example MERMAID12 seismogram and calculate arrival time)
%    sacf = 'm12.20130416T105310.sac';
%    [x, h] = readsac(sacf);
%    datefmt = ['uuuu/MM/dd HH:mm:ss.SS'];
%    evtdate = datetime('2013/04/16 10:44:20.70', 'Format', datefmt, 'TimeZone', 'UTC');
%    % SAC header includes event information; leave optional inputs empty
%    tt = ARRIVALTIME(h, evtdate, [],'ak135', [], 'P')
%    figure; ha = gca; plot(x); hold(ha, 'on');
%    % Plot the arrival time (in samples)
%    plot([tt.arsamp tt.arsamp], ha.YLim, 'r'); shg
%
% Ex2: (arrival time offset assuming pt0 at both 0 and h.B seconds)
%    [x, h] = readsac('centcal.1.BHZ.SAC');
%    evtdate = datetime('2013-08-25 18:50:28', 'TimeZone', 'UTC');
%    % Time offset assuming first sample at t = 0 s
%    pt0 = 0;
%    xax0 = xaxis(length(x), h.DELTA, pt0);
%    tt0 = ARRIVALTIME(h, evtdate, [],'ak135', [], 'p', pt0);
%    % Time offset assuming first sample at t = -120.6810 s (h.B)
%    pt0 = h.B;
%    xaxB = xaxis(length(x), h.DELTA, pt0);
%    ttB = ARRIVALTIME(h, evtdate, [],'ak135', [], 'p', pt0);
%    % In either case, the offset sample is the same -- that sample
%    % simply maps to a different x-axis time depending on pt0.
%    ttB.arsamp == tt0.arsamp;
%    subplot(2,1,1)
%    plot(xax0, x);
%    vertline(tt0.arsecs); title('pt0 = 0 s (seconds since event)')
%    subplot(2,1,2)
%    plot(xaxB, x);
%    vertline(ttB.arsecs); title('pt0 = -120.6810 s (seconds since reference time)'); shg
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 03-Jul-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults.
defval('evtloc', [h.EVLA h.EVLO])
defval('evdp', h.EVDP)
defval('mod', 'ak135')
defval('phases', 'P')
defval('pt0', 0)

% Concatenate station location from header.
staloc = [h.STLA h.STLO];

% Error checking.
if any(staloc == -12345)
    error('Null value (-12345) in header station location.')

end
if ~strcmp(evtdate.TimeZone, 'UTC') || isempty(evtdate.TimeZone)
    error('Input argument evtdate must be datetime format with ''UTC'' timezone.')

end
if evdp < 0
    error('Event depth (evdp) must be positive')

end
if any(evtloc == -12345)
    error('Null value (-12345) in event location.')

end

% Collect seismogram datetime information.
seisdate = seistime(h);

% Calculate travel time(s). Exit if no phases returned.
tt = taupTime(mod, evdp, phases, 'sta', staloc, 'evt', evtloc);
if isempty(tt)
    return

end

% Preallocate new structure fields to be filled, maybe.
[tt(:).arrivaldatetime] = deal([]);
[tt(:).truearsecs] = deal([]);
[tt(:).arsecs] = deal([]);
[tt(:).arsamp] = deal([]);
[tt(:).model] = deal(mod);
[tt(:).pt0] = deal(pt0);

% Set up x-axis to map arrival time to nearest sample.
xax = xaxis(h.NPTS, h.DELTA, pt0);

% For every travel time: the arrival datetime is the earthquake
% rupture datetime plus the travel time. If the arrival datetime is
% within the time window of the seismogram, mark the offset.
len_tt = length(tt);
no_arr = [];
for i = 1:len_tt
    % The absolute theoretical arrival time is the estimated event
    % (origin) time plus theoretical travel time.
    tt(i).arrivaldatetime = evtdate + seconds(tt(i).time);
    tt(i).arrivaldatenum = datenum(tt(i).arrivaldatetime);

    % And that event is only recorded here if it has the specific phases
    % associated with that event arrive in the time window of the
    % seismogram.
    if  isbetween(tt(i).arrivaldatetime, seisdate.B, seisdate.E)
        tt(i).truearsecs = ...
            seconds(tt(i).arrivaldatetime-seisdate.B) + pt0;

        %  There is unlikely to be a sample exactly on .truearsecs.  Find the
        %  sample nearest the true offset time.
        tt(i).arsamp = nearestidx(xax, tt(i).truearsecs);
        tt(i).arsecs = xax(tt(i).arsamp);

    else
        % Index to be removed (arrival time outside seismogram's time window).
        no_arr = [no_arr  i];

   end
end
tt = orderfields(tt);

% Remove structure indices whose phase arrivals are not within
% seismograms time window.
tt(no_arr) = [];

% len_tt is the length of all possible matches before removing those
% arrival times outside of the seismogram's time window.  If the array
% [1:len_tt] equals the array of tt indices removed (no_arr), we have
% removed all indices and thus I'd prefer to return a truly empty
% double than a structure with empty fields.  N.B: cannot use
% length(tt) as loop indexer and check here because length(tt)
% decreases as indices are removed.  Do not change this.
if isequal(no_arr, 1:len_tt)
    tt = [];

end
