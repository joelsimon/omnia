% #DATACENTER=IRISDMC,http://ds.iris.edu
% II|MSVF|-17.744801|178.052795|801.1|Monasavu, Fiji|1994-05-24T00:00:00|2599-12-31T23:59:59

sacdir = fullfile(getenv('HUNGA'), 'sac');

network = 'II';
station = 'MSVF';
channel = 'BHZ';
location = '00';

DATASELECTSERVICE = 'http://service.iris.edu/fdsnws/dataselect/1/';
STATIONSERVICE = 'http://service.iris.edu/fdsnws/station/1/';

evt_isodate = '2022-01-15T04:14:45Z';
evt_date = iso8601str2date(evt_isodate);

starttime = irisdate2str(evt_date - days(1));
endtime = irisdate2str(evt_date + days(1));
traces = irisFetch.Traces(network, station, location, ...
                          channel, starttime, endtime, ...
                          ['DATASELECTURL:' DATASELECTSERVICE], ...
                          ['STATIONURL:' STATIONSERVICE]);


% Keep only nonempty traces.
ct = 0
if ~isempty(traces)
    ct = ct + 1;
    irisFetch.Trace2SAC(traces(ct), fullfile(sacdir, 'nearby'));

end
