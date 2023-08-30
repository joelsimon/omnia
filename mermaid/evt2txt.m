function txt = evt2txt(sacdir, revdir, geoazur)
% txt = EVT2TXT(sacdir, revdir, geoazur)
%
% EVT2TXT converts reviewed .evt files (which are really .mat files) to human
% readable text files.  Completely overwrites the all files at every execution.
%
% EVT2TXT overwrites:
%    [revdir]/reviewed/identified/txt/identified.txt
%    [revdir]/reviewed/unidentified/txt/unidentified.txt
%    [revdir]/reviewed/all.txt
%
% These paths must exist before calling EVT2TXT.
%
% Inputs:
% sacdir    Path to directory containing subdirectories with SAC files
%               (def: $MERMAID/processed)
% revdir    Path to directory containing 'reviewed' subdirectory
%               (def: $MERMAID/events)
% geoazur   logical true to assume GeoAzur's naming scheme
%               (def: false)
%
% Output:
% *N/A*     Writes formatted text files
% txt       Formatted text structure with fields:
%           .identified
%           .unidentified
%           .all
% The columns of the output text files are:
%    SAC filename
%    EQ origin time
%    EQ latitude,
%    EQ longitude
%    EQ Flinn-Engdahl region name
%    EQ depth
%    EQ distance
%    EQ magnitude
%    First-arriving phase name
%    IRIS public ID <-- (e.g., http://ds.iris.edu/ds/nodes/dmc/tools/event/11224472)
%
% GeoAzur naming scheme example:
%    'm12.20130416T105310.sac'
%
% Current naming scheme example (default):
%    '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac'
%
% Before running the example below run the example in reviewevt.m and
% make these directories:
%
%    mkdir ~/cpsac2evt_example/reviewed/identified/txt/
%    mkdir ~/cpsac2evt_example/reviewed/unidentified/txt/
%
% Ex: (write a line to identified.txt and all.txt;
%      nothing to write for unidentified)
%    sacdir = fullfile(getenv('OMNIA'), 'exfiles')
%    revdir = '~/cpsac2evt_example';
%    txt = EVT2TXT(sacdir, revdir, false)
%
% See also: cpsac2evt.m, reviewevt.m, revsac.m, getevt.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu | joeldsimon@gmail.com
% Last modified: 30-Aug-2023, Version 9.3.0.713579 (R2017b) on GLNXA64

% Defaults.
defval('sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('revdir', fullfile(getenv('MERMAID'), 'events'))
defval('geoazur', false)

% Initialize empty struct to hold text lines, and specify format.
txt.all = [];
txt.identified = [];
txt.unidentified = [];

if ~geoazur
    fmt = ['%51s    '  , ...
           '%19s    '  , ...
           '%7.3f    ' , ...
           '%8.3f    ' , ...
           '%34s    '  , ...
           '%6.2f    ' , ...
           '%7.3f    ' , ...
           '%4.1f    ' , ...
           '%7s    '   , ...
           '%13s\n'];

else
    fmt = ['%23s    '  , ...
           '%19s    '  , ...
           '%7.3f    ' , ...
           '%8.3f    ' , ...
           '%34s    '  , ...
           '%6.2f    ' , ...
           '%7.3f    ' , ...
           '%4.1f    ' , ...
           '%7s    '   , ...
           '%13s\n'];

end

% Fetch and format data.
allsac = {};
review_status = {'identified', 'unidentified'};
for i = 1:2
    status = review_status{i};
    if strcmp(status, 'identified')
        iup =  1;

    else
        iup = -1;

    end
    [sac, evt, xtra_evt] = revsac(iup, sacdir, revdir);
    if ~isempty(xtra_evt)
        warning(sprintf('%i additional %s .evt files than .sac files', length(xtra_evt), status))

    end

    if isempty(sac)
        % Possible to have the correct path but no .evt files (see the example
        % in the header where no "unidentified" events are present).
        % Rely on warning in revsac.m to alert user.
        continue

    end

    % Below rely on the filename to get the time, ergo we must strip the path.
    sac = cellfun(@(xx) strippath(xx), sac, 'UniformOutput', false);

    % % Remove preliminary (rapid location estimates) SAC files.
    % prelim_idx = find(contains(sac, 'prelim'));
    % sac(prelim_idx) = [];
    % evt(prelim_idx) = [];

    % Sort based on filename (time of first sample of seismogram).
    [~, idx] = sort(sac);
    sac = sac(idx);
    evt = evt(idx);

    % Keep track of identified and unidentified sactimes in single array
    % sorting after concatenation.
    allsac = [allsac; sac];

    for j = 1:length(evt)
        tmp = load(evt{j}, '-mat');
        EQ = tmp.EQ;
        clear('tmp')

        if strcmp(status, 'identified')
            % Make note of multiple event and/or phase matches by tagging the
            % public ID or phase name with a ('*') prefix.
            publicid = fx(strsplit(EQ(1).PublicId, '='),  2);
            if length(EQ) > 1
                publicid = ['*' publicid];
            end

            eqphase = EQ(1).TaupTimes(1).phaseName;
            if length(EQ(1).TaupTimes) > 1
                eqphase = ['*' eqphase];

            end
            data = {strippath(EQ(1).Filename),
                    EQ(1).PreferredTime(1:19),
                    EQ(1).PreferredLatitude,
                    EQ(1).PreferredLongitude,
                    EQ(1).FlinnEngdahlRegionName,
                    EQ(1).PreferredDepth,
                    EQ(1).TaupTimes(1).distance,
                    EQ(1).PreferredMagnitudeValue,
                    eqphase,
                    publicid};


        else
            data = {sac{j}, NaN(1,9)};

        end
        txt.(status){j} = sprintf(fmt, data{:});

    end
end

% Write 'identified.txt' and 'unidentified.txt'.
for i = 1:2
    status = review_status{i};
    fout  = fullfile(revdir, 'reviewed', status, 'txt', [status '.txt']);

    if exist(fout, 'file') == 2
        wstatus = fileattrib(fout, '+w', 'a');
        if wstatus == 0
            error('Unable to allow write access to %s.', fout)

        end
    end

    fid = fopen(fout, 'w');
    for j = 1:length(txt.(status))
        fprintf(fid, txt.(status){j});

    end
    fclose(fid);

    wstatus = fileattrib(fout, '-w', 'a');
    if wstatus == 0
        error('Unable to restrict write access to %s.', fout)

    end
end

% Write 'all.txt' by concatenating identified and unidentified text.
% Sort again based on time assigned to first sample.
txt.all = [txt.identified txt.unidentified];
[~, idx] = sort(allsac);
txt.all = txt.all(idx);

fout  = fullfile(revdir, 'reviewed', 'all.txt');
if exist(fout, 'file') == 2
    wstatus = fileattrib(fout, '+w', 'a');
    if wstatus == 0
        error('Unable to allow write access to %s.', fout)

    end
end

fid = fopen(fout, 'w');
for j = 1:length(txt.all)
    fprintf(fid, txt.all{j});

end
fclose(fid);

wstatus = fileattrib(fout, '-w', 'a');
if wstatus == 0
    error('Unable to restrict write access to %s.', fout)

end
