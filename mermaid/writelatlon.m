function writelatlon(sacdir, evtdir, returntype, filename)
% WRITELATLON(sacdir, evtdir, returntype, filename)
%
% Writes textfile of MERMAID and event latitudes and longitudes to
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
% Last modified: 12-Nov-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults.
merpath = getenv('MERMAID');
defval('sacdir', fullfile(merpath, 'processed'))
defval('evtdir', fullfile(merpath, 'events'))
defval('returntype', 'ALL')
defval('filename',  fullfile(merpath, 'events', 'reviewed', 'identified', 'txt', 'mermaid_latlon.txt'))

% Fetch all identified SAC files matching the requested return type.
s = revsac(1, sacdir, evtdir, returntype);

% Text file format.
fmt = ['%44s    ', ...
       '%8.4f    ' , ...
       '%9.4f    ' , ...
       '%4i    ', ...
       '%8.4f    ' , ...
       '%9.4f    ' , ...
       '%6.2f\n'];

% Open new, or unlock existing, text file.
writeaccess('unlock', filename);
fid = fopen(filename, 'w');

% For every SAC file; parse relevant details and write to file.
for i = 1:length(s)
    sac = s{i};
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

    data = {strippath(sac), ...
            stla, ...
            stlo, ...
            stdp, ...
            evla, ...
            evlo, ...
            evdp};

    fprintf(fid, fmt, data{:});

end

% Restrict write access to filename, and print its name to screen.
writeaccess('unlock', filename)
disp(filename)
