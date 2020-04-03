function [s, EQ, evtpath] = fullsacevt(s, sdiro, evtdiro, ofuse)
% [s, EQ, evtpath] = FULLSACEVT(sac, sdiro, evtdiro, ofuse)
%
% Return fullpath SAC filename and EQ structure assuming they live
% somewhere (possibly multiple directories deep) in their respective
% directories, 'sdiro' and 'evtdiro.'  The evt filename must match the
% SAC filename completely up to 'sac' or 'SAC', e.g.,
% s = '.../IU.XMAS.20.HNZ.2019.192.17.15.58.SAC.none' would have an
% associated evtpath = '.../IU.XMAS.20.HNZ.2019.192.17.15.58.evt'
%
% Input:
% s         Single SAC filename, perhaps without full path
%               (def: '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac')
% sdiro     Directory where SAC file lives (def: $MERMAID)
% evtdiro   Directory where evt file lives (def: sdiro)
% ofuse     String which may be of use to find filename in
%               fullsac.m (see there)
%
% Output:
% s         Single SAC filename with full path appended
%               (def: [])
% EQ        Associated EQ structure (def: [])
% evtpath   Full path to evtfile containing EQ structure
%               (def: [])
%
% See also: fullsac.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 02-Apr-2020, Version 2017b on MACI64

% Defaults.
defval('s', '20180810T055938.09_5B6F01F6.MER.DET.WLT5.sac')
defval('sdiro', getenv('MERMAID'))
defval('evtdiro', sdiro)
defval('ofuse', []);
EQ = [];
evtpath = [];

% Ensure this filename follows naming scheme used to locate its corresponding
% .evt file (by swapping .SAC for .evt).
if ~contains(s, {'sac' 'SAC'})
    error('Input ''s'' must contain ''sac'' or ''SAC''')

end

% Get the fullpath SAC filename.
s = fullsac(strippath(s), sdiro, [], ofuse);

if ~isempty(s)

    % Replace 'sac' or 'SAC' with 'evt' and chop off off any appendages
    % (e.g., '.none', '.vel', or '.acc').
    nopath_s = strippath(s);
    idx = strfind(lower(nopath_s), 'sac');
    evtname = nopath_s(1:idx-1);
    evtname = [evtname 'evt'];
    evtpath = fullsac(evtname, evtdiro, [], ofuse);

    if ~isempty(evtpath)
        tmp = load(evtpath, '-mat');
        EQ = tmp.EQ;
        clear tmp;

    end
end
