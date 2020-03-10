function mer = readmerloc(locdir)

% Default.
defval('locdir', fullfile(getenv('MERMAID'), 'locations'));

% Princeton-owned float numbers.
floatstr = {'008' '009' '010' '011' '012' '013' '016' '017' '018' ...
            '019' '020' '021' '022' '023' '024' '025'};

% Datime format for time of GPS point.
locdate_fmt = 'dd-MMM-uuuuHH:mm:ss';

for i = 1:length(floatstr)
    % Identify the current float name and it's location textfile.
    mername = sprintf('P%s', floatstr{i});
    filename = fullfile(locdir, sprintf('P%s_all.txt', floatstr{i}));;

    % Read the location file.
    fid = fopen(filename, 'r');
    c = textscan(fid, fmtout);

    % Parse location dates (e.g., '05-Aug-2018') and times (e.g., '13:25:04').
    loc_day = c{2};
    loc_time = c{3};

    % Loop over all location days; concatenate day and time as input to
    % datetime.  I prefer a loop here to cellfun because I find it
    % easier to read, though the latter would work too.
    for j = 1:length(loc_day)
        mer.(mername).locdate(j) = datetime([loc_day{j} loc_time{j}], ...
                                            'InputFormat', locdate_fmt, ...
                                            'TimeZone', 'UTC');
    end
    mer.(mername).locdate = mer.(mername).locdate';
    
    % Tack on the latitudes and longitudes.
    mer.(mername).lat = c{4}(:);
    mer.(mername).lon = c{5}(:);

end


% The following (marginally modified) function was written by Frederik J. Simons
% and is included in vit2tbl.m (and EarthScopeOceans serverscript):
% https://github.com/earthscopeoceans/serverscripts/blob/master/vit2tbl.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAKE FORMAT STRING
function fmt=fmtout

% All but last one get spaces
stname_fmt  ='%4s   ';
%%%%%%%%%%%%%%%%%%%%%%%%
stdt_fmt    ='%11s ';
stti_fmt    ='%8s    ';  % JDS added
STLA_fmt    ='%11.6f ';
STLO_fmt    ='%12.6f ';
%%%%%%%%%%%%%%%%%%%%%%%%
hdop_fmt    ='%7.3f';
vdop_fmt    ='%7.3f   ';
%%%%%%%%%%%%%%%%%%%%%%%%
Vbat_fmt    ='%6d ';
minV_fmt    ='%6d   ';
%%%%%%%%%%%%%%%%%%%%%%%%
Pint_fmt    ='%6d';
Pext_fmt    ='%6d';
Prange_fmt  ='%5d   ';
%%%%%%%%%%%%%%%%%%%%%%%%
cmdrcd_fmt  ='%3d ';
f2up_fmt    ='%3d ';
% Last one gets a closure
fupl_fmt    ='%3d\n';

% Combine all the formats, the current result is:
% '%s %s %11.6f %11.6f %8.3f %8.3f %5i %5i %5i %12i %5i %3i %3i %3i\n'
fmt=[stname_fmt,stdt_fmt,stti_fmt,STLA_fmt,STLO_fmt,hdop_fmt,vdop_fmt, ...
     Vbat_fmt,minV_fmt, Pint_fmt,Pext_fmt,Prange_fmt,cmdrcd_fmt,f2up_fmt, ...
     fupl_fmt];

