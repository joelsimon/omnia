function cmd = reqdet(sac)
% cmd = REQDET(sac)
%
% Return formatted MERMAID command to request a detected SAC file.
%
% Input:
% sac      SAC filename, in automaid v0.1.0+ format,
%          corresponding to third-generation MERMAID
%          def('20180629T170731.06_5B3F1904.MER.DET.WLT5.sac')
%
% Output:
% cmd      Formatted "mermaid REQUEST" command corresponding to input SAC file
%
% Ex: (request detected file '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac')
%    sac = '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac';
%    cmd = REQDET(sac)
%
% Author: Dr. Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 07-Sep-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default.
defval('sac', '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac')

% Sanity.
if ~issac(sac)
    error(sprintf('%s is not an automaid-generated SAC file', sac))

end
if ~contains(sac, 'DET')
    error(sprintf('%s is not a detected (triggered) SAC file', sac))

end

% Fetch UTC time of first and samples of seismogram.  NB: I could use
% mersac2date here to use the SAC filename itself to determine the timing (with
% truncated-integer precision) of the first sample. However, that time is
% truncated (I want it to be exact), and future versions of automaid may write
% the filename differently.  Use seistime.m to actually read the header.
[~, header] = readsac(sac);
sac_date = seistime(header);

% Use the UTC time of the first sample as the request date.
sac_date = sac_date.B;

% Compute duration of seismogram to integer seconds.
sac_duration = ceil(header.E - header.B);

% Determine if this file was transmitted in raw (*MER.DET.RAW.sac) binary counts
% or as wavelet coefficient (*MER.DET.WLT?.sac) sets.
idx = strfind(sac, 'WLT');
if ~isempty(idx)
    sac_scales = str2double(sac(idx+3));

else
    % Raw counts.
    sac_scales = -1;

end

% Format the request as "mermaid REQUEST:date,duration,scales."
cmd = reqstr(sac_date, sac_duration, sac_scales);
