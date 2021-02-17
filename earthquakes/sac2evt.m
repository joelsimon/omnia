function EQ = sac2evt(sac, model, ph, baseurl, varargin)
% EQ = SAC2EVT(sac, model, ph, baseurl, [param, value])
%
% SAC2EVT is the stupid SAC file to event matching tool.
%
% Input:
% sac             SAC filename
% model           TauP model (def: 'ak135')
% ph              TauP phases (def: taup_defaultphases)
% baseurl         1: 'http://service.iris.edu/fdsnws/event/1/' (def)
%                 2: 'https://earthquake.usgs.gov/fdsnws/event/1/'
%                 3: 'http://isc-mirror.iris.washington.edu/fdsnws/event/1/'
%                 4: 'http://www.isc.ac.uk/fdsnws/event/1/'
% [param, value]* Comma separated parameter, value pair list for irisFetch.Events
%
% N.B.: baseurls 2-4 either are buggy and/or straight up do not
% work. Left here for future fixes (hopefully).
%
% Output:
% EQ              Event structure that concatenates output structures
%                     from irisFetch.Events and arrivaltime.m  (see the
%                     latter to understand how timing is handled, in
%                     particular that relative times are w.r.t the SAC
%                     reference time, that is to say the first sample is
%                     assigned at h.B 0 s, not 0 s)
%
% By default SAC2EVT queries event information from the IRIS DMC for
% the time duration beginning one hour before the start of the
% seismogram and ending at the end time of the seismogram*.  For each
% earthquake returned it then calculates the theoretical travel times
% for the specified seismic phases using taupTime.m.  Overwrite
% these times with 'start' and 'end' [param, value] optional arguments.
%
% By default SAC2EVT searches the entire globe for events and requests
% all magnitudes (not just the "preferred magnitude") be returned to
% increase the chance of returning an 'Mb' or 'Ml' magnitude type.
% One of these is necessary for an expected phase-pressure
% approximation via reid.m.  Be aware that altering the search area
% and/or optional parameters may lower the rate of event matching
% and/or EQ structure completeness.  Available parameters and their
% effect may be found at the default baseurl:
% http://service.iris.edu/fdsnws/event/1/
%
% N.B: negative event depths are set to 0 km for the purpose of
% theoretical travel-time computation; see in-code comments for more.
%
% SAC2EVT has external dependencies -
% *taupTime.m: last tested with Nov. 2002 version written by Qin Li
% *irisFetch.m: last tested with version = 2.0.10 and IRIS-WS-2.0.18.jar
%
% Ex1:
%    EQ = SAC2EVT('centcal.1.BHZ.SAC')
%
% *Ex2: Look for M5+ events in a two minute time window;
%       and overwrite default to not includeallmagnitudes
%    sac = 'm35.20140915T080858.sac';
%    stime = '2014-09-15T08:04:00';
%    etime = '2014-09-15T08:06:00';
%    EQ = SAC2EVT(sac, [], [], 1, 'start', stime, 'end', etime, 'minmag', ...
%                 5, 'includeallmagnitudes', false)
%    EQ.Params    % Note time and other parameters overwritten from defaults
%
% See also: cpsac2evt.m, arrivaltime.m, http://service.iris.edu/fdsnws/event/docs/1/help/
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 17-Feb-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default I/O.
defval('sac', 'centcal.1.BHZ.SAC')
defval('model', 'ak135')
defval('ph', taup_defaultphases)
defval('baseurl', 1);
EQ = [];

% Read SAC data and header.
[~, h] = readsac(sac);

% By default: time searched is from one hour before the start time of
% the seismogram to the end of the seismogram.  These times are
% overwritten if 'start' and 'end' are specified as inputs.
seisdate = seistime(h);
stime =  fdsndate2str(seisdate.B - hours(1));
etime = fdsndate2str(seisdate.E);

% Cases 2--4 are not suggested / don't work at the moment.
switch baseurl
  case 1
    baseurl = 'http://service.iris.edu/fdsnws/event/1/';

  case 2
    baseurl  = 'https://earthquake.usgs.gov/fdsnws/event/1/';

  case 3
    baseurl = 'http://isc-mirror.iris.washington.edu/fdsnws/event/1/';

  case 4
    baseurl = 'http://www.isc.ac.uk/fdsnws/event/1/';

  otherwise
    error('Specify integer 1--4 for baseurl')

