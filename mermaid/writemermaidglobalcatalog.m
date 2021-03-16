function mercatfile = writemermaidglobalcatalog(globalfile, idfile, nfloats, incl_prelim)
% mercatfile = WRITEMERMAIDGLOBALCATALOG(globalfile, idfile, nfloats, incl_prelim)
%
% WRITEMERMAIDGLOBALCATALOG reads the text file output by
% writeglobalcatalog.m and appends to each line (corresponding to a
% single event ID) the total number, and the specific float number(s),
% of MERMAIDs that also positively identified that event.
%
% Three text files are written: M?_all.txt, M?_DET.txt, M?_REQ.txt,
% where ? is the magnitude unit (e.g., '5').  The first file includes
% all 'DET' (triggered) and 'REQ' (requested) SAC files, while the
% latter two parse individually by return type.
%
% Input:
% globalfile   Name of text file output writeglobalcatalog.m
%                  (def: $MERMAID/events/globalcatalog/M6.txt)
% idfile       Name of 'identified.txt' file output by evt2txt.m,
%                  (def: $MERMAID/events/reviewed/identified/txt/identified.txt)
% nfloats      Number of floats to consider (def: 16), which
%                  controls the field width of the last column
% incl_prelim  true to include 'prelim.sac' (def: true)
%
% Output:
% *N/A*       Writes M?_all.txt, M?_DET.txt, M?_REQ.txt,
%                 where ? is a magnitude unit (e.g., '5'),
%                 in the same directory as idfile
% mercatfile  3x1 cell of All, DET, and REQ files written
%
% See also: readmermaidglobalcatalog.m, plotmermaidglobalcatalog.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 16-Mar-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults.
defval('globalfile', fullfile(getenv('MERMAID'), 'events', 'globalcatalog', 'M6.txt'));
defval('idfile', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                            'identified', 'txt', 'identified.txt'))
defval('nfloats', 16)
defval('incl_prelim', true)

% Read the global events file and the MERMAID-identified events file.
[eqtime, eqlat, eqlon, eqdepth, eqmag, globe_id] = readglobalcatalog(globalfile);
[sac, ~, ~, ~, ~, ~, ~, ~, ~, mer_id] =  readidentified(idfile, [], [], [], [], incl_prelim);

% Find the float numbers.
floatnum = cellfun(@(xx) xx(17:18), sac,'UniformOutput', false);
det_idx = cellstrfind(sac, '\.DET\.');
req_idx = cellstrfind(sac, '\.REQ\.'); % alternatively: ~intersect

% Find MERMAID events with leading asterisk (indicating the
% possibility of multiple events present in the time window), and
% remove the leading asterisk, as we are only interested here in the
% primary event.
star_idx = cellstrfind(mer_id, '*');
for i = 1:length(star_idx)
    mer_id{star_idx(i)}(1) = [];

end

% Two new columns are added: total number and specific float number(s)
% which also positively identified event; initialize them.
all_float_tot_column = zeros(size(globe_id));
det_float_tot_column = all_float_tot_column;
req_float_tot_column = all_float_tot_column;

all_float_num_column = repmat({NaN}, size(globe_id));
det_float_num_column = all_float_num_column;
req_float_num_column = all_float_num_column;

% These are the events which are contained both in the global and
% MERMAID catalogs.
[common_id, globe_idx] = intersect(globe_id, mer_id);

% Loop over the complete set of common IDs and find the total number
% and specific floats which see that event, for all return types.
for i = 1:length(common_id)
    all_id_idx = cellstrfind(mer_id, common_id{i});
    all_floatnum = unique(floatnum(all_id_idx));
    all_float_tot_column(globe_idx(i)) = length(all_floatnum);
    all_float_num_column{globe_idx(i)} = cell2commasepstr(all_floatnum);

    det_id_idx = intersect(all_id_idx, det_idx);
    if ~isempty(det_id_idx)
        det_floatnum = sort(floatnum(det_id_idx));
        det_float_tot_column(globe_idx(i)) = length(det_floatnum);
        det_float_num_column{globe_idx(i)}  = cell2commasepstr(det_floatnum);

    end

    req_id_idx = intersect(all_id_idx, req_idx);
    if ~isempty(req_id_idx)
        req_floatnum = sort(floatnum(req_id_idx));
        req_float_tot_column(globe_idx(i)) = length(req_floatnum);
        req_float_num_column{globe_idx(i)}  = cell2commasepstr(req_floatnum);

    end
end

% Max length of comma-separated float list, where the float numbers
% are two digits long.
length_float_num_column = (nfloats * 3) - 1;

% Format, based on max length just determined.
fmt = ['%23s    '  , ...
       '%7.3f    ' , ...
       '%8.3f    ' , ...
       '%6.2f    ' , ...
       '%4.1f    ' , ...
       '%8s    '   , ...
       '%2i    '   , ...
       ['%' sprintf('%is', length_float_num_column) '\n']];


% Write all, det, and req files.
iddir = fileparts(idfile);
mag_unit = globalfile(end-4);
mercatfile{1} = writefile(iddir, eqtime, eqlat, eqlon, eqdepth, ...
                          eqmag, globe_id, all_float_tot_column, ...
                          all_float_num_column, 'ALL', fmt, mag_unit);

mercatfile{2} = writefile(iddir, eqtime, eqlat, eqlon, eqdepth, ...
                          eqmag, globe_id, det_float_tot_column, ...
                          det_float_num_column, 'DET', fmt, mag_unit);

mercatfile{3} = writefile(iddir, eqtime, eqlat, eqlon, eqdepth, ...
                          eqmag, globe_id, req_float_tot_column, ...
                          req_float_num_column, 'REQ', fmt, mag_unit);
mercatfile = mercatfile';

%_____________________________________________________________%
function fout = writefile(iddir, eqtime, eqlat, eqlon, eqdepth, ...
                          eqmag, globe_id, totcolumn, numcolumn, ...
                          returntype, fmt, mag_unit)
% This function writes a single file given a return type (e.g., 'DET')
% and its corresponding data, found above.

fout  = fullfile(iddir, sprintf('M%s_%s.txt', mag_unit, returntype));
if exist(fout, 'file') == 2
    wstatus = fileattrib(fout, '+w', 'a');
    if wstatus == 0
        error('Unable to allow write access to %s.', fout)

    end
end

fid = fopen(fout, 'w');
for j = 1:length(globe_id)
    data = {eqtime{j}, ...
            eqlat(j), ...
            eqlon(j), ...
            eqdepth(j), ...
            eqmag(j), ...
            globe_id{j}, ...
            totcolumn(j), ...
            numcolumn{j}};
    fprintf(fid, fmt, data{:});

end
fclose(fid);

wstatus = fileattrib(fout, '-w', 'a');
if wstatus == 0
    error('Unable to restrict write access to %s.', fout)

end
fprintf('Wrote: %s\n', fout)
