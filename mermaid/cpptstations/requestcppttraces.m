function reqfile = requestcppttraces(id, reqdir, cpptfile, evtdir, model, ph)
% reqfile = REQUESTCPPTTRACES(id, reqdir, cpptfile, evtdir, model, ph)
%
% Write textfiles for CPPT data requests.
%
% Each textfile corresponds to a single instrument and has three columns:
% (1) starttime: five minutes before first arrival
% (2)   endtime: ten minutes after first arrival
% (3)        ID: corresponding event id
%
% Input:
% id       Cell array of IRIS public ID numbers as char
% reqdir   Directory to store request-textfiles
%              (def: $MERMAID/events/cpptstations/requests)
% cpptfile Filename containing CPPT stations' location info
%              (def: $MERMAID/events/cpptstations/cpptstations.txt)
% evtdir   Path to directory containing 'raw/' and 'reviewed'
%              subdirectories (def: $MERMAID/events/)
% model    Taup model (def: 'ak135')
% ph       Taup phases (def: defphases)
%
% Output:
% *N/A*    Writes textfiles for each instrument listed in cpptfile,
%              named as instrument name + UTC time that file was written
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 21-Jan-2020, Version 2017b on GLNXA64
% Documented & verified: 2017.1 pg. 151; 2017.2 pg. 89

% Defaults.
defval('id', {'10932551'})
defval('reqdir', fullfile(getenv('MERMAID'), 'events', 'cpptstations', 'requests'))
defval('cpptfile', fullfile(getenv('MERMAID'), 'events', 'cpptstations', 'cpptstations.txt'))
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('model', 'ak135')
defval('ph', defphases)

% Keep only the first EQ struct for each ID: their metadata may differ
% in origin time slightly depending on catalog and when they were last
% queried, but they should all be roughly the same.
for j = 1:length(id)
    if ~ischar(id{j})
        id{j} = num2str(id{j});

    end
    [~, tmp_EQ] = getsacevt(id{j}, evtdir);
    EQ{j} = tmp_EQ{1}(1);
    evtdate{j} = irisstr2date(EQ{j}.PreferredTime);

end

% Retrieve CPPT station locations.
[sta, lat, lon] = parsecpptstations(cpptfile);

% Make parent directory if necessary; state textfile format;  nab current time.
[~, foo] = mkdir(reqdir);
fmt = '%23s    %23s    %8s\n';
pwt = fdsndate2str(datetime('now', 'TimeZone', 'UTC'));

for i = 1:length(sta)
    % Generate textfile name as station name + current UTC time.
    reqfile{i} = fullfile(reqdir, [sta{i} '_' pwt 'UTC.txt']);

    % Open textfile for this station.
    fid = fopen(reqfile{i}, 'w+');

    for j = 1:length(id)
        % Compute theoretical arrival times of the requested phases at
        % this station.
        tt = taupTime(model, EQ{j}.PreferredDepth, ph, ...
                      'station', [lat(i) lon(i)], ...
                      'event', [EQ{j}.PreferredLatitude EQ{j}.PreferredLongitude]);

        % Move to next station if there exist no phase arrivals of the type
        % requested at this station for this event.
        if isempty(tt)
            warning('No phases found associated ID %s at station %s', id{j}, sta{i})
            continue

        end

        % Use the the first-arriving phase as the time reference.
        first_TaupTime = tt(1);
        firstarrival_date = evtdate{j} + seconds(first_TaupTime.time);

        % Base the query time for the traces off the time of the
        % first-arriving phase.
        starttime = fdsndate2str(firstarrival_date - minutes(5));
        endtime = fdsndate2str(firstarrival_date + minutes(10));

        % Write the line.
        data = {starttime, endtime, id{j}};
        fprintf(fid, fmt, data{:});

    end
    fclose(fid);

    % Restrict write access to the file.
    writeaccess('lock', reqfile{i});
    disp(reqfile{i})

end
reqfile = reqfile(:);
