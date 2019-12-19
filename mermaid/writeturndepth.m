function writeturndepth(sac, evtdir, savefile)
% WRITETURNDEPTH(sac, evtdir, savefile)
%
% Writes a textfile of turning depths and locations for the first
% phase of the first event associated with each SAC file in the
% input list.
%
% Input:
% sac       Cell array of fullpath SAC filenames
% evtdir    Path to directory containing 'raw/' and 'reviewed'
%               subdirectories (def: $MERMAID/events/)
% savefile  Filename of textfile to create
%
% Output:
% Textfile with columns:
% (1) SAC filename
% (2) phase name
% (3) turning depth (km)
% (4) latitude at turning depth (decimal degrees)
% (5) longitude at turning depth (decimal degrees)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 19-Dec-2019, Version 2017b on MACI64

% Default.
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))

% Textfile format.
fmt = ['%44s    ', ...
       '%5s    ', ...
       '%7.2f    ', ...
       '%7.3f    ', ...
       '%8.3f\n'];


% If the file exists it is write-protected; lift that restriction.
if exist(savefile, 'file') == 2
    wstatus = fileattrib(savefile, '+w', 'a');
    if wstatus == 0
        error('Unable to allow write access to %s.', savefile)

    end
end

% Open the save file without auto flushing; discard contents.
fid = fopen(savefile, 'W');

for i = 1:length(sac)
    % Fetch event info associated with this SAC file.
    EQ = getevt(sac{i}, evtdir);
    if  ~isstruct(EQ) && ~isempty(EQ) && isnan(EQ)
        error('No reviewed .evt file associated with %s', sac{i});

    end

    % Default output.
    phasename = NaN;
    turndepth = NaN;
    turnlat = NaN;
    turnlon = NaN;

    % There is no turning depth for an upgoing phase (lowercase 'p').
    if ~isempty(EQ) && ~isempty(EQ(1).TaupTimes) ...
            && ~strcmp(EQ(1).TaupTimes(1).phaseName, 'p')

        % Fetch SAC metadata.
        [~, h] = readsac(sac{i});

        % Compute turning depth for the first phase of the first event only.
        tp = taupPierce(EQ(1).TaupTimes(1).model, ...
                        EQ(1).TaupTimes(1).srcDepth, ...
                        EQ(1).TaupTimes(1).phaseName, ...
                        'sta', ....
                        [h.STLA h.STLO], ...
                        'evt', ...
                        [EQ(1).PreferredLatitude EQ(1).PreferredLongitude], ...
                        'turn');

        % Potentially multiple arrivals of same phase (e.g., triplication);
        % the first-arriving phase only.
        tp = tp(1);

        % Find the index of the turning depth.
        turn_idx = find(tp.pierce.depth);

        % Parse outputs.  Most usually there will be a single turning depth
        % but on occasion there may be two depths of equal value at
        % slightly different locations; take their average.
        phasename = tp.phaseName;
        turndepth = mean(tp.pierce.depth(turn_idx));
        turnlat = mean(tp.pierce.latitude(turn_idx));
        turnlon = mean(tp.pierce.longitude(turn_idx));

    end
    % Collect the data.
    data = {strippath(sac{i}), ...
            phasename, ...
            turndepth, ...
            turnlat, ...
            turnlon};

    % Write the relevant line.
    fprintf(fid, fmt, data{:});

end

% Close the file and restrict write-access.
fclose(fid);
wstatus = fileattrib(savefile, '-w', 'a');
if wstatus == 0
    error('Unable to restrict write access to %s.', savefile)

end
