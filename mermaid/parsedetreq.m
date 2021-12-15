function [det, req, det_idx, req_idx] = parsedetreq(sac)
% [det, req, req_idx] = PARSEDETREQ(sac)
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
%              idx: index of sac s.t. isequal(sac(idx), det.sac))
%         uniq_ser: unique DET/REQ serial numbers
%         uniq_sac: first DET/REQ filename from each unique serial number
%         uniq_idx: index of det.sac s.t. isequal(det.sac(det.uniq_idx), det.uniq_sac)
% only_det/req_ser: unique DET/REQ serial numbers NOT present in REQ/DET list
% only_det/req_sac: DET/REQ filenames from unique DET/REQ serial numbers NOT present in REQ/DET list
% only_det/req_idx: index of det.uniq_sac s.t. isequal(det.uniq_sac(det.only_det_idx), det.only_det_sac)
%
% The final two fields show which MERMAIDs recorded ONLY either a DET or REQ SAC
% file (and not both).  For example, req.only_req_ser = {12, 25} means that
% MERMAIDs 12 and 25 recorded a REQ SAC file but NOT a DET SAC file.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 14-Dec-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Determine which are requested and which are detected.
[det.idx, det.sac] = cellstrfind(sac, 'DET');
[req.idx, req.sac] = cellstrfind(sac, 'REQ');

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

% Sort main (non-unique) list based on serial number.
[det.ser, sidx] = sort(det.ser);
det.sac = det.sac(sidx);
det.idx = det.idx(sidx);

[req.ser, sidx] = sort(req.ser);
req.sac = req.sac(sidx);
req.idx = req.idx(sidx);

% Identify unique sublists.
[det.uniq_ser, det.uniq_idx] = unique(det.ser);
det.uniq_sac = det.sac(det.uniq_idx);

[req.uniq_ser, req.uniq_idx] = unique(req.ser);
req.uniq_sac = req.sac(req.uniq_idx);

% Determine which SAC files only exist DET or REQ.
[det.only_det_ser, det.only_det_idx] = setdiff(det.uniq_ser, req.uniq_ser);
det.only_det_sac = det.uniq_sac(det.only_det_idx);

[req.only_req_ser, req.only_req_idx] = setdiff(req.uniq_ser, det.uniq_ser);
req.only_req_sac = req.uniq_sac(req.only_req_idx);

% Reorder output structs.
det = orderfields(det, ...
                  {'ser', ...
                   'sac', ...
                   'idx', ...
                   'uniq_ser', ...
                   'uniq_sac', ...
                   'uniq_idx', ...
                   'only_det_ser', ...
                   'only_det_sac', ...
                   'only_det_idx'});
req = orderfields(req, ...
                  {'ser', ...
                   'sac', ...
                   'idx', ...
                   'uniq_ser', ...
                   'uniq_sac', ...
                   'uniq_idx', ...
                   'only_req_ser', ...
                   'only_req_sac', ...
                   'only_req_idx'});

% Some checks
if ~isequal(sac(det.idx), det.sac) || ...
        ~isequal(sac(req.idx), req.sac) || ...
        ~isequal(det.sac(det.uniq_idx), det.uniq_sac) || ...
        ~isequal(req.sac(req.uniq_idx), req.uniq_sac) || ...
        ~isequal(det.uniq_sac(det.only_det_idx), det.only_det_sac) || ...
        ~isequal(req.uniq_sac(req.only_req_idx), req.only_req_sac)
    error('indexing issue')

end
