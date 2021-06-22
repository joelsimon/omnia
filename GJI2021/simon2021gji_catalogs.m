function simon2021gji_catalogs
% SIMON2021GJI_CATALOGS
%
% Reports which EQ catalogs are being used.
%
% Developed as: simon2020_catalogs.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 16-Mar-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

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

% Paths to the relevant ID file and other necessary directories.
id_txtfile =  fullfile(evtdir, 'reviewed', 'identified', 'txt', 'identified.txt');

% Nab all the DET SAC files recorded through 2019.
endtime = datetime('31-Dec-2019 23:59:59.999', 'TimeZone', 'UTC');
mer_sac = readidentified(id_txtfile, [], endtime, 'SAC', 'DET');

% % Uncomment to overwrite file list and GeoAzur-study catalog.
% mer_sac = mermaid_sacf;
% mer_evtdir = fullfile(getenv('MERMAID'), 'geoazur', 'rematch');

N = length(mer_sac);
orig_catalog{N} = '';
orig_author{N} = '';
orig_contrib{N} = '';
mag_author{N} = '';
mbml_author{N} = '';

parfor i = 1:N
    EQ = fx(getevt(mer_sac{i}, evtdir), 1);

    orig_catalog{i} = EQ.PreferredOrigin.Catalog;
    orig_author{i} = EQ.PreferredOrigin.Author;
    orig_contrib{i} = EQ.PreferredOrigin.Contributor;

    mag_author{i} = EQ.PreferredMagnitude.Author;

    if ~isempty(EQ.MbMlAuthor)
        mbml_author{i} = EQ.MbMlAuthor;

    else
        mbml_author{i} = '';

    end
end
unique(orig_catalog)
