function varargout = readidentified(filename, starttime, endtime, reftime, returntype, incl_prelim)
% [sac, eqtime, eqlat, eqlon, eqregion, eqdepth, eqdist, eqmag, eqphase1, eqid, sacdate, eqdate] ...
%     = READIDENTIFIED(filename, starttime, endtime, reftime, returntype, incl_prelim)
%
% Reads and parses event information from identified.txt, written with
% evt2txt.m, assuming Princeton's MERMAID naming scheme of SAC filenames of
% length 44 (+7 for the occasional preliminary-location SAC file). For all
% events, including those unidentified, see readevt2txt.m.
%
% Input:
% filename     Textfile name: 'identified.txt', output by evt2txt.m
%              (def: $MERMAID/events/reviewed/identified/txt/identified.txt)
% starttime    Inclusive start time (earliest event time to OR SAC file to consider),
%                  as datetime (def: start at first event OR SAC  in catalog)
% endtime      Inclusive end time (latest event time OR SAC file to consider),
%                  as datetime (def: end at last event OR SAC file in catalog)
% reftime      Reference for start and end times
%              'EVT': start/end times refer to event (hypocenter) times
%              'SAC': start/end times refer to SAC (time at first sample) times (def)
% returntype   'ALL': both triggered and user-requested SAC files (def)
%              'DET': triggered SAC files as determined by onboard algorithm
%              'REQ': user-requested SAC file
% incl_prelim  true to include 'prelim.sac' (def: true)
%
% Output:
% sac        SAC filename
% eqtime     Event rupture time ['yyyy-mm-dd HH:MM:SS']
%                (milliseconds resolution stored in .evt files)
% eqlat      Event latitude [decimal degrees]
% eqlon      Event longitude [decimal degrees]
% eqregion   Flinn-Engdahl region name at event location
% eqdepth    Event depth [km]
% eqdist     Distance from event to station [degrees]
% eqmag      Event magnitude
% eqphase1   Name of theoretical 1st-arriving phase
% eqid       IRIS event public ID
% sacdate    Time of first sample of seismogram, as datetime
% eqdate     eqtime, as datetime
%
% See also: readevt2txt.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 16-May-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults.
defval('filename', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                            'identified', 'txt', 'identified.txt'))
defval('starttime', NaT('TimeZone', 'UTC')) % Dummy variable; changed below
defval('endtime', NaT('TimeZone', 'UTC')) % Dummy variable; changed below
defval('reftime', 'SAC')
defval('returntype', 'ALL')
defval('incl_prelim', true)

% Sanity.
if ~isdatetime(starttime) || ~isdatetime(endtime)
    error('starttime and endtime must be datetimes')

end
if isempty(starttime.TimeZone) || isempty(endtime.TimeZone)
    error('starttime and endtime must have a specified time zone')

end
if all(~strcmpi(returntype, {'ALL', 'DET', 'REQ'}))
    error('Specify one of ''ALL'', ''DET'', or ''REQ'' for input: returntype')

end
if ~islogical(incl_prelim)
    error('Input `incl_prelim` must be logical')

end

%% N.B.: Do not swap for textscan.m, fscanf.m etc (*see note below).
lynes = readtext(filename);

% Parse.
sac = cellfun(@(xx) strtrim(xx(1:44+7)), lynes, 'UniformOutput', false);
eqtime = cellfun(@(xx) xx(49+7:67+7), lynes, 'UniformOutput', false);
eqlat = cellfun(@(xx) str2double(xx(72+7:78+7)), lynes, 'UniformOutput', true);
eqlon = cellfun(@(xx) str2double(xx(83+7:90+7)), lynes, 'UniformOutput', true);
eqregion = strtrim(cellfun(@(xx) xx(95+7:128+7), lynes, 'UniformOutput', false));
eqdepth  = cellfun(@(xx) str2double(xx(133+7:138+7)), lynes, 'UniformOutput', true);
eqdist = cellfun(@(xx) str2double(xx(143+7:149+7)), lynes, 'UniformOutput', true);
eqmag = cellfun(@(xx) str2double(xx(154+7:157+7)), lynes, 'UniformOutput', true);
eqphase1 = strtrim(cellfun(@(xx) xx(162+7:168+7), lynes, 'UniformOutput', false));
eqid = strtrim(cellfun(@(xx) xx(173+7:185+7), lynes, 'UniformOutput', false));
eqdate = NaT(length(eqtime), 1, 'TimeZone', 'UTC');

% Get SAC (time at first sample) and EQ (hypocenter time) datetimes.
sacdate = mersac2date(sac);
eqdate = irisstr2date(eqtime, 2);

% Switch which dates (SAC times or event times) to use to winnow the
% return within a specific time interval.
switch upper(reftime)
  case 'SAC'
    refdate = sacdate;

  case 'EVT'
    refdate = eqdate;

  otherwise
    error('specify either ''SAC'' or ''EVT'' for input reftime')

end

% Default start and end time to include entire catalog.
if isnat(starttime)
    starttime = min(refdate);

end
if isnat(endtime)
    endtime = max(refdate);

end

% Determine which indices fall within the time interval of interest.
idx = find(isbetween(refdate, starttime, endtime));

% Separate by return type if requested.
if ~strcmpi(returntype, 'ALL')
    ridx = cellstrfind(sac, sprintf('MER.%s.*sac', upper(returntype)));
    idx = intersect(idx, ridx);

end

% Remove 'prelim.sac' files, if they are unwanted.
if ~incl_prelim
    pidx = cellstrfind(sac, 'prelim.sac');
    idx = setdiff(idx, pidx);

end

% Return parsed results.
sac = sac(idx);
eqtime = eqtime(idx);
eqlat = eqlat(idx);
eqlon = eqlon(idx);
eqregion = eqregion(idx);
eqdepth = eqdepth(idx);
eqdist = eqdist(idx);
eqmag = eqmag(idx);
eqphase1 = eqphase1(idx);
eqid = eqid(idx);
sacdate = sacdate(idx);
eqdate = eqdate(idx);

% Collect outputs.
outargs = {sac, eqtime, eqlat, eqlon, eqregion, eqdepth, eqdist, ...
           eqmag, eqphase1, eqid, sacdate, eqdate};
varargout  = outargs(1:nargout);

% *I battled textscan.m using the format from evt2txt.m with no luck;
% the problem seems to be the use of whitespace both as a delimiter
% (four spaces between every field) and within substrings ('SOUTH OF
% FIJI ISLANDS').  Various attempts at specifying 'Delimiter' and
% setting 'MultipleDelimsAsOne' proved unsuccessful.  Ergo, I will use
% my readtext.m and parse from there; takes barely any time anyway.
