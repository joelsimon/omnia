function s = simon2021gji_rmcppt
% s = simon2021gji_rmcppt
%
% !!! ONLY FOR:  wlen = 30, lohi = [1 5], wlen2 = [1.75] !!!
%
% Returns the list of 4 SAC files from CPPT stations which were
% zero-filled at/near the time of the expected first arrival, and
% must therefore be removed from consideration.
%
% For their identification,
% see also: simon2021gji_inspect_zerflag.m
%
% s =
%    {'2018.269.0037.00.TVO.CPZ1.SHZ.SAC'}
%    {'2018.298.1834.00.RKT.CPZ1.SHZ.SAC'}
%    {'2018.316.1754.00.VAH.CPZ1.SHZ.SAC'}
%    {'2019.267.0718.00.PAE.CPZ1.SHZ.SAC'}
%
%
% Developed as: simon2020_rmcppt.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 17-Mar-2020, Version 2017b on MACI64

s= {'2018.269.0037.00.TVO.CPZ1.SHZ.SAC' ...
    '2018.298.1834.00.RKT.CPZ1.SHZ.SAC' ...
    '2018.316.1754.00.VAH.CPZ1.SHZ.SAC' ...
    '2019.267.0718.00.PAE.CPZ1.SHZ.SAC'};
s = s(:);
