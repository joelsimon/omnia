function filenames = recursivedir(d, filenames) % input: filenames is an internal indexer for recursion
% filenames = RECURSIVEDIR(d)
%
% RECURSIVEDIR returns all non-dot filenames contained recursively
% (i.e., including subdirectories) in the input directory.
%
% Input:
% d             Directory structure output from dir.m
%
% Output:
% filenames     All (non-dot) filenames contained recursively
%                   in the input directory.
%
% Ex:
%    d = dir(getenv('OMNIA'))
%    filenames = RECURSIVEDIR(d)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 26-Sep-2019, Version 2017b on MACI64

%% Recursive.

% N.B:
%
% Cannot use dir(fullfile(d(i).folder, '**/*.*')) because, it
% assumes every file has an extension (chars after '.')
%
% Could use dir(fullfile(d(i).folder, '**/**')) but skipdotdir.m does
% not work recursively thus requiring the same recursive looping
% through every subdirectory to remove dot folders.

% Remove dot folders and names.
d = skipdotdir(d);

% Initialize recursion indexer if it does not exist, but do not
% overwrite if it does.
if exist('filenames', 'var') ~= 1
    filenames = {};

end

% Loop through recursively through every dir and sudbir concatenating
% filenames on the way.
for i = 1:length(d)
    if d(i).isdir

        %% Recursive.

        subdir = dir(fullfile(d(i).folder, d(i).name));
        filenames = recursivedir(subdir, filenames);

    else
    filenames = [filenames ; {fullfile(d(i).folder, d(i).name)}];

    end
end
filenames = unique(filenames);
