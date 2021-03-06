function varargout = readevt2txt(filename, starttime, endtime, returntype)
% [sac, eqtime, eqlat, eqlon, eqregion, eqdepth, eqdist, eqmag, ...
%      eqphase1, eqid, sacdate, eqdate] = READEVT2TXT(filename, starttime, endtime, returntype)
%
% Reads and parses event information from 'all.txt', written with
% evt2txt.m, assuming Princeton MERMAID naming scheme (SAC filenames
% of length 44).  For identified events only, see readidentified.m.
%
% The start and end times here consider ONLY the SAC file times (UTC
% time of first sample); not the event times (because event times do
% not exist for unidentified SAC files).  This corresponds to the
% 'SAC' option, not the 'EVT', option in readidentified.
%
% Input:
% filename   Textfile name: 'all.txt', output by evt2txt.m
%            (def: $MERMAID/events/reviewed/all.txt)
% starttime  Inclusive start time (earliest SAC time to consider),
%                as datetime (def: start at first SAC file in catalog)
% endtime    Inclusive end time (latest SAC time to consider),
%                as datetime (def: end at SAC file in catalog)
% returntype   'ALL': both triggered and user-requested SAC files (def)
%              'DET': triggered SAC files as determined by onboard algorithm
%              'REQ': user-requested SAC file
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
% See also: readidentified.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 05-Mar-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default.
defval('filename', fullfile(getenv('MERMAID'), 'events', 'reviewed', 'all.txt'))
defval('starttime', NaT('TimeZone', 'UTC'))
defval('endtime', NaT('TimeZone', 'UTC'))
defval('returntype', 'ALL')

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
eqphase1 = strtrim(cellfun(@(xx) xx(162+7:167+7), lynes, 'UniformOutput', false));
eqid = strtrim(cellfun(@(xx) xx(172+7:184+7), lynes, 'UniformOutput', false));

% Get SAC (time at first sample) and EQ (hypocenter time) datetimes.
sacdate = mersac2date(sac);
eqdate = NaT(length(eqtime), 1, 'TimeZone', 'UTC');
for i = 1:length(eqtime)
    if ~strcmp(eqid{i}, 'NaN')
        eqdate(i) = irisstr2date(eqtime{i}, 2);

    end
end

% Default start and end time to include entire catalog.
if isnat(starttime)
    starttime = min(sacdate);

end
if isnat(endtime)
    endtime = max(sacdate);

end

% Determine which indices fall within the time interval of interest.
idx = find(isbetween(sacdate, starttime, endtime));

% Separate by return type if requested.
if ~strcmpi(returntype, 'ALL')
    ridx = cellstrfind(sac, sprintf('MER.%s.*sac', upper(returntype)));
    idx = intersect(idx, ridx);

end

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
