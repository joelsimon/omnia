function writelatlon(sacdir, evtdir, returntype, filename, precision)
% WRITELATLON(sacdir, evtdir, returntype, filename, precision)
%
% Writes text file of MERMAID and event latitudes and longitudes to
% $MERMAID/events/reviewed/identified/txt/mermaid_latlon.txt
%
% Input:
% sacdir       Directory where .sac files are kept
%                  def($MERMAID/processed)
% evtdir       Path to directory containing 'raw/' and 'reviewed'
%                  subdirectories (def: $MERMAID/events/)
% returntype   For third-generation+ MERMAID only:
%              'ALL': both triggered and user-requested SAC files (def)
%              'DET': triggered SAC files as determined by onboard algorithm
%              'REQ': user-requested SAC files
% filename     Fullpath output filename (def: $MERMAID/events/.../mermaid_latlon.txt)
% singl        true to write same file in single-precision (def: true)
% precision    Number of decimal places in latitude, longitude (def: 4)
%
% Output:
% *N/A*        Text file with columns:
%              (1) SAC filename
%              (2) STLA (decimal degrees)
%              (3) STLO (decimal degrees)
%              (4) STDP (meters below sea surface, or NaN if STDP missing)
%              (5) EVLA (decimal degrees)
%              (6) EVLO (decimal degrees)
%              (7) EVDP (kilometers)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 05-Mar-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults.
merpath = getenv('MERMAID');
defval('sacdir', fullfile(merpath, 'processed'))
defval('evtdir', fullfile(merpath, 'events'))
defval('returntype', 'ALL')
defval('filename',  fullfile(merpath, 'events', 'reviewed', 'identified', 'txt', 'mermaid_latlon.txt'))
defval('singl', true)
defval('precision', 4)

% Fetch all identified SAC files matching the requested return type.
s = revsac(1, sacdir, evtdir, returntype);

% lat:  -90.(precision) --> max. 4 leading chars incl. decimal
% lon: -180.(precision) --> max. 5 leading chars incl. decimal

% Text file format.
fmt = ['%44s    ', ...
      ['%' sprintf('%i.%if    ', precision+4, precision)], ...  % STLA
      ['%' sprintf('%i.%if    ', precision+5, precision)], ...  % STLO
      '%4i    ', ...
      ['%' sprintf('%i.%if    ', precision+4, precision)], ...  % EVLA
      ['%' sprintf('%i.%if    ', precision+5, precision)], ...  % EVLO
      '%6.2f\n'];

% Open new, or unlock existing, text file.
filename =filename;
writeaccess('unlock', filename, false);
fid =fopen(filename, 'w');

if singl
    filename_single = [filename '_single'];
    writeaccess('unlock', filename_single, false);
    fid_single = fopen(filename_single, 'w');

end

% For every SAC file; parse relevant details and write to file.
for i = 1:length(s)
    sac = s{i};
    if contains(sac, 'prelim')
        continue

    end

    EQ = getevt(sac);
    EQ(1).TaupTimes(1).phaseName;

    evla = EQ.PreferredLatitude;
    evlo = EQ.PreferredLongitude;
    evdp = EQ.PreferredDepth;

    [~, h] = readsac(sac);
    stla = h.STLA;
    stlo = h.STLO;
    stdp = h.STDP;

    if stdp == -12345
        stdp = NaN;

    end

    data ={strippath(sac), ...
                  stla, ...
                  stlo, ...
                  stdp, ...
                  evla, ...
                  evlo, ...
                  evdp};

    fprintf(fid, fmt, data{:});

    if singl
        data_single = {strippath(sac), ...
                       single(stla), ...
                       single(stlo), ...
                       stdp, ...
                       single(evla), ...
                       single(evlo), ...
                       evdp};

        fprintf(fid_single, fmt, data_single{:});

    end
end

% Restrict write access to filename, and print its name to screen.
writeaccess('lock', filename, false)
fclose(fid);
disp(filename)

if singl
    writeaccess('lock', filename_single, false)
    fclose(fid_single);
    disp(filename_single)

end
