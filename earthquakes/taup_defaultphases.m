function ph = taup_defaultphases
% ph = TAUP_DEFAULTPHASES
%
% Returns a comma separated list of DEFAULT (not all!) phase names
% used in TauP version 2.1, according to TauP manual.  See
% taup.phase.list on page 5.  This returns a shorter list than
% taup_majorphases.m.
%
% Inputs: None
%
% Outputs: List of TauP version 2.1 default phases names 
%
% Ex: tt = taupTime('ak135',0,taup_defaultphases,'deg',45)
% 
% See also: taup_majorphases.m
%
% Last modified in Ver. 2017b by jdsimon@princeton.edu, 3-Jul-2018.

ph = ['p, s, P, S, Pn, Sn, PcP, ScS, Pdiff, Sdiff, PKP, SKS, PKiKP, ' ...
      'SKiKS, PKIKP, SKIKS'];
