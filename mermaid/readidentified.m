function varargout = readidentified(filename)
% [sac, eqtime, eqlat, eqlon, eqregion, eqdepth, eqdist, eqmag, eqphase1, eqid] = ...
%     READIDENTIFIED(filename)
%
% Reads and parses event information from identified.txt, written with
% evt2txt.m, assuming Princeton MERMAID naming scheme (SAC filenames
% of length 44).
%
% Input: 
% filename   (def: $MERMAID/events/reviewed/identified/txt/identified.txt)
%
% Output:
% sac        SAC filename
% eqtime     Event rupture time ['yyyy-mm-dd HH:MM:SS']
%                (milliseconds resolution stored in .evt files)
% eqlat      Event latitude [decimal degrees]
% eqlon      Event longitude [decimal degrees]
% eqregion   Flinn-Engdahl region name at event location
% eqdepth,   Event depth [km]
% eqdist     Distance from event to station [degrees]
% eqmag      Event magnitude
% eqphase1   Name of theoretical 1st-arriving phase
% eqid       IRIS event public ID
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 09-Aug-2019, Version 2017b

% Default.
defval('filename', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                            'identified', 'txt', 'identified.txt'))


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

% Collect outputs.
outargs = {sac, eqtime, eqlat, eqlon, eqregion, eqdepth, eqdist, eqmag, eqphase1, eqid};
varargout  = outargs(1:nargout)

% *I battled textscan.m using the format from evt2txt.m with no luck;
% the problem seems to be the use of whitespace both as a delimiter
% (four spaces between every field) and within substrings ('SOUTH OF
% FIJI ISLANDS').  Various attempts at specifying 'Delimiter' and
% setting 'MultipleDelimsAsOne' proved unsuccessful.  Ergo, I will use
% my readtext.m and parse from there; takes barely any time anyway.
