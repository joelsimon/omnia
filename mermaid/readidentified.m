function varargout = readidentified(filename, starttime, endtime, reftime)
% [sac, eqtime, eqlat, eqlon, eqregion, eqdepth, eqdist, eqmag, eqphase1, ...
%  eqid, sacdate, eqdate] = READIDENTIFIED(filename, starttime, endtime, reftime)
%
% Reads and parses event information from identified.txt, written with
% evt2txt.m, assuming Princeton MERMAID naming scheme (SAC filenames
% of length 44). For all events, including those unidentified, see
% readevt2txt.m.
%
% Input:
% filename   Textfile name: 'identified.txt', output by evt2txt.m
%            (def: $MERMAID/events/reviewed/identified/txt/identified.txt)
% starttime  Inclusive start time (earliest event time to OR SAC file to consider),
%                as datetime (def: start at first event OR SAC  in catalog)
% endtime    Inclusive end time (latest event time OR SAC file to consider),
%                as datetime (def: end at last event OR SAC file in catalog)
% reftime    Reference for start and end times
%            'EVT': start/end times refer to event (hypocenter) times
%            'SAC': start/end times refer to SAC (time at first sample) times (def)
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
% Contact: jdsimon@princeton.edu
% Last modified: 22-Oct-2019, Version 2017b on GLNXA64

% Defaults.
defval('filename', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                            'identified', 'txt', 'identified.txt'))
defval('starttime', NaT('TimeZone', 'UTC')) % Dummy variable; changed below
defval('endtime', NaT('TimeZone', 'UTC')) % Dummy variable; changed below
defval('reftime', 'SAC')

% Sanity.
if ~isdatetime(starttime) || ~isdatetime(endtime)
    error('starttime and endtime must be datetimes')

end
if isempty(starttime.TimeZone) || isempty(endtime.TimeZone)
    error('starttime and endtime must have a specified time zone')

end

%% N.B.: Do not swap for textscan.m, fscanf.m etc (*see note below).
lynes = readtext(filename);

% Parse.
sac = cellfun(@(xx) xx(1:44), lynes, 'UniformOutput', false);
eqtime = cellfun(@(xx) xx(49:67), lynes, 'UniformOutput', false);
eqlat = cellfun(@(xx) str2double(xx(72:78)), lynes, 'UniformOutput', true);
eqlon = cellfun(@(xx) str2double(xx(83:90)), lynes, 'UniformOutput', true);
eqregion = strtrim(cellfun(@(xx) xx(95:128), lynes, 'UniformOutput', false));
eqdepth  = cellfun(@(xx) str2double(xx(133:138)), lynes, 'UniformOutput', true);
eqdist = cellfun(@(xx) str2double(xx(143:149)), lynes, 'UniformOutput', true);
eqmag = cellfun(@(xx) str2double(xx(154:157)), lynes, 'UniformOutput', true);
eqphase1 = strtrim(cellfun(@(xx) xx(162:167), lynes, 'UniformOutput', false));
eqid = strtrim(cellfun(@(xx) xx(172:184), lynes, 'UniformOutput', false));
eqdate = NaT(length(eqtime), 1, 'TimeZone', 'UTC');

% Get SAC (time at first sample) and EQ (hypocenter time) datetimes.
sacdate = mersac2date(sac);
eqdate = NaT(size(eqtime), 'TimeZone', 'UTC');
for i = 1:length(eqtime)
        eqdate(i) = irisstr2date(eqtime{i}, 2);

end

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

% Determine which event indices fall within the time interval of interest.
idx = find(isbetween(refdate, starttime, endtime));

% And return only those events.
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
