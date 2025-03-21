function ev = writeglobalcatalog(minmag, maxmag, stime, etime, txtdir)
% ev = WRITEGLOBALCATALOG(minmag, maxmag, stime, etime, txtdir)
%
% WRITEGLOBALCATALOG queries irisFetch.Events for events within the
% specific magnitude (integer) and date ranges, and writes separate
% text files for each magnitude unit.
%
% Input:
% minmag        Minimum magnitude (def: 4), integer only
% minmag        Maximum magnitude (def: 9), integer only
% stime         Time to start query, in FDSN str format (not datetime)
%                   (def: '2018-08-01T00:00:00.000')
% etime         Time to end query, in FDSN str format (not datetime)
%                   (def: present time)
% txtdir        Directory to write M?.txt, where ? represents
%                   the magnitude unit covered by the text file,
%                   e.g., M5.txt includes M5.0 to M5.9
%                   (def: $MERMAID/events/globalcatalog)
% Output:
% *N/A*         Writes separate textfile for every magnitude unit
%                   with columns: date lat lon depth mag id
%
% See also: readglobalcatalog.m
%
% Author: Dr. Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 27-Jul-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults.
defval('minmag', 4);
defval('maxmag', 9);
defval('stime', '2018-08-01T00:00:00.000')
defval('etime', fdsndate2str(datetime('now')))
defval('txtdir', fullfile(getenv('MERMAID'), 'events', 'globalcatalog'));
[~, foo]= mkdir(txtdir);

% Sanity
if ~isint(minmag) || ~isint(maxmag)
    error('mimag and maxmag must be integers')

end
if ~ischar(stime) || ~ischar(etime)
    error('stime and etime must be character arrays, not, e.g., datetimes')

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

        % Sort with most earliest first/most recent last (the default: can't use
        % 'ascend' with cell arrays).
        [~, idx] = sort({ev.PreferredTime});
        ev = ev(idx);

    catch
        warning('No events match requested magnitude range within requested time window')

    end

    txtfile = fullfile(txtdir, sprintf('M%i.txt', mags(i)));
    if exist(txtfile, 'file') == 2
        wstatus = fileattrib(txtfile, '+w', 'a');
        if wstatus == 0
            error('Unable to allow write access to %s.', txtfile)

        end
    end

    fid = fopen(txtfile, 'w');
    if ~isempty(ev)
        % anon func to convert time string into FDSN time string.
        fdsnstr = @(xx)  [xx(1:10) 'T' xx(12:end)];
        for j = 1:length(ev)
            data = {fdsnstr(ev(j).PreferredTime), ...
                    ev(j).PreferredLatitude, ...
                    ev(j).PreferredLongitude, ...
                    ev(j).PreferredDepth, ...
                    ev(j).PreferredMagnitudeValue, ...
                    fx(strsplit(ev(j).PublicId, '='),  2)};
            fprintf(fid, fmt, data{:});

        end
    else
        fprintf(fid, '');

    end
    fclose(fid);
    fprintf('\nWrote: %s\n', txtfile)

    wstatus = fileattrib(txtfile, '-w', 'a');
    if wstatus == 0
        error('Unable to restrict write access to %s.', txtfile)

    end
end
