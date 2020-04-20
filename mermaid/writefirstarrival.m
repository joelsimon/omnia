function writefirstarrival(s, redo, filename, wlen, lohi, sacdir, ...
                           evtdir, EQ, bathy, wlen2, fs)
% WRITEFIRSTARRIVAL(s, redo, filename, wlen, lohi, sacdir, evtdir, EQ, bathy, wlen2, fs)
%
% WRITEFIRSTARRIVAL writes the output of firstarrival.m a text file.
%
% N.B. in describing the text file below the "true" arrival time
% (found with cpest.m) is labeled "dat", while the theoretical arrival
% time of the first-arriving phase is labeled "syn".
%
% Input:
% s        Cell array of identified SAC filenames (def: revsac(1))
% redo     true: delete and remake the text file
%          false: append new lines to the existing text file unless
%              that SAC file name already exists in the text file (def)
% filename Output text file name (def: $MERMAID/.../firstarrival.txt)
% wlen     Window length [s] (def: 30)
% lohi     1x2 array of corner frequencies (def: [1 5]])
% sacdir   Directory containing (possibly subdirectories)
%              of .sac files (def: $MERMAID/processed)
% evtdir   Directory containing (possibly subdirectories)
%              of .evt files (def: $MERMAID/events)
% EQ      Cell array (same size as 's') of EQ structs, if they are
%             not reviewed, or one different from saved is preferred
%             (def: [] to retrieve reviewed EQ struct from evtdir with getevt.m)
% bathy    logical true apply bathymetric travel time correction,
%              computed with bathtime.m (def: true)
% wlen2    Length of second window, starting at the 'dat', the time of
%              the first arrival, in which to search for maxc_y [s]
%              (def: 1)
% fs       Re-sampled frequency (Hz) after decimation, or []
%              to skip decimation (def: [])
%
% Output:
% Text file with the following columns (firstarrivals.m outputs in parentheses):
%    (1) SAC filename
%    (2) Theoretical 1st-arriving phase name (ph)
%    (3) AIC arrival-time pick, in seconds into seismogram with
%        xaxis = xax(h.NPTS, h.DELTA, h.B)
%    (4) Travel time residual: dat - syn (tres)
%    (5) Theoretical travel time in seconds of (2), according to taupTime.m
%    (6) Time difference between reference model with bathymetry and
%        reference model w/o bathymetry (tadj)
%    (7) Time delay between cpest.m arrival time estimate and
%        maximum absolute amplitude (delay)
%    (8) 2-standard deviation error estimation per M1 method (twosd)
%    (9) Maximum abs. amplitude in the time window starting at
%        "dat" and extending wlen2 seconds (maxc_y)
%    (10) Signal-to-noise ratio of "dat" in a time window centered on "syn"
%        (SNR), defined as ratio of biased variance of signal/noise
%        (see wtsnr.m)
%    (11) IRIS event ID
%    (12) Incomplete window flag (sentinel value: 'winflag')
%    (13) Taper flag (sentinel value: 'tapflag')
%    (14) Potential null-value flag, x = 0 (sentinel value: 'zerflag')
%
% See also: firstarrival.m, readfirstarrival.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu | joeldsimon@gmail.com
% Last modified: 20-Apr-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults.
defval('s', revsac(1))
defval('redo', false)
defval('filename', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                            'identified', 'txt', 'firstarrival.txt'))
defval('wlen', 30)
defval('lohi', [1 5])
defval('sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('EQ', [])
defval('bathy', true)
defval('wlen2', 1)
defval('fs', [])

% Textfile format.
fmt = ['%44s    ' , ...
       '%5s    ' ,  ...
       '%7.2f   ' , ...
       '%6.2f   ' , ...
       '%8.2f    ', ...
       '%6.2f   ' , ...
       '%6.2f   ' , ...
       '%5.2f   ' , ...
       '%+19.12E    ' , ...
       '%18.12E    '  , ...
       '%8s    ' , ...
       '%i    ', ...
       '%3i    ', ...
       '%3i\n'];

% Sort out if deleting, appending to, or creating output file.
file_exists = (exist(filename,'file') == 2);
if file_exists
    % Grant write access to file.
    fileattrib(filename, '+w')

    if redo
        % Clear existing contents.
        fid = fopen(filename, 'w');
        fprintf('Deleted:\n%s\n\n', filename);
        verb = 'Wrote';

    else
        % Append to existing contents.
        fid = fopen(filename, 'a');
        verb = 'Appended';

    end
else
    % Generate new file.
    fid = fopen(filename, 'w+');
    fprintf('Created:\n%s\n\n', filename);
    verb = 'Wrote';

end

% Loop over every SAC file, skipping those that already exist in the
% output file, and concatenating the lines of all others to be written
% in one fell-swoop later.
wline = [];
wlines = [];
parfor i = 1:length(s)
    sac = s{i};
    if ~isempty(EQ)
        single_EQ = EQ{i};

    else
        single_EQ = [];

    end

    % Skip SAC files that are already written.
    if ~redo && ~isempty(mgrep(filename, strippath(sac)))
        continue

    end

    % Concatenate the write lines.
    wline = single_wline(sac, true, wlen, lohi, sacdir, evtdir, single_EQ, bathy, wlen2, fs, fmt);
    wlines = [wlines wline];

end

if isempty(wlines)
    % Nothing to do if there are no new lines to write.
    fprintf('No new lines written to:\n%s\n', filename)

else
    % Append new lines to the text file.
    fprintf(fid, wlines);
    fclose(fid);

    % Exit with informative printout.
    numlines = length(regexp(wlines, '\n'));
    fprintf('%s %i %s to:\n%s\n', verb, numlines, plurals('line', ...
                                                      numlines), filename)
end

% Use a system call to sort the new entries.
[status, result] = system(sprintf('sort -k1 -n -o %s %s', filename, filename));
if status ~= 0
    warning('unable to sort %s\nflags may differ on non-Linux machines', filename)

end

% Write protect the file.
fileattrib(filename, '-w')

%_______________________________________________________________________________%
function wline = single_wline(sac, ci, wlen, lohi, sacdir, evtdir, single_EQ, bathy, wlen2, fs, fmt)
% Local call to, and formatting of, firstarrival.m

% Collect.
[tres, dat, ~, tadj, ph, delay, twosd, ~, ~, ~, maxc_y, SNR, EQ, ~, ~, ~, winflag, tapflag, zerflag] = ...
    firstarrival(sac, true, wlen, lohi, sacdir, evtdir, single_EQ, bathy, wlen2, fs);
publicid = fx(strsplit(EQ(1).PublicId, '='),  2);
tptime = EQ(1).TaupTimes(1).time;

% Parse.
data = {strippath(sac), ...
        ph,             ...
        dat,            ...
        tres,           ...
        tptime,         ...
        tadj,           ...
        delay,          ...
        twosd,          ...
        maxc_y,         ...
        SNR,            ...
        publicid,       ...
        winflag,        ...
        tapflag,        ...
        zerflag};

% Format.
wline = sprintf(fmt, data{:});
