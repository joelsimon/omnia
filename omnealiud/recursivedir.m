function filenames = recursivedir(d, filenames) % input: filenames is an internal indexer for recursion
% filenames = RECURSIVEDIR(d)
%
% RECURSIVEDIR returns all non-dot filenames contained recursively
% (i.e., including subdirectories) in the input directory.
%
% Use, d = dir(fullfile(partial_path, '**/*[pattern]*', '**/*[pattern2]*')) for
% regexp-like behavior (though multiple patterns with dir.m is tricky and should
% be used with caution...).
%
% Input:
% d             Directory structure output from dir.m,
%               partial path and dir('**/*[pattern]') allowed
%
% Output:
% filenames     All (non-dot) filenames contained recursively
%                   in the input directory
%
% Ex1: (fetch all files in $OMNIA')
%    d = dir(getenv('OMNIA'));
%    filenames = RECURSIVEDIR(d)
%
% Ex2: (fetch all SAC files contained recursively in $MERMAID/processed)
%    d = dir(fullfile(getenv('MERMAID'), 'processed', '**/*.sac'));
%    filenames = RECURSIVEDIR(d)
%
% Author: Dr. Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 21-Oct-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

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
