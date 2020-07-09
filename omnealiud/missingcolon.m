function L = missingcolon(filename)
% L = MISSINGCOLON(FILENAME)
%
% Returns lines of m-files that are not terminated with semicolons.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 07-Jul-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

if exist(filename, 'file') ~= 2
    error('requested filename ''%s'' does not exist in path', filename)

end
info = checkcode(filename);
idx = cellstrfind({info.message}, 'Terminate statement with semicolon to suppress output');
L = [info(idx).line]';
