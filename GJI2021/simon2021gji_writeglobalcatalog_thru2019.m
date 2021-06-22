function simon2021gji_writeglobalcatalog_thru2019
% SIMON2021GJI_WRITEGLOBALCATALOG_THRU2019
%
% One-time-use function intended to update global catalog and MERMAID
% matches to that global catalog for dates 01-Aug-2018 through the end
% of 2019.
%
% These text files are then used for tbl1_6.m.
%
% *This updates the text files in the $MERMAID/events
%  e.g. /home/jdsimon/mermaid/events/globalcatalog/M6.txt, and
%       /home/jdsimon/mermaid/events/reviewed/identified/txt/M6_DET.txt
%
% Developed as: ./scriptish/simon2020_writeglobalcatalog_thru2019.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 16-Mar-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Define paths.
merdir = getenv('MERMAID');
procdir = fullfile(merdir, 'processed');
evtdir = fullfile(merdir, 'events');

% Ensure in GJI21 git branch -- complimentary paper w/ same data set.
startdir = pwd;
cd(procdir)
system('git checkout GJI21');
cd(evtdir)
system('git checkout GJI21');
cd(startdir)

% Write it.
minmag = 4;
maxmag = 9;
stime = fdsndate2str(datetime('01-Aug-2018 00:00:00.000', 'TimeZone', 'UTC'));
etime = fdsndate2str(datetime('31-Dec-2019 23:59:59.999', 'TimeZone', 'UTC'));
txtdir = fullfile(evtdir, 'globalcatalog');

% Write global events.
writeglobalcatalog(minmag, maxmag, stime, etime, txtdir)

% And append the MERMAID numbers to that text file.
incl_prelim = false;
writemermaidglobalcatalogall(incl_prelim)
