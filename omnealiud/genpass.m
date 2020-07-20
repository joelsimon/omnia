function password = genpass(len)
% password = GENPASS(len)
%
% Generate a random password of the desired length (min. 8; def: 16)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 20-Jul-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

%% Recursive.

% Default password length.
defval('len', 16);

% Sanity.
if ~isint(len)
    error('Input must be an integer')

end
if len < 8
    error('Minimum password length of 8 characters')

end

% The non-empty ascii set spans char indices 33 through 126.
rng('shuffle')
ascii_idx = randi([33 126], 1, len);

% Ensure no two successive chars are the same.
if any(find(diff(ascii_idx) == 0))

    %% Recursion.

    password = genpass(len);
    return

end
password = char(ascii_idx);
