function EQ = sac2evt(sac, model, ph,  varargin)
% EQ = SAC2EVT(sac, redo, model, ph, [param, value])
%
% SAC2EVT is the stupid SAC file to event matching tool.
%
% Input:
% sac           SAC filename 
% redo          logical true to return and overwrite any previous *.raw.evt/pdf files
%               logical false to skip redundant sac2evt.m execution
%               (def: false)
% model         Taup model (def: 'ak135')
% ph            Taup phases (def: taup_defaultphases)
% [param, value]  Comma separated parameter, value pair list for irisFetch.Events
%                   (def: 'includeallmagnitudes', true, 'includeallorigins', true)
%
% Output: 
% EQ            Event structure that concatenates output structures 
%                   from irisFetch.Events and taupTime.m
%
% SAC2EVT queries event information from the IRIS DMC for the time
% duration beginning one hour before the start of the seismogram and
% ending at the end time of the seismogram.  For each earthquake
% returned it then calculates the theoretical travel times for the
% specified seismic phases using taupTime.m.
%
% By default SAC2EVT searches the entire globe for events and requests
% all magnitudes (not just the "preferred magnitude") be returned to
% increase the chance of returning an 'Mb' or 'Ml' magnitude type.
% One of these is necessary for an expected phase-pressure
% approximation via reid.m.  Be aware that altering the search area
% and/or optional parameters may lower the rate of event matching
% and/or EQ structure completeness.  All available parameters and
% their effect may be found at http://service.iris.edu/fdsnws/event/1/ 
%
% SAC2EVT has external dependencies -
% *taupTime.m: last tested with Nov. 2002 version written by Qin Li
% *irisFetch.m: last tested with version = 2.0.10 and IRIS-WS-2.0.18.jar
%
% See also: cpsac2evt.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 3-Dec-2018, Version 2017b

% Default I/O.
defval('sac', 'centcal.1.BHZ.SAC')
defval('model', 'ak135')
defval('ph', taup_defaultphases)
EQ = [];

% Read SAC data and set up reference time axis.
[x, h] = readsac(sac);
xax = xaxis(length(x), h.DELTA, h.B);

% Absolute start and end time of complete seismogram and search window
% starting 1 hour before start of seismogram and ending at end of
% seismogram.
seisdate = seistime(h);
startTime = seisdate.B - hours(1);
endTime = seisdate.E;
    
% Fetch event data.  
fprintf(['\n**************************\nSearching for events between ' ...
         '%s and %s\n'], datestr(startTime), datestr(endTime));
baseurl = 'http://service.iris.edu/fdsnws/event/1/';
if isempty(varargin)
    varargin = {'includeallmagnitudes', true, 'includeallorigins', true};

end
ev = irisFetch.Events('startTime', startTime, 'endTime', endTime, ...
                      'BASEURL', baseurl, varargin{:});

% Not interested in the .Picks field at the moment.
if ~isempty(ev)
    ev = rmfield(ev, 'Picks');

end

