function EQ = updateevt(EQ)
% EQ = UPDATEEVT(EQ)
%
% UPDATEEVT updates various EQ structure fields with their correct
% fieldnames and/or values.  EQ structures are saved in .evt files
% output by cpsac2evt.m
%
% Corrections, should they become necessary, should be added here:
% e.g., first-generation EQ structures incorrectly computed incidence
% angle.  Further, I changed the fieldname from tt.incidenceAngle to
% tt.incidentDeg.
%
% Input/Output:
% EQ           Event structure 'EQ' saved by cpsac2evt.m
%
% See also: cpsac2evt.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 23-Mar-2019, Version 2017b

% Update FileName field.
if isfield(EQ, 'FileName')
    EQ.Filename = EQ.FileName;
    EQ = rmfield(EQ, 'FileName');

end

% Update incidence angle computation.
tt = EQ.TaupTimes;
for i = 1:length(tt)
    % Recompute correct incidence angles with and corresponding pressure.
    if isfield(tt(i), 'incidenceAngle')
        rmfield(tt(i), 'incidenceAngle');
        [~, ~, tt(i).incidentDeg, tt(i).incidentRad] = phangle(tt(i).rayParam, ...
                                                         tt(i).phaseName, ...
                                                         tt(i).model);

        % Skip updating the pressure if this event if its too distant to use
        % Ml magnitude type per warning thrown in woodanderson.m, or
        % too close to use Mb magnitude type per warning thrown in
        % gutenbergrichter.m (both called via reid.m).
        if deg2km(tt(i).distance) >= 600 && strcmpi(EQ.MbMlType, 'Ml')
            tt(i).pressure = [];
            continue
            
        end

        if deg2km(tt(i).distance) <= 600 && strcmpi(EQ.MbMlType, 'Mb')
            tt(i).pressure = [];
            continue
            
        end

        % Update the pressure, if MbMlType field exists.
        if ~isempty(EQ.MbMlType)
            % Use the default frequencies based on magnitude type in reid.m.
            switch EQ.MbMlType
              case 'Mb'
                freq = 1;

              case 'Ml'
                freq = 5;

            end
            switch tt(i).model
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
            expp = reid(EQ.MbMlType, EQ.MbMlMagnitudeValue, tt(i).distance, ...
                        freq, tt(i).incidentDeg, Vp, Vs);

            % The output of reid.m is a 1x2 array or P and S wave pressure.  Use
            % the last character of the phase name (not the first)
            % because this is the incidence (incoming), not takeoff
            % (outgoing), pressure.
            switch upper(tt(i).phaseName(end))
              case 'P'
                expp = expp(1);
                
              case 'S'
                expp = expp(2);

            end
            tt(i).pressure = expp;
            
        end
        tt(i) = orderfields(tt(i));
        
    end
end

% Delete and rewrite TaupTimes field, which may be unaltered if the
% above loop was not entered.
EQ = rmfield(EQ, 'TaupTimes');
EQ.TaupTimes = tt;
EQ = orderfields(EQ);
