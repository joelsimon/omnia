function [CP, filename] = getcp(sac, diro)
% [CP, filename] = GETCP(sac, diro)
%
% GETCP returns the CP structure associated with the input SAC file
% and saved with writechangepoint.m.
%
% Input: 
% sac       SAC filename 
%               (def: '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac')
% diro      Path to directory 'changepoints' directory
%               (def: $MERMAID/events/changepoints)
%
% Output:
% CP        Changepoint structure, or [] if no .cp file found
% filename  Filename of .cp file
%
% Ex: (first run example in writechangepoint.m)
%    sac = '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac';
%    diro = '~/cpsac2evt_example/changepoints';
%    [CP, filename] = GETCP(sac, diro)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 01-May-2019, Version 2017b

% Defaults.
defval('sac', '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac')
defval('diro', fullfile(getenv('MERMAID'), 'events', 'changepoints'))

% Find the .cp file via a recursive directory search.
sans_sac = strrep(strippath(sac), '.sac', '');
cp_dir = dir(fullfile(diro, sprintf('**/%s.cp', sans_sac)));

% Load it, or return empty.
if ~isempty(cp_dir)
    filename = fullfile(cp_dir.folder, cp_dir.name);
    tmp = load(filename, '-mat');
    CP = tmp.CP;
    clear('tmp')

else
    filename = [];
    CP = [];

end
