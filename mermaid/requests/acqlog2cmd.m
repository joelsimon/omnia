function acqlog2cmd(csv_file, req_file, nscal)
% ACQLOG2CMD(csv_file, req_file, nscal)
%
% Convert *_Available_in_AcqLogs.csv files as written by Dalija Namjesnik to
% "mermaid REQUEST:XXXX-XX-XXTXX_XX-XX,X,X" formatted-strings for .cmd files.
%
% Input:
% <todo>
%
% Output:
% <todo>
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 02-Feb-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default number of scales to request: 5 scales = 20 Hz
% Output files defaulted later, based on station name
defval('nscal', 5)

% Find station name
basename = strippath(csv_file);
kstnm = basename(1:5);

% Read Dalija's .csv file
csv_fmt = [repmat('%s ', [1,31]) '\n'];
csv_fid = fopen(csv_file, 'r');
ts = textscan(csv_fid, csv_fmt, 'HeaderLines', 1, 'Delimiter', ',');
fclose(csv_fid);

% Parse relevent startTime, endTime, flag columns for .csv
index = str2double(ts{2});
start_str = ts{23};
end_str = ts{24};
flag = ts{30};

% Convert startTime and endTime strings to datetimes
fmt_str = 'uuuu-MM-dd HH:mm:ss.SSSSSS';
start_date = datetime(start_str, 'Format', fmt_str, 'TimeZone', 'UTC');
end_date = datetime(end_str, 'Format', fmt_str, 'TimeZone', 'UTC');

% Shift datetimes: round up startTime and round down endTime
% (requests must be in integer seconds)
% This avoids potential problem of request starting before buffer acq
start_date = dateshift(start_date, 'end', 'second');
end_date = dateshift(end_date, 'start', 'second');

% Default 4 filenames (for, e.g., 'P0006'):
% P0006_request.txt
% P0006_request_comment.txt
%
% P0006_request_flag.txt
% P0006_request_flag_comment.txt
defval('req_file', sprintf('%s_request.txt', kstnm));

if endsWith(req_file, '.txt')
    req_comment_file = strrep(req_file, '.txt', '_comment.txt');
    flag_file = strrep(req_file, '.txt', '_flag.txt');
    flag_comment_file = strrep(flag_file, '.txt', '_comment.txt');

else
    req_comment_file = [req_file, '_comment'];
    flag_file = [req_file '_flag'];
    flag_comment_file = [flag_file '_comment'];

end

% Open output request files
req_fid = fopen(req_file, 'w');
req_comment_fid = fopen(req_comment_file, 'w');

flag_fid = fopen(flag_file, 'w');
flag_comment_fid = fopen(flag_comment_file, 'w');

% Initialize counters for number of requests (good and flag)
req_num = 0;
flag_num = 0;

% Loop over all requests and write them to either to the good or flag file
for i = 1:length(start_date)
    % Convert request datetimes to .cmd "mermaid REQUEST:XXX...:" format
    req_str = reqdateduration(start_date(i), end_date(i));

    % Any request longer than 30 minutes must be split over multiple lines
    for j = 1:length(req_str)

        % Write each subrequest to individual line, in either good and flag file
        % For both, write two versions:
        % (1) just the command exactly as to be copied to .cmd
        % (2) the command plus some comments about request number, EQ index
        cmd_str = sprintf('mermaid REQUEST:%s,%i', req_str{j}, nscal);
        if isempty(flag{i})
            req_num = req_num + 1;

            fprintf(req_fid, '%s\n', cmd_str);
            fprintf(req_comment_fid, ....
                    '%s # %s REQUEST %04i (INDEX %04i)\n', ...
                    cmd_str, kstnm, req_num, index(i));


        else
            flag_num = flag_num + 1;
            fprintf(flag_fid, '%s\n', cmd_str);
            fprintf(flag_comment_fid, ...
                    '%s # %s REQUEST %04i (INDEX %04i)\n', ...
                    cmd_str, kstnm, flag_num, index(i));

        end
    end
end

% Close all files
fclose(req_fid);
fclose(req_comment_fid);
fclose(flag_fid);
fclose(flag_comment_fid);

% End with printout of files written
fprintf('Wrote: %s\n', req_file)
fprintf('Wrote: %s\n', req_comment_file)
fprintf('Wrote: %s\n', flag_file)
fprintf('Wrote: %s\n', flag_comment_file)
