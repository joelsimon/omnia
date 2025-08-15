function hunga_matchreq2evt

sacdir = fullfile(getenv('HUNGA'), 'sac');
evtdir = fullfile(getenv('HUNGA'), 'evt');

eventid = 11516993;
model = 'ak135';
phases = ['P, S, 4kmps, 3.5kmps, 3kmps, 2.5kmps, 2kmps, 1.5kmps, 1kmps'];

sacfile = globglob(sacdir, '*.sac');
for i = 1:length(sacfile)
    % HAVE TO REMAKE EVERYTIME
    % SAC FILE MAY HAVE SAME NAME (STARTTIME) BUT BE LENGTHENED FROM CURRENT
    [EQ(i), evtfile{i}] = ...
        matchreq2evt(sacfile{i}, eventid, model, phases, evtdir);

end
