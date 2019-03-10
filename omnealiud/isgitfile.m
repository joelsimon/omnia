function  status = isgitfile(filename)
% ISGITFILE(filename)
%
% ISGITFILE(filename) returns true if filename, given with a full
% path, is under git version control.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 06-Dec-2018, Version 2017b

if ~exist(filename, 'file') == 2
    error('%s does not exist or is not a filename\n', filename)

end

% Version 1.8.5 and above you can use git -C to perform git operations
% in another folder.  Being that I have a prehistoric version of git
% on my linux box I have to cd to the actual directory.
startdir = pwd;
[filedir, name, ext] = fileparts(filename);
cd(filedir)

% Second output here to silence result of command in command window.
[result, ~] = system(sprintf('git ls-files --error-unmatch -- %s', [name ext]));

% Exit code of 0 means the file is tracked by git.
if result == 0
    status = true;

else
    status = false;

end

% Back from whence you came.
cd(startdir)


