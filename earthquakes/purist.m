function ph = purist(ph)
% ph = PURIST(ph)
%
% PURIST converts NON-REFLECTED seismic core phase names suffixed with
% 'ab', 'bc', 'ac', or 'df', from their IASPEI-approved phase-naming
% convention to the 'purist' naming scheme of TauP
% (TauP_Instructions.pdf pg. 16 paragraph 9).
%
% PURIST is not smart -- it uses the simple rules that:
%    *phases suffixed with 'ab', 'bc', 'ac' bottom in the outer core
%    *phases suffixed with 'df' bottom in the inner core
% 
% Input:
% ph                 IASPEI approved core-phase name, as listed at
%                        http://www.isc.ac.uk/standards/phases/
%
% Output:
% ph                 Phase name acceptable as TauP input
%
% Ex1: Non-reflected phases work as expected
%    PURIST('PKPab')
%    PURIST('SKPbc')
%    PURIST('SKSac')
%    PURIST('PKPdf')
%
% Ex2: Reflected and primed-phases throw an error
%    PURIST('P''P''')
%    PURIST('S3KSac')
%    PURIST('PKKPdf')
%    
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 19-Mar-2019, Version 2017b

% Wish list: handling for (multiply-)reflected phases (SKKSdf,
% S3KSac), primed phases (P'P'), for which the string conversion rules
% are non-trivial.

% Sanity.
if ~ischar(ph)
    error('Input character array for ''ph''')

end

% Doesn't handle primed-phases.
ph = strtrim(ph);
if contains(ph, '''')
        error(sprintf('No rule to convert %s to its purist name', ph))

end

% Parse the phase suffix.
suffix = ph(end-1:end);
ph_no_suffix = ph(1:end-2);

% Does not handle multiply-reflected phases at the moment.
switch suffix
  case {'ab', 'bc', 'ac'}
    if length(ph_no_suffix) ~= 3
        error(sprintf('No rule to convert %s to its purist name', ph))
        
    else
        % Bottoms in outer core; chop the suffix off.
        ph = ph_no_suffix;
        
    end
  case  'df'
    if length(ph_no_suffix) ~= 3
        error(sprintf('No rule to convert %s to its purist name', ph))
        
    else
        % Bottoms in inner core; insert 'IK' as third and fourth characters.
        ph = [ph_no_suffix(1:2) 'IK' ph_no_suffix(3)];
        
    end
end
