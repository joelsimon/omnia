function writeglobalcatalog(minmag, maxmag, stime, etime, txtdir)
% WRITEGLOBALCATALOG(minmag, maxmag, stime, etime, txtdir)
%
% WRITEGLOBALCATALOG queries irisFetch.Events for events within the
% specific magnitude (integer) and date ranges, and writes separate
% text files for each magnitude unit.
%
% Input:
% minmag        Minimum magnitude (def: 4), integer only
% minmag        Maximum magnitude (def: 9), integer only
% stime         Time to start query, in FDSN format
%                   (def: 2018-08-07T00:00:00.000)
% etime         Time to end query, in FDSN format
%                   (def: 2018-10-01T00:00:00.000)
% txtdir        Directory to write M?.txt, where ? represents
%                   the magnitude unit covered by the text file,
%                   e.g., M5.txt includes M5.0 to M5.9
%                   (def: $MERMAID/events/globalcatalog)
% Output:
% *N/A*         Writes separate textfile for every magnitude unit
%                   with columns: date lat lon depth mag id
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 05-Oct-2019, Version 2017b on GLNXA64

% I cannot tell exactly when MERMAID P-08 (the first) really started
% acquiring data, I think its this log file:
%
% 08_5B685191.LOG, L110
% [date -d @1533624310 = Tue Aug  7 02:45:10 EDT 2018]
%
% While the one previous (08_5B66F5B9.LOG) is a 1 day sink and
% surface, no data acquisition?

% Defaults.
defval('minmag', 4);
defval('maxmag', 9);
defval('stime', '2018-08-07T00:00:00.000')
defval('etime', '2019-10-01T00:00:00.000');
defval('txtdir', fullfile(getenv('MERMAID'), 'events', 'globalcatalog'));
[~, foo]= mkdir(txtdir);

% Sanity
if ~isint(minmag) || ~isint(maxmag)
    error('mimag and maxmag must be integers')

end

% File format.
fmt = ['%23s    '  , ...
       '%7.3f    ' , ...
       '%8.3f    ' , ...
       '%6.2f    ' , ...
       '%4.1f    ' , ...
       '%8s\n'];

% Fetch and write.
mags = [minmag : maxmag];
for i = 1:length(mags)
    ev = [];
    try
        ev = irisFetch.Events('minmag', mags(i), 'maxmag', mags(i) + 0.9, ...
                              'start', stime, 'end', etime);

    end

    txtfile = fullfile(txtdir, sprintf('M%i.txt', mags(i)));
    fid = fopen(txtfile, 'a+');

    if ~isempty(ev)
        for j = length(ev):-1:1
            data = {ev(j).PreferredTime, ...
                    ev(j).PreferredLatitude, ...
                    ev(j).PreferredLongitude, ...
                    ev(j).PreferredDepth, ...
                    ev(j).PreferredMagnitudeValue, ...
                    fx(strsplit(ev(j).PublicId, '='),  2)};

            fprintf(fid, sprintf(fmt, data{:}));

        end

    else
        fprintf(fid, 'NaN');

    end
end
