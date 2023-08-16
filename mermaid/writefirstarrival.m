function writefirstarrival(s, redo, filename, wlen, lohi, sacdir, ...
                           evtdir, EQ, bathy, wlen2, fs, popas, pt0)
% WRITEFIRSTARRIVAL(s, redo, filename, wlen, lohi, sacdir, evtdir, EQ, ...
%                   bathy, wlen2, fs, popas, pt0)
%
% WRITEFIRSTARRIVAL writes the output of firstarrival.m a text file.
%
% N.B. in describing the text file below the "true" arrival time
% (found with cpest.m) is labeled "dat", while the theoretical arrival
% time of the first-arriving phase is labeled "syn".
%
% Input: (see `firstarrival.m` for defaults)
% s        Cell array of identified SAC filenames
%              (def: `revsac(1, sacdir, evtdir, 'ALL')`; or the defaults therein)
% redo     true: delete and remake the text file
%          false: add new lines to the existing text file unless
%              that SAC file name already exists in the text file (def)
% filename Output text file name (def: $MERMAID/.../firstarrival.txt)
% wlen     Window length [s]
% lohi     1x2 array of corner frequencies, or NaN to skip bandpass
% sacdir   Directory containing (possibly subdirectories) of .sac files
% evtdir   Directory containing (possibly subdirectories) of .evt files
% EQ       Cell array (same size as 's') of corresponding EQ structs
% bathy    logical true apply bathymetric travel time correction,
%              computed with bathtime.m
% wlen2    Length of second window, starting at the 'dat', the time of
%              the first arrival, in which to search for maxc_y [s]
% fs       Re-sampled frequency (Hz) after decimation, or [] to skip decimation
% popas    1 x 2 array of number of poles and number of passes for bandpass,
%              or NaN if no bandpass
% pt0      Time in seconds assigned to first sample of X-xaxis
%
% Output:
% Text file with the following columns (firstarrivals.m outputs in parentheses):
%    (1) SAC filename
%    (2) Theoretical 1st-arriving phase name (ph)
%    (3) AIC arrival-time pick, in seconds on a time axis defined by
%        xaxis = xax(h.NPTS, h.DELTA, pt0)
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
%    (15) Time in seconds assigned to first sample of X-xaxis ('pt0')
%
% See also: firstarrival.m, readfirstarrival.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 16-Aug-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults.
defval('sacdir', [])
defval('evtdir', [])
defval('s', revsac(1, sacdir, evtdir, 'ALL'))
defval('redo', false)
defval('filename', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                            'identified', 'txt', 'firstarrival.txt'))
% Default the rest as empties to be filled in firstarrival.m
defval('wlen', [])
defval('lohi', [])
defval('EQ', [])
defval('bathy', [])
defval('wlen2', [])
defval('fs', [])
defval('popas', [])
defval('pt0', 0)

% Make textfile directory, if required.
fdir = fileparts(filename);
if exist(fdir, 'dir') ~= 7
    mkdir(fdir)

end

% Textfile format.
fmt = ['%-45s    ' , ...
       '%11s    ' ,  ...
       '%7.2f   ' , ...
       '%6.2f   ' , ...
       '%8.2f    ', ...
       '%6.2f   ' , ...
       '%6.2f   ' , ...
       '%5.2f   ' , ...
       '%+19.12E    ' , ...
       '%18.12E    '  , ...
       '%8s    ' , ...
       '%1i    ', ... % winflag: can only be int
       '%3i    ', ... % tapflag: can be NaN
       '%3i    ', ... % zerflag: can be NaN
       '%+6.3f\n'];

% Sort out if deleting, adding to, or creating output file.
if exist(filename, 'file') == 2
    % Grant write access to file.
    writeaccess('unlock', filename, false)

    if redo
        % Clear existing contents.
        fid = fopen(filename, 'w');
        fprintf('Deleted:\n%s\n\n', filename);
        verb = 'Wrote';

    else
        % Add to existing contents.
        fid = fopen(filename, 'a');
        verb = 'Added';

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
    if contains(sac, 'prelim')
        continue

    end

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
    wline = single_wline(sac, true, wlen, lohi, sacdir, evtdir, single_EQ, bathy, wlen2, fs, popas, pt0, fmt);
    wlines = [wlines wline];

end

if isempty(wlines)
    % Nothing to do if there are no new lines to write.
    fprintf('No new lines written to:\n%s\n', filename)

else
    % Add new lines to the text file.
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
writeaccess('lock', filename, false)

%_______________________________________________________________________________%
function wline = single_wline(sac, ci, wlen, lohi, sacdir, evtdir, single_EQ, bathy, wlen2, fs, popas, pt0, fmt)
% Local call to, and formatting of, firstarrival.m

% Collect.
[tres, dat, ~, tadj, ph, delay, twosd, ~, ~, ~, maxc_y, SNR, EQ, ~, ~, ~, winflag, tapflag, zerflag] = ...
    firstarrival(sac, ci, wlen, lohi, sacdir, evtdir, single_EQ, bathy, wlen2, fs, popas, pt0);
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
        zerflag,        ...
        pt0};

% Format.
wline = sprintf(fmt, data{:});
