function writefirstarrivalpressure(s, redo, filename, fmt, wlen, lohi, sacdir, ...
                           evtdir, EQ, bathy)
% WRITEFIRSTARRIVALPRESSURE(s, redo, filename, fmt, wlen, lohi, sacdir, ...
%                   evtdir, EQ, bathy)
%
% WRITEFIRSTARRIVALPRESSURE writes the output of
% firstarrivalpressure.m to a text file.
%
% Input:
% s        Cell array of identified SAC filenames (def: revsac(1))
% redo     true: delete and remake the text file
%          false: append new lines to the existing tex file unless
%              that SAC file name already exists in the text file (def)
% filename Output text file name (def: $MERMAID/.../firstarrivalpressure.txt)
% fmt      Line format, e.g., set if using SAC files with names
%              longer than 44 chars (see default internally)
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
%
% Output:
% Text file with the following columns (firstarrivalpressure.m outputs in parentheses):
%    (1) SAC filename
%    (2) Theoretical 1st-arriving phase name (ph)
%    (3) RMS value of 1st arrival, in window from arrival time to max. abs. amplitude (RMS)
%    (4) Theoretical pressure in Pa of 1st arrival, according to reid.m (P)
%    (5) Mb or Ml magnitude value used in reid.m, if it exists
%    (6) Mb or Ml magnitude type used in reid.m, if it exists
%    (7) Depth of event in km
%    (8) Distance in degrees from MERMAID to event in degrees
%    (9) MERMAID latitude in decimal degrees
%    (10) MERMAID longitude in decimal degrees
%    (11) Event latitude in decimal degrees
%    (12) Event longitude in decimal degrees
%    (13) IRIS event ID
%    (14) Incomplete window flag: true for incomplete, false
%        otherwise (see timewindow.m)
%
% See also: firstarrivalpressure.m, readfirstarrivalpressure.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 31-Oct-2019, Version 2017b on GLNXA64

% Defaults.
defval('s', revsac(1))
defval('redo', false)
defval('filename', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                            'identified', 'txt', 'firstarrivalpressure.txt'))
defval('fmt', ['%44s    ' , ...
               '%5s    ' ,  ...
               '%18.12E    ' , ...
               '%6.2f   ' ,  ...
               '%4.1f    ',  ...
               '%5s    ',    ...
               '%6.2f    ',  ...
               '%7.3f    ' , ...
               '%7.3f    ' , ...
               '%8.3f    ' , ...
               '%7.3f    ' , ...
               '%8.3f    ' , ...
               '%8s   ',     ...
               '%i\n'])
defval('wlen', 30)
defval('lohi', [1 5])
defval('sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('EQ', [])
defval('bathy', true)

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
    wline = single_wline(sac, wlen, lohi, sacdir, evtdir, fmt, single_EQ, bathy);
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
function wline = single_wline(sac, wlen, lohi, sacdir, evtdir, fmt, single_EQ, bathy)
% Local call to, and formatting of, firstarrivalpressure.m

% Collect.
[RMS, ph, P, ~, ~, ~, ~, ~, ~, EQ, incomplete] = ...
    firstarrivalpressure(sac, wlen, lohi, sacdir, evtdir, single_EQ, bathy);

[~, h] = readsac(fullsac(sac, sacdir));
merlat = h.STLA;
merlon = h.STLO;

depth = EQ(1).PreferredDepth;
dist = EQ(1).TaupTimes(1).distance;
evtlat = EQ(1).PreferredLatitude;
evtlon = EQ(1).PreferredLongitude;
publicid = fx(strsplit(EQ(1).PublicId, '='),  2);

if isempty(P)
    P = NaN;

end

magval = EQ(1).MbMlMagnitudeValue;
if isempty(magval)
    magval = NaN;

end

magtype = EQ(1).MbMlType;
if isempty(magtype)
    magtype = NaN;

end

% Parse.
data = {strippath(sac), ...
        ph,             ...
        RMS,            ...
        P,              ...
        magval,         ...
        magtype,        ...
        depth,          ...
        dist,           ...
        merlat,         ...
        merlon,         ...
        evtlat,         ...
        evtlon,         ...
        publicid,       ...
        incomplete};

% Format.
wline = sprintf(fmt, data{:});
