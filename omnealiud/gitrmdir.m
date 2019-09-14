function [git_removed, deleted] = gitrmdir(d)
% [git_removed, deleted] = GITRMDIR(d)
%
% GITRMDIR is wrapper to gitrmfile.m and properly removes every
% non-dot file contained in the input directory structure, either with
% a system call to 'git rm' or with MATLAB's builtin delete.m,
% depending on if the individual files are tracked by git.
%
% GITRMDIR works recursively and properly clears all files in all
% subdirectories of in the input directory.
%
% Input:
% d             Directory structure output from dir.m
%
% Output:
% git_removed   Cell array of non dot files deleted with a
%                   system call to 'git rm' (def: {})
% deleted       Cell array of non dot files deleted with
%                   MATLAB's builtin delete.m (def: {})
%
% Before running the example generate two files in the terminal and
% track and commit one.
%
%    $ mkdir ~/examples/gitrmdir; cd ~/examples/gitrmdir
%    $ touch is_git_tracked not_git_tracked
%    $ git init; git add is_git_tracked; git commit -m "a test"
%
% Ex: (ensure MATLAB in same directory where you just made those files)
%    cd ~/examples/gitrmdir
%    d = dir(pwd);
%    [git_removed, deleted] = GITRMDIR(d)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 08-Sep-2019, Version 2017b

% Pull all non-dot filenames from every (sub)directory.
filenames = recursivedir(d);
if isempty(filenames)
    deleted = {};
    git_removed = {};
    warning('Director(ies) empty, or only include dot files')
    return

end

% Delete each.
[git_removed, deleted] = gitrmfile(filenames);