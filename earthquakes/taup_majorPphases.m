function ph = taup_majorPphases
% ph = TAUP_MAJORPPHASES
% 
% Returns list of all 'major' P phases present from 0-180 degrees in
% Earth model ak135, as noted pp. 161 of "Seismological Tables: ak135"
% by B.L.N. Kennett (kennett+2005), converted to 'purist' name (no
% 'ab', 'bc' branch suffixes) for use in TauP.
%
% ph = ['P, PP, PcP, PKP, PKIKP']
%
% Inputs: None
%
% Outputs: List of TauP version 2.1 default phases names 
%
% From kennett+2005 Section 5:
% 
% "Summary Tables for Major Phases
%
% Phase times and slownesses are shown at 1° intervals for a selection
% of important phases, with separate tables for 0, 100, 300 and 600 km depth
%
% 1 Mostly mantle phases out to 124°
% P, PP, PcP, S, SS, ScS, ScP, SKSac
%
% 2 Mostly core phases from 110°-180°
% PKPab, PKPbc, PKPdf, PP, SKSac, SKSdf, SKP, SS"
%
% Note: SKSac bottoms in outer core (SKS); SKSdf bottoms in inner core
% (SKIKS). Changed branch names to 'purist' names for TauP. See
% Section 4: Phase naming in TauP, point 9 in TauP Manual V2.1.
%
% Ex: tt = taupTime('ak135',0,taup_majorphases,'deg',140)
%
% See also: taup_majorphases.m, taup_defaultphases.m
%
% Last modified in Ver. 2017b by jdsimon@princeton.edu, 2-Jul-2018.

ph = ['P, PP, PcP, PKP, PKIKP'];
