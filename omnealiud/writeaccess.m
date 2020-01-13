function writeaccess(lock, filename, warn)
% WRITEACCESS(lock, filename, warn)
%
% Manage write access to an input file.
%
% Input:
% lock       'lock': restrict write access (def)
%            'unlock': grant write access
% filename   Filename to restrict or grant write access
% warn       logical true to warn if filename does not exist
%                (def: true)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 27-Dec-2019, Version 2017b on MACI64

defval('lock', 'lock')
defval('warn', true)

if exist(filename, 'file') ~= 2
    if warn
        warning('filename %s does not exist', filename)

    end
    return

end

switch lower(lock)
  case 'lock'
    wstatus = fileattrib(filename, '-w', 'a');
    if wstatus == 0
        error('Unable to restrict write access to %s.', filename)

    end

  case 'unlock'
    wstatus = fileattrib(filename, '+w', 'a');
    if wstatus == 0
        error('Unable to grant write access to %s.', filename)

    end

  otherwise
    error('First input must be either ''lock'' or ''unlock''')

end
