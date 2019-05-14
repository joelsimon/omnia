function  status = isgitfile(filename)
% ISGITFILE(filename)
%
% ISGITFILE(filename) returns true if a FULL PATH filename is under
% git version control.  Assumes user has git installed.
%
% Tested in: git version 1.8.3.1
%            git version 2.6.4 (Apple Git-63)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 06-Dec-2018, Version 2017b

% Sanity.
if exist(filename, 'file') ~= 2
    error('%s does not exist or is not a filename\n', filename)

end

%  Parse filename info.
[pathstr, name, ext] = fileparts(filename);

% Note the version of git; slightly different commands.  Wrap in try
% command; if it fails likely don't have git installed.
try
    [~, git_version]  = system('git version');
    
catch
    error('''git version'' in the command line failed -- is git installed?')

end
git_version = str2double(strrep(git_version(13:17), '.', ''));


% Version 1.8.5 and above you can use git -C to perform git operations
% in another folder. In older versions of git you must cd to the
% actual file's directory.
if git_version >= 185
    % Second output here to silence result of command in command window.
    [result, ~] = system(sprintf('git -C %s ls-files --error-unmatch -- %s', pathstr, [name ext]));    

else
    startdir = pwd;
    cd(pathstr)
    [result, ~] = system(sprintf('git ls-files --error-unmatch -- %s', [name ext]));
    cd(startdir)

end

% Exit code of 0 means the file is tracked by git.
if result == 0
    status = true;

else
    status = false;

end