% Loop over every phase for every event.
evtidx = [];
nevt = 0;
for i = 1:length(ev)
    quake = ev(i);
    depth = quake.PreferredDepth;
    if depth < 0 
        depth = 0;

    end

    % Event date for this quake.
    evdate = datetime(quake.PreferredTime, 'InputFormat', ...
                     'uuuu-MM-dd HH:mm:ss.SSS', 'TimeZone', 'UTC');

    % Compute travel times and arrival times w.r.t to xax generated above,
    % where pt0 (time assigned to sample 1) is set at h.B seconds
    tt = arrivaltime(h, evdate, [quake.PreferredLatitude ...
                        quake.PreferredLongitude], model, depth, ph, h.B);

    if all(arrayfun(@(zz) (isempty(zz.arsecs)), tt))
        % .arsecs is the arrival time of the seismic phase(s) relative to h.B.
        % If all are empty for a given event that means no phases
        % associated with that event arrive in the time window of
        % seismogram.  Move to next event.
        continue

    end    
    
    % irisFetch.m incorrectly returns the <type> subfield ('Flinn-Engdahl
    % region') instead of <text> (e.g. 'CENTRAL ITALY') subfield xml
    % file that is returned from fdsnws query (see url in
    % EQ(*).PublicID).  Use another web query to get the region name
    % from the preferred latitude and longitude.
    if strcmpi(quake.FlinnEngdahlRegionName, 'Flinn-Engdahl region')

        % Do not input baseurl as input to feregion.m: feregion.m and
        % sac2evt.m have different baseurls.
        quake.FlinnEngdahlRegionName = feregion(quake.PreferredLatitude, ...
                                                quake.PreferredLongitude); ...

    end

    % For every event, loop over phase and keep the ones that arrive
    % within the seismogram's time window.  Compute the approximate
    % pressure of that phase and log this information in .TaupTime
    % structure, tacked to larger EQ structure.
    evtidx = [evtidx i];
    nphase = 0;
    for j = 1:length(tt)
        tp = tt(j);
        tpSamp = tp.arsamp;
        tpSecs = tp.arsecs;
        if isempty(tpSamp)
            continue

        end

        % Generate a fresh instance of the EQ struct if first phase match of
        % this event.
        nphase = nphase + 1;
        if nphase == 1
            nevt = nevt  + 1;
            EQ(nevt).FileName = strippath(sac);
            evfields = fieldnames(quake);

            for k = 1:length(evfields)
                EQ(nevt).(evfields{k}) = quake.(evfields{k});

            end
        end

        tpfields = fieldnames(tp);
        for l = 1:length(tpfields)
            EQ(nevt).TaupTimes(nphase).(tpfields{l}) = tp.(tpfields{l});

        end       
    end
end

if ~isempty(EQ)

    % The following loop computes a rough approximation of the expected
    % pressure of each specific phase.  We would prefer to use magnitude
    % type 'Mb' (at 1 Hz) for this approximation, though magnitude type
    % 'Ml' (at 5 Hz) will suffice.  Look first for 'Mb.' We only have to
    % do this once for this specific quake.
    for i = 1:length(EQ)
        [mbml_author, mbml_type, mbml_val] = getmbml(EQ(i));
        EQ(i).MbMlAuthor = mbml_author;
        EQ(i).MbMlType = mbml_type;
        EQ(i).MbMlMagnitudeValue = mbml_val;

        if isempty(mbml_author)
            [EQ(i).TaupTimes(:).pressure] = deal([]);
            continue

        end

        % Distance is the same for all TaupTimes phases (the distance
        % corresponds to the EQ, not the phase).  Skip this event if its
        % too distant to use Ml magnitude type per warning thrown in
        % woodanderson.m, or too close to use Mb magnitude type per
        % warning thrown in gutenbergrichter.m (both called via reid.m).
        if deg2km(EQ(i).TaupTimes(1).distance) >= 600 && strcmpi(mbml_type, 'Ml')
            [EQ(i).TaupTimes(:).pressure] = deal([]);
            continue
            
        end

        if deg2km(EQ(i).TaupTimes(1).distance) <= 600 && strcmpi(mbml_type, 'Mb')
            [EQ(i).TaupTimes(:).pressure] = deal([]);
            continue
            
        end

        for j = 1:length(EQ(i).TaupTimes)
            % Input swtiches for reid.m
            switch mbml_type
              case 'Mb'
                freq = 1;

              case 'Ml'
                freq = 5;

            end

            switch model
              case 'ak135'
                Vp = 5800; 
                Vs = 3640; 
                
              case 'iasp91'
                Vp = 5800;
                Vs = 3360;
                
              case 'prem'
                % Ignoring "Ocean" layer (Vs = 0).
                Vp = 5800;
                Vs = 3200;
            end

            % Main routine to compute pressure.
            expp = reid(mbml_type, mbml_val, EQ(i).TaupTimes(j).distance, ...
                        freq, EQ(i).TaupTimes(j).incidenceAngle, Vp, Vs);

            % reid.m outputs a 2x1 array (P and S wave pressure).
            switch upper(EQ(i).TaupTimes(j).phaseName(1))
              case 'P'
                expp = expp(1);
                
              case 'S'
                expp = expp(2);

              otherwise
                error('Phase name must start with ''P'' or ''S'' (case-insensitive).')

            end
            EQ(i).TaupTimes(j).pressure = expp;

        end
    end    

    % Sort events by maximum magnitude.
    maxmag = [EQ.PreferredMagnitudeValue];
    [~, pidx] = sort(maxmag, 'descend');
    EQ = EQ(pidx);
    
    % Move NaN magnitude values to end ('sort' omits NaN values).
    prefmagvals = [EQ.PreferredMagnitudeValue];
    [~, nanidx]  = unzipnan(prefmagvals);
    nan_EQ = EQ(nanidx);
    EQ(nanidx) = [];
    EQ = [EQ nan_EQ];
    EQ = orderfields(EQ);

    % Print followup to the initial irisFetch.Events message.
    fprintf(['\n%i %s found with phase arrivals in %s ************' ...
             '*\n**************************\n\n'], length(EQ), ...
            plurals('event', length(EQ)),sac)
    
end
    
% End main.
%________________________________________________________________________%

function [magauthor, magtype, magval] = getmbml(quake)
% Returns the value, and author associated with an 'Mb' or 'Ml'
% magnitude, or [] for all if no 'Mb' or 'Ml' magnitude type found.
%
% Prefers Mb, then Ml for magnitude type.
% Prefers GCMT, then ISC then, IDC, then NEIC/PDE (the same) for author.
%
% Ergo, any Mb from a "non"-preferred author is returned before any Ml
% magnitude types.
%
% Last modified in Ver. 2017b by jdsimon@princeton.edu, 26-Sep-2018.

magauthor = [];
magtype = [];
magval = [];

if isempty(quake.Magnitudes)
    return

end

authors = upper({quake.Magnitudes.Author});
magtypes = upper({quake.Magnitudes.Type});
magvals = [quake.Magnitudes.Value];

% (to inspect all these values) -- 
% [num2cell(1:length(authors))' authors' magtypes' num2cell(magvals)']

% I Prefer IDC over PDE/NEIC because it has a slightly lower magnitude
% threshold according to this (possibly outdated) article, "SUMMARY OF
% THE ISC BULLETIN OF EVENTS OF 2003", from
% http://www.isc.ac.uk/docs/papers/download/2006p02/.  Also, note that
% NEIC and PDE are used interchangeable as "Author".  I believe
% technically NEIC (National Earthquake Information Center, USA) is
% the author that publishes the PDE (Preliminary Determination of
% Epicenters) catalog.

for M = {'MB', 'ML'}
    magidx = find(ismember(magtypes, M));

    if ~isempty(magidx)
        for A = {'GCMT', 'ISC', 'IDC', 'NEIC', 'PDE'}
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
        magauthor = authors{max_idx(1)};
        magtype = [upper(M{:}(1)) lower(M{:}(2))]; 
        magval = max_mag;
        return
        
    end
end

%________________________________________________________________________%


%********************************************************************%

% N.B. From http://service.iris.edu/fdsnws/event/1/, "Notice this web
% service will not be offered long term," but none of these
% alternative baseurls work for unknown reasons:
% 
% baseurl = 'http://service.scedc.caltech.edu/fdsnws/event/1/'
% baseurl = 'http://service.ncedc.org/fdsnws/event/1/'
% baseurl = 'http://earthquake.usgs.gov/fdsnws/event/1/'
% baseurl = 'http://isc-mirror.iris.washington.edu/fdsnws/event/1/'
%
% Fix when/if this breaks, I suppose.