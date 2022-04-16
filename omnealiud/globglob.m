function fname = globglob(varargin)
% fname = GLOBGLOB(pattern1, pattern, ..., patternN)
%
% Return matched filename pattern, like Python's `glob.glob`
% Beware of odd wildcard expansion, which may differ between systems.
%
% Input:
% pattern   Fileparts pattern (wildcard "*" allowed)
%
% Output:
% fname     Cell array of matched filenames
%
% Ex:
%    GLOBGLOB(getenv('OMNIA'), 'exfiles')
%    GLOBGLOB(getenv('OMNIA'), 'exfiles', '*.sac')
%    GLOBGLOB(getenv('OMNIA'), '*x*s')
%    GLOBGLOB(getenv('OMNIA'), '*x*s', '*.*a*')
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 24-Feb-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% nasty one-liner...
fname = fullfiledir(skipdotdir(dir(fullfile(varargin{:}))));
