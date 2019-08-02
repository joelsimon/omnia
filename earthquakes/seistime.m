function [seisdate, seiststr, seisertime, refdate, evtdate] = seistime(h)
% [seisdate, seiststr, seisertime, refdate, evtdate] = SEISTIME(h)
%
% SEISTIME returns the UTC time of the first and last SAMPLES of a SAC
% seismogram, i.e. the reference time of the SAC file (which may be
% arbitrary), plus any offset time in seconds of the first/last sample
% as designated by "B"/"E" field in SAC header.
%
%            seconds(seisdate.B - refdate)  == h.B
%
% SEISTIME will also returns the reference time in the SAC header, and
% maybe return the event time (reference time - h.O) if h.O (origin
% time) is filled.
%
% N.B.: Because seisdate.B is the time at the first sample -->
%
%   time relative to refdate: xaxis(h.NPTS, h.DELTA, h.B)
%   time relative to seisdate.B: xaxis(h.NPTS, h.DELTA, 0)
%
% First three outputs are same data in three formats: a datetime array
% via datetime.m, a PDE/ISC-formatted string via datestr.m, and a
% serial date number via datenum.m.  Note datetime uses 'SSS' for
% milliseconds format, while datestr.m uses 'FFF' for fractional
% seconds (same if precision is 3, which it is in SAC headers).
%
% datetime -- useful for arithmetic between points in time
% datestr  -- useful for annotating figures and writing text files
% datenum  -- useful for date arithmetic and comparison (e.g., sorting)
%
% Input:
% h           SAC header structure returned from readsac.m
%
% Outputs:
% seisdate    Datetime structure of seismogram GMT start (.B) and end times (.E)
%                 seisdate.B == absolute time of first sample in seismogram, or 
%                 the reference time in header plus the offset time (B) in header
%                 seisdate.E == absolute time of last sample in seismogram, or
%                 the reference time in header plus the offset time (E) in header
% seiststr    Same as above, in datestr format, specifically that
%                 used in PDE and ISC catalogs (ISF data type)
% seisertime  Same as above, in serial time (datenum) format
% refdate     Reference time of the SAC header in datetime format
% evtdate     Time of event (origin), if h.O field filled (def: [])
%                evtdate = refdate + seconds(h.O)
% _____________________
% 
% N.B.: Datetime, by default, does not show millisecond
% precision (but it does store it).
%
% >> foo = datetime('2014 987', 'InputFormat', 'uuuu SSS') - ...
%          datetime('2014 986', 'InputFormat', 'uuuu SSS')
% foo = 
%       duration
%       00:00:00
%
% >> milliseconds(foo)
%
% ans = 
%      1
%
% Also: "The symbolic identifiers describing date and time formats are
% different from those that describe the display formats of datetime
% arrays." 
%
% https://www.mathworks.com/help/matlab/ref/datestr.html#btenptl-1-formatOut
%
% This is annoying; 'uuuu' in datetime.m is 'yyyy' in datestr.m
% _____________________
%
% Ex:
%    [~, h] = readsac('m12.20130416T105310.sac')
%    [seisdate, seiststr, seisertime, refdate] = SEISTIME(h)
%
% See also: arrivaltime.m, readsac.m
% 
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 17-Sep-2018, Version 2017b
% Documented 2017.2 pg. 45

% NOTES ABOUT TIMING IN SAC
% From https://ds.iris.edu/files/sac-manual/manual/tutorial.html -- 
%
% "How SAC Handles Time:
%
% The SAC header contains a reference or zero time, stored as six
% integers (NZYEAR, NZJDAY, NZHOUR, NZMIN, NZSEC, NZMSEC), but
% normally printed in an equivalent alphanumeric format (KZDATE and
% KZTIME). This can be set to any reference time you wish. It is often
% the time of the first data point, but can also be the origin time of
% the event, midnight, your birthday, etc. It does not even have to be
% a time encompassed by the data itself. ALL OTHER TIMES ARE OFFSETS
% IN SECONDS FROM THIS REFERENCE TIME AND ARE STORED AS FLOATING POINT
% VALUES IN THE HEADER."
%
% Ergo, add h.B to every sample in the seismogram to properly account
% for the offset from reference time.

% Generate date formats, pull times from SAC header, feed to datetime.m
tims = [h.NZYEAR h.NZJDAY h.NZHOUR h.NZMIN h.NZSEC h.NZMSEC];
if any(tims == -12345)
    error('Null value (-12345) in header time.')
end
headertimes = num2str(tims);

% Use ISO year (u) not Gregorian year (y) per MATLAB 2017b warning.
datefmt = ['uuuu DDD HH mm ss SSS'];
refdate = datetime(headertimes, 'InputFormat', datefmt, 'TimeZone', 'UTC');

% From SAC manual -- "All other times are offsets in seconds from this
% reference time and are stored as floating point values in the
% header."
seisdate.B = refdate + seconds(h.B);
seisdate.E = refdate + seconds(h.E);

% Put into serial time.
seisertime.B = datenum(seisdate.B);
seisertime.E = datenum(seisdate.E);

% Put into time format as printed in PDE NEIC catalog.
seiststr.B = pdetime2str(seisdate.B);
seiststr.E = pdetime2str(seisdate.E);

% Grab the event time, if h.O (event rupture time, offset in seconds
% from reference time) is filled.
if exist('h.O') || h.O ~= -12345 
    evtdate = refdate + seconds(h.O);

else
    evtdate = [];

end

