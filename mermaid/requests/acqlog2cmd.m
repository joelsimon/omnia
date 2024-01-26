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
% Last modified: 25-Jan-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('nscal', 5)

basename = strippath(csv_file);
kstnm = basename(1:5);

csv_fmt = [repmat('%s ', [1,31]) '\n'];
csv_fid = fopen(csv_file, 'r');
ts = textscan(csv_fid, csv_fmt, 'HeaderLines', 1, 'Delimiter', ',');
fclose(csv_fid);

index = str2double(ts{2});
start_str = ts{23};
end_str = ts{24};
flag = ts{30};

fmt_str = 'uuuu-MM-dd HH:mm:ss.SSSSSS';
start_date = datetime(start_str, 'Format', fmt_str, 'TimeZone', 'UTC');
end_date = datetime(end_str, 'Format', fmt_str, 'TimeZone', 'UTC');

start_date = dateshift(start_date, 'end', 'second');
end_date = dateshift(end_date, 'start', 'second');

defval('req_file', sprintf('%s.txt', kstnm))
if endsWith(req_file, 'txt')
    flag_file = strrep(req_file, '.txt', '_FLAG.txt');

else
    flag_file = [req_file '_FLAG.txt'];

end

req_fid = fopen(req_file, 'w');
flag_fid = fopen(flag_file, 'w');

req_num = 0;
flag_num = 0;
for i = 1:length(start_date)
    req_str = reqdateduration(start_date(i), end_date(i));
    for j = 1:length(req_str)
        if isempty(flag{i})
            req_num = req_num + 1;
            cmd_str = sprintf('mermaid REQUEST:%s,%i', req_str{j}, nscal);
            fprintf(req_fid, '%s # %s REQUEST %04i (INDEX %04i)\n', cmd_str, kstnm, req_num, index(i));

        else
            flag_num = flag_num + 1;
            cmd_str = sprintf('mermaid REQUEST:%s,%i', req_str{j}, nscal);
            fprintf(flag_fid, '%s # %s FLAGGED REQUEST %04i (INDEX %04i)\n', cmd_str, kstnm, flag_num, index(i));

        end
    end
end
fclose(req_fid);
fclose(flag_fid);
fprintf('Wrote: %s\n', req_file)
fprintf('Wrote: %s\n', flag_file)
