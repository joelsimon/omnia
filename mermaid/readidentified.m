function varargout = readidentified(filename, starttime, endtime)
% [sac, eqtime, eqlat, eqlon, eqregion, eqdepth, eqdist, eqmag, ...
%      eqphase1, eqid, eqdate] = READIDENTIFIED(filename, starttime, endtime)
%
% Reads and parses event information from identified.txt, written with
% evt2txt.m, assuming Princeton MERMAID naming scheme (SAC filenames
% of length 44).
%
% Input:
% filename   Textfile name
%            (def: $MERMAID/events/reviewed/identified/txt/identified.txt)
% starttime  Inclusive start time (earliest event time to consider),
%                as datetime (def: start at first line of identified.txt)
% endtime    Inclusive end time (latest event time to consider),
%                as datetime (def: start at first line of identified.txt)
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
% eqdate     eqtime, as datetime
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 21-Oct-2019, Version 2017b on MACI64

% Default.
defval('filename', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                            'identified', 'txt', 'identified.txt'))
defval('starttime', NaT('TimeZone', 'UTC'))
defval('endtime', NaT('TimeZone', 'UTC'))

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
for i = 1:length(eqtime)
    eqdate(i) = irisstr2date(eqtime{i}, 2);

end

% Default start and end time to include entire catalog; defval.m
% does not overwrite a non-empty input.
if isnat(starttime)
    starttime = min(eqdate);

end
if isnat(endtime)
    endtime = max(eqdate);

end

% Determine which event indices fall within the time interval of interest.
idx = find(isbetween(eqtime, starttime, endtime));

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
           eqmag, eqphase1, eqid, eqdate};
varargout  = outargs(1:nargout);

% *I battled textscan.m using the format from evt2txt.m with no luck;
% the problem seems to be the use of whitespace both as a delimiter
% (four spaces between every field) and within substrings ('SOUTH OF
% FIJI ISLANDS').  Various attempts at specifying 'Delimiter' and
% setting 'MultipleDelimsAsOne' proved unsuccessful.  Ergo, I will use
% my readtext.m and parse from there; takes barely any time anyway.
