function fetchsacpz(tr, wdir)
% FETCHSACPZ(tr, wdir)
%
% Fetch SACPZ file from http://service.iris.edu/irisws/sacpz/1/query for single
% trace from irisFetch.Traces.
%
% Input:
% tr       Trace structure from irisFetch.Traces
% wdir     Write directory to save .pz file (def: pwd)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu | joeldsimon@gmail.com
% Last modified: 07-May-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('wdir', pwd);
[~, foo] = mkdir(wdir);
baseurl = 'http://service.iris.edu/irisws/sacpz/1/query?';

for i = 1:length(tr)
    % Station parameters.
    net = tr(i).network;
    sta = tr(i).station;
    loc = tr(i).location;
    cha = tr(i).channel;

    % Time parameters.
    startdate = datetime(datestr(tr(i).startTime));
    starttime = fdsndate2str(startdate);
    endtime = fdsndate2str(datetime(datestr(tr(i).endTime)));

    % Compile query.
    query = sprintf('net=%s%ssta=%s%sloc=%s%scha=%s%sstart=%s%send=%s', ...
                    net,'&',  sta, '&', loc, '&', cha, '&', starttime, '&', endtime);


    % Pole-zero filename based on start time of SAC file.
    [yr, ~, ~, hr, mi, se] = datevec(tr(i).startTime);
    dy = day(datetime(datestr(tr(i).startTime)), 'dayofyear');
    se = strsplit(num2str(se), '.');
    se = sprintf('%02s', se{1});
    fname = fullfile(wdir, sprintf('%s.%s.%s.%s.%4i.%03i.%02i.%02i.%s.sacpz', ...
                               net, sta, loc, cha, yr, dy, hr, mi, se));

    % Make the request.
    switch computer
      case 'GLNXA64'
        [a, b] = system(sprintf('wget ''%s'' -O %s', [baseurl query], fname));

      case 'MACI64'
        [a, b] = system(sprintf('curl ''%s'' -o %s', [baseurl query], fname));

      otherwise
        error('Unrecognized computer type')

    end
end
