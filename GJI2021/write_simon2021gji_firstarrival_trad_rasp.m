function write_simon2021gji_firstarrival_trad_rasp
% WRITE_SIMON2021GJI_FIRSTARRIVAL_TRAD_RASP
%
% This writes for FOR ISLAND ("nearby" [G,IU,AM etc.]", and "CPPT" [RSP]) island stations:
%
% nearby_and_cppt/cppt.firstarr.P.vel.txt <- CPPT (RSP network; "traditional" stations) only, from Olivier Hyvernaud
% nearby_and_cppt/cppt.firstarrpress.P..txt
% nearby_and_cppt/cppt.firstarrpress.P.vel.txt
% nearby_and_cppt/nearby.firstarr.P.vel.txt <- "Nearby" includes traditional and Raspberry Shake stations
% nearby_and_cppt/nearby.firstarrpress.P.vel.txt
% rasp.firstarr.P.vel.txt  <- Raspberry Shake, AM network
% rasp.firstarrpress.P.vel.txt
% trad.firstarr.P.vel.txt  < "Traditional" stations, G, IU, RSP etc. (no Raspberry Shake)
% trad.firstarrpress.P.vel.txt
%
% Writes firstarrival text files for nearby (island traditional and Raspberry
% Shake) and CPPT (island) stations, including an extra (not instrument
% corrected or decimated, i.e., raw SAC file) 'cppt.firstarrpress.P..txt' which
% is useful for simon2021gji_inspect_zerflag.m to see which SAC files were zero
% filled within the firstarrival.m taper.
%
% NB, the poor naming "nearby" and "CPPT" occurred due to collecting data from
% many sources over a long time period and thinking when I originally called
% one bin "nearby," it included all data from nearby stations (in that case,
% "traditional" and Raspberry shake sensors). Later, I recovered data from
% the RSP thanks to Olivier Hyvernaud which I (unfortunately) at the time
% grouped under the name "CPPT."  Those data are only "traditional"
% stations. So this script reads all those data from both sources, and pieces
% together the traditional "nearby" sensors with all the CPPT sensors, and
% extracts the Raspberry Shake sensors from the "nearby" bin.
%
% Developed as: simon2020_writefirstarrival2.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 18-Jun-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

% Define paths.
merdir = getenv('MERMAID');
procdir = fullfile(merdir, 'processed');
evtdir = fullfile(merdir, 'events');
nearbydir = fullfile(evtdir, 'nearbystations');

% Ensure in GJI21 git branch.
startdir = pwd;
cd(procdir)
system('git checkout GJI21');
cd(evtdir)
system('git checkout GJI21');
cd(startdir)

% Parameters for firstarrival text file.
otype = 'vel';
wlen = 30;
lohi = [1 5];
bathy = false;
wlen2 = [1.75];
fs = 20;
popas = [4 1];
pt0 = 0;

% Paths to the relevant ID file and other necessary directories.
id_txtfile =  fullfile(evtdir, 'reviewed', 'identified', 'txt', 'identified.txt');
mer_sacdir =  procdir;
mer_evtdir =  evtdir;
nearbydir =  fullfile(evtdir, 'nearbystations');
cpptdir =  fullfile(evtdir, 'cpptstations');
datadir = fullfile(getenv('GJI21_CODE'), 'data');

% Load the MERMAID first-arrival data keeping ALL IDs.  Use the unwinnowed data
% here because we want to include all events identified by MERMAID, regardless
% of if the taper flag or something is incomplete and thus the pick is ultimately
% rejected.
mer_det_txt1 = fullfile(datadir, 'mer.firstarr.all.txt');
[~, ~, ~, ~, FA_0] = ...
    winnowfirstarrival(mer_det_txt1);

% Keep only those events whose first arrival is a P wave -- we don't want to
% compare events in the MERMAID catalog whose first arrival is PP or PKP or S
% with those in the NEARBY catalog whose first arrival is a P wave.
ph2keep = {'p' 'P'};
ph_idx = [];
for i = 1:length(ph2keep)
    % NB, cannot use cellstrfind here because we want exact matches.
    ph_idx = [ph_idx ; find(strcmp(FA_0.ph, ph2keep{i}))];

end
ph_idx = sort(ph_idx);

% Ignore leading asterisk on event ID (signals possible multi events)
% -- KEEPING ONLY THOSE EVENT IDS WHOSE FIRST ARRIVAL IS A P WAVE
id = FA_0.ID(ph_idx);
star_idx = cellstrfind(id, '*');
for i = 1:length(star_idx)
       id{star_idx(i)}(1) = [];

end
id = unique(id);

%% NEARBY STATIONS !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! %%

% Grow a list of nearby SAC files and EQ structures related to these
% event IDs.
nearby_sac = {};
nearby_EQ = {};

% For every event identified by MERMAID...
parfor i = 1:length(id)
   % Ensure these data exist for 'nearby' stations.
    nearby_idpath = fullfile(nearbydir, 'evt', id{i});
    nearby_iddir = dir(fullfile(nearby_idpath, '**/*.evt'));
    if isempty(nearby_iddir)
        continue

    end

    % Fetch the requested 'otype' (instrument response removed) SAC files
    % and EQ structs corresponding only to the MERMAID 'DET' events.
    [~, ~, ns, ne, nsu, neu] = ...
        getnearbysacevt(id{i}, mer_evtdir, mer_sacdir, nearbydir, false, 'DET', otype);

    % Concatenate the complete and unmerged nearby SAC files and EQ structures.
    ns = [ns ; nsu];
    ne = [ne ; neu];

    % Master list of indices within this ID directory of SAC/.evt files to remove.
    nearby_rm_idx = [];

    % Master list of station names and P-arrival times s.t. we may select
    % the first P arrival time if multiple P-wave arrivals are
    % associated with the same station name (e.g., unmerged SAC files
    % that contain P-waves.
    nearby_sta = {};
    nearby_ptime = [];

    % For every nearby station .SAC file and EQ structure associated with
    % this MERMAID-identified event...
    for j = 1:length(ns)

        % Remove MERGED SAC files, those in the top-level directory, which are
        % a SAC merge of the /unmerged/ SAC files in the child directory
        % (we do consider the latter).
        if contains(ns{j}, '.merged.')
            nearby_rm_idx = [nearby_rm_idx ; j];
            continue

        end

        % Remove nearby traces whose sampling rate is too low for the full
        % bandwidth of the bandpass filter.
        [nearby_x, nearby_h] = readsac(ns{j});
        if round(1/nearby_h.DELTA) < 2*lohi(2)
            nearby_rm_idx = [nearby_rm_idx ; j];
            continue

        end

        % Remove those SAC files which are less than 200 seconds long, the
        % minimum length to be considered 'like' a MERMAID seismogram.
        nearby_xax = xaxis(nearby_h.NPTS, nearby_h.DELTA, 0); % pt0 irrelevant; only worried about total length
        if nearby_xax(end) < 200
            nearby_rm_idx = [nearby_rm_idx ; j];
            continue

        end

        % Remove those SAC files whose EQ structures are empty.
        if isempty(ne{j})
            nearby_rm_idx = [nearby_rm_idx ; j];
            continue

        end

        % Only save the nearby records whose first arrival is 'p' or 'P' --
        % the repeats are removed below with strdup.m.
        if strcmpi(ne{j}.TaupTimes(1).phaseName, 'p')
            ne{j}.TaupTimes = ne{j}.TaupTimes(1);

            % This unique network.station.location.channel name may be found by
            % keeping all characters up to the fourth period ('.')
            % delimiter. DO NOT USE strsplit because it ignores
            % empties between delims (e.g.,
            % AU.NIUE..BHZ.2018.220.01.38.57.SAC.acc, where the
            % location is missing).
            nearby_name = strippath(ns{j});
            nearby_delims = strfind(nearby_name, '.');
            nearby_sta = [nearby_sta ; nearby_name(1:nearby_delims(4))];
            nearby_ptime = [nearby_ptime ; ne{j}.TaupTimes.arrivaldatenum];

        else
            nearby_rm_idx = [nearby_rm_idx ; j];

        end

        % Remove those nearby SAC files whose taper window in firstarrival.m
        % intersects the SAC taper, applied before during SAC
        % TRANSFER (default length: 0.05 at either end). I.e., the
        % arrival is near an edge that was tapered.  The full
        % taper window in firstarrival.m is 2*wlen.
        taper_samplen = nearby_h.NPTS * 0.05;
        [~, nearby_FAW, nearby_incomplete] = ...
            timewindow(nearby_x, 2*wlen, ne{j}.TaupTimes(1).truearsecs, 'middle', nearby_h.DELTA, nearby_h.B);

        % firstarrival.m taper window intersects edge(s) of seismogram.
        if nearby_incomplete
            nearby_rm_idx = [nearby_rm_idx ; j];
            continue

        end

        % SAC TAPER at start of seismogram intersects firstarrival.m taper window.
        % (<= because length(1:taper_samplen) == taper_samplen)
        if nearby_FAW.xlsamp <= taper_samplen
            nearby_rm_idx = [nearby_rm_idx ; j];
            continue

        end

        % SAC TAPER at end of seismogram intersects firstarrival.m taper window.
        % (> because length(h.NPTS-taper_samplen:h.NPTS) == taper_samplen+1)
        if nearby_FAW.xrsamp > nearby_h.NPTS - taper_samplen;
            nearby_rm_idx = [nearby_rm_idx ; j];
            continue

        end
    end
    % Remove those indices identified above.  DO NOT REARRANGE THIS; you
    % must do this before proceeding to next stage of index-removal.
    ns(nearby_rm_idx) = [];
    ne(nearby_rm_idx) = [];

    % Identify any repeated station names; keep the first-arriving P-wave
    % for repeats (e.g., if multiple unmerged (short) SAC files each
    % contain P arrivals).
    [~, nearby_di] = strdup(nearby_sta);
    if ~isempty(nearby_di)
        nearby_rm_idx = [];
        for j = 1:length(nearby_di)
            [~, nearby_p1_idx] = min(nearby_ptime(nearby_di{j}));
            nearby_rm_idx = [nearby_rm_idx nearby_di{j}([1:nearby_p1_idx-1 nearby_p1_idx+1:end])];

        end
        ns(nearby_rm_idx) = [];
        ne(nearby_rm_idx) = [];

    end

    % Concatenate growing cell array;
    nearby_sac = [nearby_sac ; ns];
    nearby_EQ = [nearby_EQ ; ne];

end
[nearby_sac, sort_idx] = sort(nearby_sac);
nearby_EQ = nearby_EQ(sort_idx);

% Name of nearby text file, to be split into trad and Raspberry by
% shell script after completion.
nearby_det_txt1 = fullfile(datadir, sprintf('nearby.firstarr.P.%s.txt', otype));
nearby_det_txt2 = fullfile(datadir, sprintf('nearby.firstarrpress.P.%s.txt', otype));

% Write one large firstarrival text file for all nearby (traditional and Raspberry) stations.
writefirstarrival(nearby_sac, true, nearby_det_txt1, wlen, lohi, [], ...
                  [], nearby_EQ, bathy, wlen2, fs, popas, pt0);
writefirstarrivalpressure(nearby_sac, true, nearby_det_txt2, wlen, ...
                          lohi, [], [], nearby_EQ, bathy, wlen2, fs, popas, pt0);

%% CPPT STATIONS !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! %%

% Grow a list of CPPT SAC files and EQ structures related to these
% event IDs.
cppt_sac = {};
cppt_EQ = {};

% For every event identified by MERMAID...
parfor i = 1:length(id)
    % Ensure these data exist for CPPT stations.
    cppt_idpath = fullfile(cpptdir, 'evt', id{i});
    cppt_iddir = dir(fullfile(cppt_idpath, '**/*.evt'));
    if isempty(cppt_iddir)
        continue

    end

    % Fetch the acceleration (instrument response removed) SAC files and EQ
    % structs corresponding only to the MERMAID 'DET' events.
    [~, ~, cs, ce] = ...
        getcpptsacevt(id{i}, mer_evtdir, mer_sacdir, cpptdir, false, 'DET', otype);

    % Master list of indices within this ID directory of SAC/.evt files to remove.
    cppt_rm_idx = [];

    % Master list of station names and P-arrival times s.t. we may select
    % the first P arrival time if multiple P-wave arrivals are
    % associated with the same station name (e.g., unmerged SAC files
    % that contain P-waves.
    cppt_sta = {};
    cppt_ptime = [];

    % For every cppt station .SAC file and EQ structure associated with
    % this MERMAID-identified event...
    for j = 1:length(cs)

        % Remove MERGED SAC files, those in the top-level directory, which are
        % a SAC merge of the /unmerged/ SAC files in the child
        % directory (we do consider the latter).  MERGED files are
        % zero-filled (to plug data gaps), and potentially contain
        % overlapped segments; ignore them!
        if contains(cs{j}, '.merged.')
            cppt_rm_idx = [cppt_rm_idx ; j];
            continue

        end

        % Remove CPPT traces whose sampling rate is too low for the full
        % bandwidth of the bandpass filter.
        [cppt_x, cppt_h] = readsac(cs{j});
        if round(1/cppt_h.DELTA) < 2*lohi(2)
            cppt_rm_idx = [cppt_rm_idx ; j];
            continue

        end

        % Remove those SAC files which are less than 200 seconds long, the
        % minimum length to be considered 'like' a MERMAID seismogram.
        cppt_xax = xaxis(cppt_h.NPTS, cppt_h.DELTA, 0); % pt0 irrelevant; only worried about total length
        if cppt_xax(end) < 200
            cppt_rm_idx = [cppt_rm_idx ; j];
            continue

        end

        % Remove those SAC files whose EQ structures are empty.
        if isempty(ce{j})
            cppt_rm_idx = [cppt_rm_idx ; j];
            continue

        end

        % Only save the CPPT records whose first arrival is 'p' or 'P'.
        if strcmpi(ce{j}.TaupTimes(1).phaseName, 'p')
            ce{j}.TaupTimes = ce{j}.TaupTimes(1);

            % This unique network.station.location.channel name may be found by
            % keeping all characters up to the fourth period ('.')
            % delimiter. DO NOT USE strsplit because it ignores
            % empties between delims (e.g.,
            % AU.NIUE..BHZ.2018.220.01.38.57.SAC.acc, where the
            % location is missing).
            cppt_name = strippath(cs{j});
            cppt_delims = strfind(cppt_name, '.');
            cppt_name(cppt_delims(4):cppt_delims(7));
            cppt_ptime = [cppt_ptime ; ce{j}.TaupTimes.arrivaldatenum];

        else
            cppt_rm_idx = [cppt_rm_idx ; j];

        end

        % Remove those CPPT SAC files whose taper window in firstarrival.m
        % intersects the SAC taper, applied before during SAC TRANSFER
        % (default length: 0.05 at either end). I.e., the arrival is
        % near an edge that was tapered.  The full taper window in
        % firstarrival.m is 2*wlen.
        taper_samplen = cppt_h.NPTS * 0.05;
        [~, cppt_FAW, cppt_incomplete] = ...
            timewindow(cppt_x, 2*wlen, ce{j}.TaupTimes(1).truearsecs, 'middle', cppt_h.DELTA, cppt_h.B);

        % firstarrival.m taper window intersects edge(s) of seismogram.
        if cppt_incomplete
            cppt_rm_idx = [cppt_rm_idx ; j];
            continue

        end

        % SAC TAPER at start of seismogram intersects firstarrival.m taper window.
        % (<= because length(1:taper_samplen) == taper_samplen)
        if cppt_FAW.xlsamp <= taper_samplen
            cppt_rm_idx = [cppt_rm_idx ; j];
            continue

        end

        % SAC TAPER at end of seismogram intersects firstarrival.m taper window.
        % (> because length(h.NPTS-taper_samplen:h.NPTS) == taper_samplen+1)
        if cppt_FAW.xrsamp > cppt_h.NPTS - taper_samplen;
            cppt_rm_idx = [cppt_rm_idx ; j];
            continue

        end
    end
    % Remove those indices identified above.  DO NOT REARRANGE THIS; you
    % must do this before proceeding to next stage of index-removal.
    cs(cppt_rm_idx) = [];
    ce(cppt_rm_idx) = [];

    % Identify any repeated station names; keep the first-arriving P-wave
    % for repeats.  I don't think this will every happen with CPPT
    % data (there are no 'unmerged' SAC files to consider) but I'll
    % leave this here as a safety precaution, nonetheless.
    [~, cppt_di] = strdup(cppt_sta);
    if ~isempty(cppt_di)
        cppt_rm_idx = [];
        for j = 1:length(cppt_di)
            [~, cppt_p1_idx] = min(cppt_ptime(cppt_di{j}));
            cppt_rm_idx = [cppt_rm_idx cppt_di{j}([1:cppt_p1_idx-1 cppt_p1_idx+1:end])];

        end
        cs(cppt_rm_idx) = [];
        ce(cppt_rm_idx) = [];

    end

    % Concatenate growing cell array;
    cppt_sac = [cppt_sac ; cs];
    cppt_EQ = [cppt_EQ ; ce];

end
[cppt_sac, sort_idx] = sort(cppt_sac);
cppt_EQ = cppt_EQ(sort_idx);

% Name of CPPT text file.
cppt_det_txt1 = fullfile(datadir, sprintf('cppt.firstarr.P.%s.txt', otype));
cppt_det_txt2 = fullfile(datadir, sprintf('cppt.firstarrpress.P.%s.txt', otype));

% Write one firstarrival text file for all CPPT stations.
writefirstarrival(cppt_sac, true, cppt_det_txt1, wlen, lohi, [], [], ...
                  cppt_EQ, bathy, wlen2, fs, popas, pt0);
writefirstarrivalpressure(cppt_sac, true, cppt_det_txt2, wlen, lohi, ...
                          [], [], cppt_EQ, bathy, wlen2, fs, popas, pt0);

% CPPT stations may have been zero-filled by Olivier Hyvernaud. I do not know
% what CPPT stations are zero filled (conversely, I DO know which
% nearbystations' data is zero filled because I marked those by .merged. in the
% name).  If the output type is not empty (e.g., we are working with
% instrument-corrected and not raw data), we must generate a complementary
% text file that deals with the raw data so that we may properly flag those
% zero-filled SAC files.  The problem is that TRANSFER in SAC turns zeros into
% numerical error, and thus zerflag is not triggered in firstarrival.m.  Also,
% make sure not to decimate in firstarrival.m because that will also average
% values and remove contiguous zeros.
%
% Use simon2021gji_inspect_zerflag.m to review those SAC files with potential
% data-gaps in the firstarrival tapers.  Make the complementary text file with
% the raw CPPT data using firstarrivalpressure.m because it sees the same segment as
% firstarrrrival.m, but it doesn't have to compute error estimates (time
% consuming).
if ~isempty(otype)
    % Remove otype from SAC file to convert it to it's RAW SAC file name.
    cppt_sac_raw = strrep(cppt_sac, ['.' otype], '');
    cppt_det_raw = fullfile(datadir, 'cppt.firstarrpress.P..txt')
    writefirstarrivalpressure(cppt_sac_raw, true, cppt_det_raw, wlen, NaN, [], ...
                              [], cppt_EQ, bathy, wlen2, [], NaN, pt0);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Processing done -- now just organize text files.
%____________________________________________________________________________%
%% RASP
% Separate Raspberry Shake data from nearby.*txt and save to separate
% rasp.*txt (these are not "traditional" seismometers and will be
% treated separately).
rasp_det_txt1 = fullfile(datadir, sprintf('rasp.firstarr.P.%s.txt', otype))
rasp_det_txt2 = fullfile(datadir, sprintf('rasp.firstarrpress.P.%s.txt', otype))

% Allow write permission.
writeaccess('unlock', rasp_det_txt1, false);
writeaccess('unlock', rasp_det_txt2, false);

% Not the quickest way to do this -- reloading the text and parsing,
% but it will do.
nearby_str1 = readtext(nearby_det_txt1);
nearby_str2 = readtext(nearby_det_txt2);

% Separate those lines that include AM.R (AM network, Raspberry Shake)
[rasp_idx1, rasp_str1] = cellstrfind(nearby_str1, 'AM\.R.*SAC');
[rasp_idx2, rasp_str2] = cellstrfind(nearby_str2, 'AM\.R.*SAC');

% Write RASP files.
rasp_fid1 = fopen(rasp_det_txt1, 'w');
rasp_fid2 = fopen(rasp_det_txt2, 'w');

fprintf(rasp_fid1, '%s\n', rasp_str1{:});
fprintf(rasp_fid2, '%s\n', rasp_str2{:});

fclose(rasp_fid1);
fclose(rasp_fid2);

% Restrict write permission.
writeaccess('lock', rasp_det_txt1);
writeaccess('lock', rasp_det_txt2);

%_____________________________________________________________________________%
%% TRAD

% Concatenate non-Raspberry Shake data from nearby.*txt with all data
% from cppt.*txt (these are all "traditional" seismometers and will be
% treated together).
trad_det_txt1 = fullfile(datadir, sprintf('trad.firstarr.P.%s.txt', otype));
trad_det_txt2 = fullfile(datadir, sprintf('trad.firstarrpress.P.%s.txt', otype));

% Allow write permission.
writeaccess('unlock', trad_det_txt1, false);
writeaccess('unlock', trad_det_txt2, false);

% The traditional island stations are those indices in nearby_str that
% are not Raspberry Shake stations.
trad_idx1 = setdiff(1:length(nearby_str1), rasp_idx1);
trad_idx2 = setdiff(1:length(nearby_str2), rasp_idx2);

% Read the CPPT data to be concatenated.
cppt_str1 = readtext(cppt_det_txt1);
cppt_str2 = readtext(cppt_det_txt2);

% Concatenate all "traditional" seismometer data.
trad_str1 = [nearby_str1(trad_idx1) ; cppt_str1];
trad_str2 = [nearby_str2(trad_idx2) ; cppt_str2];

% Write TRAD files.
trad_fid1 = fopen(trad_det_txt1, 'w');
trad_fid2 = fopen(trad_det_txt2, 'w');

fprintf(trad_fid1, '%s\n', trad_str1{:});
fprintf(trad_fid2, '%s\n', trad_str2{:});

fclose(trad_fid1);
fclose(trad_fid2);

% Restrict write permission.
writeaccess('lock', trad_det_txt1);
writeaccess('lock', trad_det_txt2);

% Finally, move those individual text files I just parsed to a subdirectory.
predir = fullfile(datadir, 'nearby_and_cppt');
[~, foo] = mkdir(predir);

[~, foo] = movefile(nearby_det_txt1, predir, 'f'); % force overwrite of locked file
[~, foo] = movefile(nearby_det_txt2, predir, 'f');

[~, foo] = movefile(cppt_det_txt1, predir, 'f');
[~, foo] = movefile(cppt_det_txt2, predir, 'f');

% And move the complementary file for catching zerflags, if it exists.
if ~isempty(otype)
    [~, foo] = movefile(cppt_det_raw, predir, 'f');

end
