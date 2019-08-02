function tf = isequalpt0(EQ, CP, h)
% ISEQUALPT0(EQ, CP, h)
%
% Compares fieldname .pt0, the of the first sample offset from the
% reference time in the SAC header (h.B), across and earthquake and
% changepoint structures.
%
% Returns true is EQ(*).TaupTimes(*).pt0 == CP.inputs.pt0 == h.B.
%
% Input:
% EQ         Earthquake structure from cpsac2evt.m 
%               (or getevt.m)
% CP         Changepoint structure from cpsac2evt.m*
%               (or getcp.m)
% h          SAC header from readsac.m
%
% *CP(1) only, in this case, because CP(2) is windowed .pt0 relates
%  the window the CP(1).xax; CP(1).inputs.pt0 ~= CP(2).inputs.pt0
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 02-Aug-2019, Version 2017b

tf = true;
if isstruct(EQ)
    for j = 1:length(EQ)
        for k = 1:length(EQ(j).TaupTimes)
            if ~isequal(EQ(j).TaupTimes(k).pt0, CP.inputs.pt0, h.B)
                tf = false;
                return

            end
        end
    end
elseif ~isequal(CP.inputs.pt0, h.B)
    tf = false;

end