end

% Fetch event data.
fprintf('\n**************************\n')

% The following 'if' statement allows updating of the EQ structure
% with the most recent info by only searching for the identified event
% (i.e., sac2evt.m has already been run and a match has been
% identified).  The if statement is necessary because 'eventid' and
% 'start/end' time options don't play nice together.  Assumes the
% variable input argument list is properly formatted as [parameter,
% value] pairs.

if isempty(varargin) || ~contains([varargin{1:2:end}], 'eventid', 'IgnoreCase', true)
    % The irisFetch-specific options 'startTime' and 'endTime' accept
    % datetime arrays, but I have seen some odd behavior with their use:
    % double ampersands (&&) in the parameter list when using them, which
    % breaks some baseurls other than the default IRIS. Thus I think it's
    % safer to use the general 'start' and 'end' times, known to all
    % fdsnws data centers, in string format.
    [ev, params] = irisFetch.Events('start', stime, 'end', etime, ...
                                    'includeallmagnitudes', true, ...
                                    'includeallorigins', true, 'baseurl', ...
                                    baseurl, varargin{:});

else
    [ev, params] = irisFetch.Events('includeallmagnitudes', true, ...
                                    'includeallorigins', true, 'baseurl', ...
                                    baseurl, varargin{:});

end

% Keep track of the date this query was made.
querytime = irisdate2str(datetime('now', 'TimeZone', 'UTC'), 1);

