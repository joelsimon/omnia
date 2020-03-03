function [s, EQ, evtpath] = fullsacevt(s, sdiro, evtdiro)
% [s, EQ, evtpath] = FULLSACEVT(sac, sdiro, evtdiro)
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
%
% Output:
% s         Single SAC filename with full path appended
%               (def: [])
% EQ        Associated EQ structure (def: [])
% evtpath   Full path to evtfile containing EQ structure
%               (def: [])
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 27-Feb-2020, Version 2017b on GLNXA64

% Defaults.
defval('s', '20180810T055938.09_5B6F01F6.MER.DET.WLT5.sac')
defval('sdiro', getenv('MERMAID'))
defval('evtdiro', sdiro)
EQ = [];
evtpath = [];

if ~contains(s, {'sac' 'SAC'})
    error('Input ''s'' must contain ''sac'' or ''SAC''')

end

s = fullsac(s, sdiro);

if ~isempty(s)

    % Replace 'sac' or 'SAC' with 'evt' and chop off off any appendages
    % (e.g., '.none', '.vel', or '.acc').
    nopath_s = strippath(s);
    idx = strfind(lower(nopath_s), 'sac');
    evtname = nopath_s(1:idx-1);
    evtname = [evtname 'evt'];
    evtpath = fullsac(evtname, evtdiro);

    if ~isempty(evtpath)
        tmp = load(evtpath, '-mat');
        EQ = tmp.EQ;
        clear tmp;

    end
end
