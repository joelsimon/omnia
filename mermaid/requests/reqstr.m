function cmd = reqstr(sac_date, sac_duration, sac_scales)
% cmd = REQSTR(sac_date, sac_duration, sac_scales)
%
% Return request formatted for .cmd file: "mermaid REQUEST:date,duration,scales."
%
% Input:
% sac_date      Datetime in UTC of first-requested sample [char]
% sac_duration  Length in integer seconds of requested seismogram [double]
% sac_scales    Number of wavelet scales (1:5), or -1 for raw counts [double]
%
% Output:
% cmd           "mermaid REQUEST"-formatted command for .cmd file
%
% Ex: (request raw SAC file that starts now and contains for 100 s)
%    sac_date = datetime('now', 'TimeZone', 'UTC');
%    sac_duration = 100;
%    sac_scales = -1;
%    cmd = REQSTR(sac_date, sac_duration, sac_scales)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 18-Jun-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

% Sanity.
if ~isa(sac_date, 'datetime')
    error('''sac_date'' must a datetime object')

end
if ~strcmp(sac_date.TimeZone, 'UTC')
    error('''sac_date'' .TimeZone must be UTC')

end
if ~isint(sac_duration)
    error('''sac_duration'' must be an integer')

end
if sac_duration <= 0
    error('''sac_duration'' must be positive')

end
if ~ismember(sac_scales, [-1:5])
    error('''sac_scales'' must be an integer between -1 and 5')

end
if sac_duration > 1800
    error('''sac_duration'' cannot be greater than 1800 (must split to multline request')

end

% Convert datetime to datestr with proper format.
sac_datestr = reqdate(sac_date);

% Format the request as "mermaid REQUEST:date,duration,scales."
cmd = sprintf('mermaid REQUEST:%s,%i,%i', sac_datestr, sac_duration, sac_scales);
