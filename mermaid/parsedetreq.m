function [det, req] = parsedetreq(sac)
% [det, req] = PARSEDETREQ(sac)
%
% Parse an input list of SAC files into separate DET and REQ lists.
%
% Input:
% sac        Cell array of SAC filenames
%
% Output:
% det/req    DET and REQ structures which parse the input list
%
%              ser: all DET/REQ serial numbers
%              sac: all DET/REQ SAC filenames
%         uniq_ser: unique DET/REQ serial numbers
%         uniq_sac: first DET/REQ filename from each unique serial number
% only_det/req_ser: unique DET/REQ serial numbers NOT present in REQ/DET list
% only_det/req_sac: DET/REQ filenames from unique DET/REQ serial numbers NOT present in REQ/DET list
%
% The final two fields show which MERMAIDs recorded ONLY either a DET or REQ SAC
% file (and not both).  For example, req.only_req_ser = {12, 25} means that
% MERMAIDs 12 and 25 recorded a REQ SAC file but NOT a DET SAC file.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 07-Dec-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Determine which are requested and which are detected.
[~, det.sac] = cellstrfind(sac, 'DET');
[~, req.sac] = cellstrfind(sac, 'REQ');

% Winnow SAC files down to unique floats -- there may be requested data, for
% example, for the same event with slightly different interpolated locations.
if ~isempty(det.sac)
    det.ser = getmerser(det.sac);

else
    det.ser = {};

end
if ~isempty(req.sac)
    req.ser = getmerser(req.sac);

else
    req.ser = {};

end

% Only plot MERMAID location once if multiple files exists for each event
% (e.g., REQ multiple phases for same event with slightly different
% interpolated locations).
[det.uniq_ser, det_uniq_idx] = unique(det.ser);
det.uniq_sac = det.sac(det_uniq_idx);

[req.uniq_ser, req_uniq_idx] = unique(req.ser);
req.uniq_sac = req.sac(req_uniq_idx);

% Determine which SAC files only exist DET or REQ.
[det.only_det_ser, only_det_idx] = setdiff(det.uniq_ser, req.uniq_ser);
det.only_det_sac = det.uniq_sac(only_det_idx);

[req.only_req_ser, only_req_idx] = setdiff(req.uniq_ser, det.uniq_ser);
req.only_req_sac = req.uniq_sac(only_req_idx);

% Sort the return master lists based on serial number.
[det.ser, sidx] = sort(det.ser);
det.sac = det.sac(sidx);

[req.ser, sidx] = sort(req.ser);
req.sac = req.sac(sidx);

% Reorder output structs.
det = orderfields(det, {'ser', 'sac', 'uniq_ser', 'uniq_sac', 'only_det_ser', 'only_det_sac'});
req = orderfields(req, {'ser', 'sac', 'uniq_ser', 'uniq_sac', 'only_req_ser', 'only_req_sac'});
