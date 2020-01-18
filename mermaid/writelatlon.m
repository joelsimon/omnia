function writelatlon
% WRITELATLON
%
% Write station and event lat, lon, and depth to textfile.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 18-Jan-2020, Version 2017b on GLNXA64

s = revsac(1);

fid = fopen(fullfile(getenv('MERMAID'), 'events', 'reviewed', 'identified', 'txt', 'mermaid_latlon.txt'), 'w');
fmt = ['%44s    ', ...
       '%8.4f    ' , ...
       '%9.4f    ' , ...
       '%4i    ', ...
       '%8.4f    ' , ...
       '%9.4f    ' , ...
       '%6.2f\n'];


s = [s(1:10) ; getsac('10964158')];

for i = 1:length(s)
    sac = s{i};
    EQ = getevt(sac);
    EQ(1).TaupTimes(1).phaseName

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

    data = {strippath(sac),     ...
            stla,  ...
            stlo,  ...
            stdp,  ...
            evla, ...
            evlo, ...
            evdp};

    fprintf(fid, fmt, data{:});
end
