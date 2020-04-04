function [seisdate, seiststr, seisertime, refdate, evtdate] = seistime(h)
% [seisdate, seiststr, seisertime, refdate, evtdate] = SEISTIME(h)
%
% SEISTIME returns the UTC time of the first and last SAMPLES of a SAC
% seismogram, i.e. the reference time of the SAC file (which may be
% arbitrary), plus any offset time in seconds of the first/last sample
% as designated by "B"/"E" field in SAC header.
%
%           seconds(seisdate.B - refdate) == h.B
%
% SEISTIME will also returns the reference time in the SAC header, and
% maybe return the event time (reference time - h.O) if h.O (origin
% time) is filled.
%
% NB, because seisdate.B is the time at the first sample -->
%
% Ex2: x-axis time relative to refdate: xaxis(h.NPTS, h.DELTA, h.B)
% Ex3: x-axis time relative to first sample: xaxis(h.NPTS, h.DELTA, 0)
%
% First three outputs are same data in three formats: a datetime array
% via datetime.m, a PDE/ISC-formatted string via datestr.m, and a
% serial date number via datenum.m.  Note datetime uses 'SSS' for
% milliseconds format, while datestr.m uses 'BUFF' for fractional
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
% Ex1:
%    [~, h] = readsac('m12.20130416T105310.sac')
%    [seisdate, seiststr, seisertime, refdate] = SEISTIME(h)
%
% Ex2: (plot on x-axis where the time of the first sample is in reference to refdate)
%    [x, h] = readsac('centcal.1.BHZ.SAC');
%    seisdate = SEISTIME(h);
%    xax = xaxis(h.NPTS, h.DELTA, h.B);
%    plot(xax, x); title('First sample at seconds offset from refdate')
%
% Ex3: (plot on x-axis where the time of the first sample is in reference to seisdate.B)
%    [x, h] = readsac('centcal.1.BHZ.SAC');
%    seisdate = SEISTIME(h);
%    xax = xaxis(h.NPTS, h.DELTA, 0);
%    plot(xax, x); title('First sample at seconds offset from seisdate.B')
%
% In both cases, seisdate.B and seisdate.E are unchanged -- they are absolute
% datetimes.  What changes is the relative time that you place the first sample.
%
% See also: arrivaltime.m, readsac.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 04-Apr-2020, Version 2017b on MACI64
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
nullval = -12345;
tims = [h.NZYEAR h.NZJDAY h.NZHOUR h.NZMIN h.NZSEC h.NZMSEC];

% Check for missing data.
if any(tims == nullval)
    error('Null value (-12345): h.NZ*')

end
if h.B == nullval;
    error('Null value (-12345): h.B')

end
if h.NPTS == nullval
    error('Null value (-12345): h.NPTS')

end
if h.DELTA == nullval
    error('Null value (-12345): h.DELTA')

end
headertimes = num2str(tims);

% I choose to NOT use h.E (even if it is included in the header, which it is not
% always) because the data may have been decimated, and it is common to then
% update the header-timing variables h.NPTS, and h.DETLA, however the updated
% h.E (which may only vary by a sample...) may not have been overwritten. Just
% to be safe...
xax = xaxis(h.NPTS, h.DELTA, h.B);
h.E = xax(end);

% Use ISO year (u) not Gregorian year (y) per MATLAB 2017b warning.  The refdate
% is the reference time in the SAC header -- it doesn't necessarily correspond to
% anything (an event, the first sample, etc.).
datefmt = ['uuuu DDD HH mm ss SSS'];
refdate = datetime(headertimes, 'InputFormat', datefmt, 'TimeZone', 'UTC');

% From SAC manual -- "All other times are offsets in seconds from this reference
% time and are stored as floating point values in the header."
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
