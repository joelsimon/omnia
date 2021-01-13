function tdate = mseed2sac2date(sac)
% tdate = MSEED2SAC2DATE(sac)
%
% Returns the datetime (whole-second precision) of a SAC file converted with
% mseed2sac and its default output filename.
%
% Input:
% sac        MERMAID SAC filename (accepts cell arrays)
%
% Output:
% tdate      Datetime array of UTC starttimes
%
% Ex: (same date; w/ & w/o location "00"; char or cell input)
%    sac = 'MH.P0008..BDH.D.2018.220.014200.SAC'
%    tdate = MSEED2SAC2DATE(sac)
%    sac = 'MH.P0008.00.BDH.D.2018.220.014200.SAC'
%    tdate = MSEED2SAC2DATE(sac)
%    sac = {'MH.P0008..BDH.D.2018.220.014200.SAC' ...
%           'MH.P0008.00.BDH.D.2018.220.014200.SAC'}
%    tdate = MSEED2SAC2DATE(sac)
%
% See also: seistime.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 12-Jan-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Anonymous function to handle string splits
splitter = @(xx) strsplit(xx, '.', 'CollapseDelimiters', false);

% Collect list of SAC files
sac = strippath(sac);
if iscell(sac)
    % Split each SAC file name at every period  '.'
    C = cellfun(@(xx) splitter(xx), sac, 'UniformOutput', false);

    % Construct a datestr from the split fields
    tstr = cellfun(@(xx) [xx{6:end-1}], C, 'UniformOutput', false);

else
    % Same as in the cellular case, minus the cells
    C = splitter(sac);
    tstr = [C{6:end-1}];

end

% Construct datetime array from fields parsed from the filename
fmt = 'uuuuDDDHHmmss';
tdate = datetime(tstr, 'InputFormat', fmt, 'TimeZone', 'UTC');
