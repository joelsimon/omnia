function TF = issac(filename)
% ISSAC(filename)
%
% ISSAC returns logical true if filename is a SAC file and logical
% false otherwise.
%
% Last modified in Ver. 2017b by jdsimon@princeton.edu, 10-Oct-2018.

% Changelog - 
%
% 10-Oct-2018: Returns false instead of error if input non char.

TF = false;

if ~ischar(filename)
    return

end

if strcmp(upper(suf(strtrim(filename))), 'SAC')
    TF = true;

end
