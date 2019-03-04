function TF = issac(filename)
% ISSAC(filename)
%
% ISSAC returns logical true if filename is a SAC file and logical
% false otherwise.
%
% Ex:
% ISSAC('centcal.1.BHZ.SAC')
% ISSAC(gca)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 10-Oct-2018, Version 2017b
% Last modified in Ver. 2017b by jdsimon@princeton.edu, 10-Oct-2018.

TF = false;
if ~ischar(filename)
    return

end

if endsWith(upper(filename), 'SAC')
    TF = true;

end
