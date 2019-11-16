
% Performs instrument response correction using the function
% 'transfer' in the SAC program.

% out       CASE SENSITIVE* output type
%           'none': displacement (def)
%           'vel' : velocity 
%           'acc' : acceleration
 
% *a recursive call to dir.m uses the specific case input


defval('out', 'none')


if all(~strcmpi({'none' 'vel' 'acc'}, out))
    error('Input ''out'' must be one of: ''none'', ''vel'', or ''acc''')

end

% Retreive every raw SAC file recursively in the dir of interest.
allsac = dir('**/*.SAC');

% Retrieve every processed (response removed) SAC file recursively in
% the dir of interest.
allresp = dir(sprintf('**/*.%s', out));  % Case matters here.