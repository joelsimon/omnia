function [git_removed, deleted] = gitrmfile(filename)
% [git_removed, deleted] = GITRMFILE(filename)
%
% Delete files(s) respecting their git history, if it exists.
%
% GITRMFILE checks if the input file is tracked by git, and if so
% removes it with a system call to 'git rm'; otherwise it uses
% MATLAB's builtin function delete.m.  Assumes user has git installed.
%
% GITRMFILE throws an error and returns the system call's result if an
% input file tracked by git has uncommitted changes in the staging area.  
% It does not force (-f) remove any files.
%
% Input:
% filename      File name(s), either as char or cell array
%
% Output:
% git_removed   Cell array of files deleted with a system call to 
%                   'git rm' (def: {})
% deleted       Cell array of files deleted with MATLAB's delete.m
%                   (def: {})
%
% Before running the example generate two files in the terminal and
% track and commit one.
%
%    $ touch is_git_tracked not_git_tracked
%    $ git init; git add is_git_tracked; git commit -m "a test"
%
% Ex: (ensure MATLAB in same directory where you just made those files)
%    filename = {'is_git_tracked' 'not_git_tracked'};
%    [git_removed, deleted] = GITRMFILE(filename)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 09-Sep-2019, Version 2017b on GLNXA64

if ~iscell(filename)
    filename = {filename};

end

g_count = 0;
d_count = 0;

deleted = {};
git_removed = {};
for i = 1:length(filename)

    if exist(filename{i}, 'file') ~= 2
        error('%s does not exist or is not a filename\n', filename{i})

    end

    if isgitfile(filename{i})
        try
            [~, git_version]  = system('git version');
            
        catch
            error(['''git version'' in the command line failed -- ' ...
                   'is git installed?'])

        end
        git_version = str2double(strrep(git_version(13:17), '.', ''));

        [pathstr, name, ext] = fileparts(filename{i});
        if isempty(pathstr)
            pathstr = pwd;
            
        end

        if git_version >= 185
            [status, result] = system(sprintf('git -C %s rm -- %s', ...
                                              pathstr, [name ext]));

        else
            startdir = pwd;
            cd(pathstr)
            [status, result] = system(sprintf('git rm -- %s', [name ext]));
            try
                cd(startdir)

            end
        end

        if status ~= 0
            error(sprintf(['\nFailed to remove file: %s\n\nSystem ' ...
                           'call result:\n%s'], filename{i}, result))

        end

        g_count = g_count + 1;
        git_removed{g_count} = filename{i};
        
    else
        delete(filename{i})
        d_count = d_count + 1;
        deleted{d_count} = filename{i};

    end
end
deleted = deleted';
git_removed = git_removed';
