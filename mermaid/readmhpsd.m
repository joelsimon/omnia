function [hdr, psd] = readmhpsd(filename)
% [hdr, psd] = READMHPSD(filename)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 03-Mar-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Read header line by line
hdr = struct();
fid = fopen(filename, 'r');
tline = fgetl(fid);
while ~contains(tline, 'Datablock')
    hdrline = regexp(tline, ':', 'split', 'once');
    hdr.(hdrline{1}) = strtrim(hdrline{2});
    tline = fgetl(fid);

end

% Read PSD frequency and percentile data chunks
skip = 0;
psd = struct();
while contains(tline, 'Datablock')
    % Parse "#Datablock ..." description line to determine chunk size/type.
    dbstruct = parse_datablock_line(tline);
    desc = dbstruct.desc;
    size = dbstruct.size;
    precision = dbstruct.precision;
    machineformat = dbstruct.machineformat;

    % Read datablock chunks based on preceding description line
    data = fread(fid, size, precision, skip, machineformat);
    psd.(desc) = data;

    tline = fgetl(fid);
    while isempty(tline)
        tline = fgetl(fid);

    end
end

% Verify file and its read completed as expected.
if ~strcmp(tline, '<<EOF>>')
    error('file incomplete - expected terminal ''<<EOF>>'' not found\n%s', filename)

end

%% ___________________________________________________________________________ %%

function dbstruct = parse_datablock_line(tline)
desc = lower(char(regexp(tline, '\[(.*)\]', 'tokens', 'once')));
stat = strsplit(strtrim(fx(strsplit(tline, '->'), 2)), " ");
size = str2num(stat{1}); % (int32?)
precision = stat{2};
machineformat = stat{3};

switch machineformat
  case 'little'
    machineformat = 'l';

  case 'big'
    machineformat = 'b';

  case 'n/a'
    % 'native'; endianness does apply for in8 data
    machineformat = 'n';

  otherwise
    error('machineformat ''%s'' not understood', machineformat)

end
dbstruct = struct('desc', desc, ...
                  'size', size, ...
                  'precision', precision, ...
                  'machineformat', machineformat);
