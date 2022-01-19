function fname = fullfiledir(dur)
% fname = FULLFILEDIR(dur)
%
% Return cell array of fullfile names given `dir` structure.
%
% Input:
% dur        Structure output by `dir`
%
% Output:
% fname      Cell array of fulfile names ([dur.folder dur.name])
%
% Ex:
%    fname = FULLFILEDIR(dir(pwd))
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 18-Jan-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

fname = {};

for i = 1:length(dur)
    fname{i} = fullfile(dur(i).folder, dur(i).name);

end
fname = fname';
