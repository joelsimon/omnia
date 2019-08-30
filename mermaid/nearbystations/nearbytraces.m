function [F, tr] = nearbytraces(id, txtfile)

defval('id', 10948555)
defval('txtfile', fullfile(getenv('MERMAID'), 'events', 'nearbystations', 'nearbystations.txt'))
defval('lohi', [1 5]);
defval('alignon', 'etime')
defval('ampfac', 3)
defval('revdir', fullfile(getenv('MERMAID'), 'events'))
defval('procdir', fullfile(getenv('MERMAID'), 'processed'))
defval('normlize', true)
defval('first', false)

tx = readtext(txtfile);

% Find the lines that start with #DATACENTER (they separate blocks). 
dcline = cellstrfind(tx, 'DATACENTER');

% Remove the header, the only other place where the '|' column separator exists.
tx(1:dcline(1)-1) = [];

% Loop through every line and keep the network and station names.
tx_idx = 0;
for i = 1:length(tx)
    if isempty(strfind(tx{i}, '|'))
        continue

    else
        tx_idx = tx_idx + 1;
        l = strsplit(tx{i}, '|');
        net{tx_idx} = l{1};
        sta{tx_idx} = l{2};

    end
end

% Remove duplicate stations.
[sta, uniq_idx] = unique(sta);
net = net(uniq_idx);

% Plot the baseline MERMAID record section.
[F, EQ] = recordsection(id, lohi, 'etime', ampfac);

% Every earthquake in the list is identical (but not necessarily .TaupTimes!).
EQ = EQ{1}; 
evtdate = datetime(irisstr2date(EQ(1).PreferredTime));

% Use the x-axis limits to bracket the start and end dates.
axstart = evtdate + seconds(F.ax.XLim(1));
axend = evtdate + seconds(F.ax.XLim(2));

% Convert start and end dates (datetimes) to strings.
starttime = irisdate2str(axstart);
endtime = irisdate2str(axend);

% Fetch data.
tr_full_idx = 0;
for i = 1:length(sta)
    try
        traces = irisFetch.Traces(net{i}, sta{i}, '*', 'BHZ', ...
                                  starttime, endtime, ['http://' ...
                            'service.iris.edu/'], 'federated');

    catch
        % Error.
        continue

    end
    % Success.
    tr_full_idx = tr_full_idx + 1;
    tr_full{tr_full_idx} = traces;

end

% Winnow.
tr_idx = 0;
for i = 1:length(tr_full)
    i
    % Keep the data just from the first data center.
    datacenters = fieldnames(tr_full{i})
    datacenter1 = datacenters(1)
    tr_full{i} = tr_full{i}.(datacenter1{:})
    if isempty(tr_full{i})
        continue

    end 

    % Keep the data just from the first location (e.g., '00' or '10').
    location = {tr_full{i}.location}
    location1 = location{1}
    loc1_idx = cellstrfind(location, location1)

    for j = 1:length(loc1_idx)
        tr_idx = tr_idx + 1
        tr(tr_idx) = tr_full{i}(loc1_idx(j))

    end
end        

rangey = range(F.ax.YLim);
shifty = rangey * 0.025;


hold(F.ax, 'on')
for i = 1:length(tr)
    % Hoping it's the requested starttime; not always the case.
    tr(i).startDate = datetime(datestr(tr(i).startTime), 'TimeZone', 'UTC');
    delay = tr(i).startDate - evtdate;
    [~, tr(i).distance] = grcdist([EQ.PreferredLongitude ...
                        EQ.PreferredLatitude], [tr(i).longitude ...
                        tr(i).latitude]);

    xax = xaxis(length(tr(i).data), 1/tr(i).sampleRate, seconds(delay));    
    w = hanning(length(tr(i).data));
    tr(i).xf = bandpass(w .* tr(i).data, tr(i).sampleRate, lohi(1), lohi(2));
    tr(i).normxf = norm2max(tr(i).xf);
    F.plnbtr(i) = plot(F.ax, xax, ampfac * tr(i).normxf + tr(i).distance, ...
                       'Color', [0.8 0.8 0.8])
    
end
hold(F.ax, 'off')
botz([F.plnbtr F.ph], F.ax);