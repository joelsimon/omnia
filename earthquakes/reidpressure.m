function EQ = reidpressure(EQ)
% EQ = REIDPRESSURE(EQ)
%
% REIDPRESSURE attaches the expected pressure from reid.m as an extra
% field, '.pressure', to every index (phase) of EQ.TaupTimes.  It is
% called internally, e.g., in sac2evt.m.
%
% Input:
% EQ    EQ without EQ.TaupTimes(:).pressure field
%
% Output
% EQ    EQ with EQ.TaupTimes(:).pressure field
%
% See also: sac2evt.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 11-Sep-2019, Version 2017b on GLNXA64

if isempty(EQ.TaupTimes)
    return

end

if isempty(EQ.MbMlAuthor)
    [EQ.TaupTimes(:).pressure] = deal([]);
    return

end

% Distance is the same for all TaupTimes phases (the distance
% corresponds to the EQ, not the phase).  Skip this event if its
% too distant to use Ml magnitude type per warning thrown in
% woodanderson.m, or too close to use Mb magnitude type per
% warning thrown in gutenbergrichter.m (both called via reid.m).
if deg2km(EQ.TaupTimes(1).distance) >= 600 && strcmpi(EQ.MbMlType, 'Ml')
    [EQ.TaupTimes(:).pressure] = deal([]);
    return

end

if deg2km(EQ.TaupTimes(1).distance) <= 600 && strcmpi(EQ.MbMlType, 'Mb')
    [EQ.TaupTimes(:).pressure] = deal([]);
    return

end

for j = 1:length(EQ.TaupTimes)
    % Use the default frequencies based on magnitude type in reid.m.
    switch EQ.MbMlType
      case 'Mb'
        freq = 1;

      case 'Ml'
        freq = 5;

    end

    switch EQ.TaupTimes(j).model
      case 'ak135'
        Vp = 5800;
        Vs = 3640;

      case 'iasp91'
        Vp = 5800;
        Vs = 3360;

      case 'prem'
        Vp = 5800; % Ignoring "Ocean" layer (Vs = 0).
        Vs = 3200;

    end

    % Main routine to compute pressure.
    expp = reid(EQ.MbMlType, EQ.MbMlMagnitudeValue, EQ.TaupTimes(j).distance, ...
                freq, EQ.TaupTimes(j).incidentDeg, Vp, Vs);

    % The output of reid.m is a 1x2 array of P and S wave pressure [Pa].
    % Use the last character of the phase name (not the first)
    % because this is the incidence (incoming), not takeoff
    % (outgoing), pressure.

    % Remove 'diff', 'g', or 'n', suffix, if it exists.  Other prefixes
    % ('ab', etc.), are handled by purist.m, (nested in
    % taupTime.m, itself nested in arrivaltime.m, above).
    %
    % N.B.: Other phase IASPEI-approved suffixes also exist (e.g., 'dif'
    % in favor of 'diff'; 'pre'; 'PcP2' to mean multiple reflections; 'P''
    % (prime); 'Sb', 'S*', etc.  Being that phangle.m is designed to be
    % called most often as a subfunction of MatTaup I am only coding for
    % phase names acceptable there (e.g., 'PcP2' throws an error and thus
    % I am not coding a rule to remove suffixes that are numbers).
    %
    % See TauP_Instructions.pdf pg. 15 for the relevant suffixes.
    ph_no_suffix = upper(EQ.TaupTimes(j).phaseName);

    if endsWith(ph_no_suffix, 'diff', 'IgnoreCase', true)
        ph_no_suffix = ph_no_suffix(1:end-4);

    end

    if endsWith(ph_no_suffix, {'g' 'n'}, 'IgnoreCase', true)
        ph_no_suffix = ph_no_suffix(1:end-1);

    end

    switch lower(ph_no_suffix(end))
      case 'p'
        expp = expp(1);

      case 's'
        expp = expp(2);

      otherwise
        error(['Phase name must end with either ''P'' or ' ...
               '''S'' (case-insensitive, and ignoring any ' ...
               '''diff'', ''n'', or ''g'' suffix) .'])

    end
    EQ.TaupTimes(j).pressure = expp;

end