%  for all events...
nevt = 0;
for i = 1:length(ev)
    quake = ev(i);

    % Skip this event is the timing is NaN, as is often the case when
    % alternate baseurls other than the IRIS default are specified.
    if isnan(quake.PreferredTime)
        continue

    end

    % Set negative depths to 0 km for taupTime (but do no overwrite the
    % EQ.PreferredDepth field, or any of the various EQ.Origins' Depth
    % fields).  Therefore it is possible that the man EQ structure
    % will display the (reported) negative event depth, but the
    % TaupTimes srcDepth field will be adjusted to 0 km, and that
    % adjusted depth is what is used to compute theoretical arrival
    % times in the attached TaupTimes structure.
    depth = quake.PreferredDepth;
    if depth < 0
        depth = 0;

    end

    % Event date for this quake.
    evdate = datetime(quake.PreferredTime, 'InputFormat', ...
                     'uuuu-MM-dd HH:mm:ss.SSS', 'TimeZone', 'UTC');

    % Compute travel times and arrival times on an x-axis where pt0, the
    % time assigned to the first sample, is set at h.B seconds, i.e., times
    % are w.r.t to the SAC reference time, not just always counting forward
    % from 0 s. Note this initial offset is recorded in EQ.TaupTimes.pt0.
    tt = arrivaltime(h, evdate, [quake.PreferredLatitude ...
                        quake.PreferredLongitude], model, depth, ph, h.B);
    if isempty(tt)
        continue

    end

    % irisFetch.m incorrectly returns the <type> subfield ('Flinn-Engdahl
    % region') instead of <text> (e.g. 'CENTRAL ITALY') subfield in
    % the xml file that is returned from fdsnws query (see url in
    % EQ(*).PublicID).  Use another web query to get the region name
    % from the preferred latitude and longitude.
    if strcmpi(quake.FlinnEngdahlRegionName, 'Flinn-Engdahl region') ...
            || isempty(quake.FlinnEngdahlRegionCode);

        % Do not input baseurl as input to feregion.m: feregion.m and
        % sac2evt.m have different baseurls.
        [quake.FlinnEngdahlRegionName, quake.FlinnEngdahlRegionCode] ...
            = feregion(quake.PreferredLatitude, quake.PreferredLongitude);

    end
    quake.Filename = strippath(sac);
    quake.Params = params;
    quake.QueryTime = querytime;
    quake.PhasesConsidered = ph;
    quake.TaupTimes = tt;

    nevt = nevt + 1;
    if nevt == 1
        EQ = quake; % Overwrite empty (double); cannot yet index.

    else
        EQ(nevt) = quake;

    end
end

if ~isempty(EQ)
    % The following loop computes a rough approximation of the expected
    % pressure of each specific phase.  We would prefer to use
    % magnitude type 'Mb' (at 1 Hz) for this approximation, though
    % magnitude type 'Ml' (at 5 Hz) will suffice.
    for i = 1:length(EQ)
        [mbml_author, mbml_type, mbml_val] = getmbml(EQ(i));
        EQ(i).MbMlAuthor = mbml_author;
        EQ(i).MbMlType = mbml_type;
        EQ(i).MbMlMagnitudeValue = mbml_val;

        % Attach .pressure field to every phase (index j) of
        % EQ(i).TaupTimes(j).
        EQ(i) = reidpressure(EQ(i));

    end

    % Sort events by maximum magnitude.
    maxmag = [EQ.PreferredMagnitudeValue];
    [~, pidx] = sort(maxmag, 'descend');
    EQ = EQ(pidx);

    % Move NaN magnitude values to end ('sort' omits NaN values, e.g.,
    % http://ds.iris.edu/spud/event/11042481, for which no magnitude
    % data exists).
    prefmagvals = [EQ.PreferredMagnitudeValue];
    [~, nanidx]  = unzipnan(prefmagvals);
    nan_EQ = EQ(nanidx);
    EQ(nanidx) = [];
    EQ = [EQ nan_EQ];
    EQ = orderfields(EQ);

    % Print followup to the initial irisFetch.Events message.
    fprintf(['\n%i %s found with phase arrivals in %s ************' ...
             '*\n**************************\n\n'], length(EQ), ...
            plurals('event', length(EQ)), strippath(sac))

else
    fprintf(['\nNo matching phase arrivals in %s ************' ...
             '*\n**************************\n\n'], strippath(sac))

end

% End main.
%________________________________________________________________________%

function [magauthor, magtype, magval] = getmbml(quake)
% Returns the value, and author associated with an 'Mb' or 'Ml'
% magnitude, or [] for all if no 'Mb' or 'Ml' magnitude type found.
%
% Prefers Mb over Ml for magnitude type.
% Prefers (in order): GCMT; ISC; IDC; then NEIC/US/PDE (the same?) for author.
%
% Ergo, any Mb from a "non"-preferred author is returned before any Ml
% magnitude types.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 01-Jul-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

magauthor = '';
magtype = '';
magval = [];

if isempty(quake.Magnitudes)
    return

end

authors = upper({quake.Magnitudes.Author});
magtypes = upper({quake.Magnitudes.Type});
magvals = [quake.Magnitudes.Value];

% (to inspect all these values) --
% [num2cell(1:length(authors))' authors' magtypes' num2cell(magvals)']

% I Prefer IDC over NEIC/US/PDE because it has a slightly lower
% magnitude threshold according to this (possibly outdated) article,
% "SUMMARY OF THE ISC BULLETIN OF EVENTS OF 2003", from
% http://www.isc.ac.uk/docs/papers/download/2006p02/.  Also, note that
% NEIC and PDE are used interchangeable as "Author".  I believe
% technically NEIC (National Earthquake Information Center, USA) is
% the author that publishes the PDE (Preliminary Determination of
% Epicenters) catalog.

for M = {'MB', 'ML'}
    magidx = find(ismember(magtypes, M));

    if ~isempty(magidx)
        for A = {'GCMT', 'ISC', 'IDC', 'NEIC', 'US', 'PDE'}
            authidx = find(ismember(authors, A));
            matchidx = intersect(magidx, authidx);

            if ~isempty(matchidx)
                magauthor = A{:};
                magtype = [upper(M{:}(1)) lower(M{:}(2))];
                magval = magvals(matchidx(1));
                return

            else
                continue

            end
        end
        % Only here if none of the preferred authors are found to list that
        % magnitude type.  Return instead the maximum value of the
        % correct magnitude type from the list of remaining authors
        % (who aren't in my preferred list above).
        [max_mag, max_idx] = max(magvals(magidx));
        magauthor = authors{magidx(max_idx)};
        magtype = [upper(M{:}(1)) lower(M{:}(2))];
        magval = max_mag;
        return

    end
end
