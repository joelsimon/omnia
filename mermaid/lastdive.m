function [errors, outfile] = lastdive(servdir, procdir)
% [errors, outfile] = LASTDIVE(servdir, procdir)
%
% Returns MERMAID serial numbers that include errors in the *.out files
% associated with the last dive, and also writes the contents of the *.out file
% associated with the last dive for each to:
% $MERMAID/processed/lastdive.txt, and
% $MERMAID/processed/lastdive_error.txt
%
% The "last dive" is considered the contents in the .out file after the latest
% transmission that is at least 24 hrs earlier than the final transmission in
% the *.out file.
%
% Input:
% servdir      MERMAID server directory (def: $MERMAID/server)
% procdir      MERMAID processed directory (def: $MERMAID/processed)
%
% Output:
% errors       List of MERMAID serial numbers which have error in .out file,
%                  associated with the last dive
% outfile      The contents of each *.out file corresponding to the last dive
% *N/A*        Writes lastdive.txt and lastdive_error.txt to 'procdir'
%
% Author: Dr. Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 03-Sep-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults.
defval('servdir', fullfile(getenv('MERMAID'), 'server'))
defval('procdir', fullfile(getenv('MERMAID'), 'processed'))

% Collect all MERMAID *.out files.
d = skipdotdir(dir(fullfile(servdir, '452*P-*.out')));

% Write file of last dives for each float.
f = fullfile(procdir, 'lastdive.txt');
writeaccess('unlock', f, false)
fid = fopen(f, 'w');

f_error = fullfile(procdir, 'lastdive_error.txt');
writeaccess('unlock', f_error, false)
fid_error = fopen(f_error, 'w');
errors = {};
error_index = 0;

% Loop over all floats and parse just last dive contents from *.out.
for i = 1:length(d)
    % Read entire *.out file for this float.
    tx = readtext(fullfile(d(i).folder, d(i).name));

    % Chop ".out" off of filename to get MERMAID serial number.
    serial_number = d(i).name(1:end-4);

    % Find all occurrences of "sending cmd...", which specifies new transmission.
    [cmd_index, cmd_datestr] = cellstrfind(tx, sprintf('sending cmd from %s.cmd', serial_number));

    % Convert cmd date strings into datetime objects. Start at last
    % transmission and work backwards to find first gap in transmission
    % greater than 24 hrs, implying a dive has occurred.
    N = length(cmd_datestr);
    Format = 'uuuuMMdd';
    TimeZone = 'UTC';
    cmd_datetime(1) = datetime(cmd_datestr{end}(4:11), 'Format', Format, ...
                               'TimeZone', TimeZone);
    for j = 1:N-1
        dive_index = N-j;
        cmd_datetime(j+1) = datetime(cmd_datestr{dive_index}(4:11), 'Format', Format, ...
                                     'TimeZone', TimeZone);
        if cmd_datetime(j) - cmd_datetime(j+1)  > days(1)
            break

        end
    end

    % Inspect text in *.out file corresponding to data since the last dive.
    dive_block = tx(cmd_index(dive_index):length(tx));
    contains_error = ~isempty(cellstrfind(dive_block, 'error'));
    if contains_error
        fprintf('WARNING: %s last dive contains error\n', serial_number)

    end

    % Write data.
    writeblock(fid, i, dive_block, serial_number, contains_error)
    if contains_error
        error_index = error_index + 1;
        errors{error_index} = serial_number;
        writeblock(fid_error, error_index, dive_block, serial_number, true)

    end

    % Collect output in struct.
    float_number = strrep(serial_number(end-3:end), '-', '0');
    outfile.(float_number) = dive_block;

end

% Close and restrict write access to files.
fclose(fid);
writeaccess('lock', f, false)
fclose(fid_error);
writeaccess('lock', f_error, false)

% Print output files.
fprintf('Wrote: %s\n', f)
fprintf('Wrote: %s\n', f_error)

%%______________________________________________________________________________________%%

function writeblock(fid, indexer, dive_block, serial_number, contains_error)
% Subfunction to write last dive blocks.

% Adapt header line if dive contains an error.
if ~contains_error
    header_line = sprintf('%s\n\n', serial_number);

else
    header_line = sprintf('!! ERROR -- %s -- ERROR !!\n\n', serial_number);

end

% Block separator, if not on first block.
if indexer ~= 1
    fprintf(fid, '%s\n', repmat('-', 50, 1));

end

% Write dive block.
fprintf(fid, '%s', header_line);
fprintf(fid, '%s\n', dive_block{:});
