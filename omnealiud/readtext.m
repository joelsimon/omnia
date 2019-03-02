function lynes = readtext(filename,num)
% lynes = READTEXT(filename,num)
%
% Reads and returns each line of a text file in a cell array.
% Essentially copied from MATLAB's fgetl.m help.
%
% Inputs:
% filename       Name of text file 
% num            Number of lines to read before quitting 
%                    (def: read every line)
% Output:
% lynes          Cell array of individual lines  
%
% Ex: (read arbitrarily formatted example data)
%    lynes = READTEXT('test80211.txt')
%
% See also: mgrep.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 10-Jan-2018, Version 2017b

% Default to read entire file. idx counter will never go negative.
defval('num', -1)

% Default output.
lynes = [];

% Open, read, close.
fid = fopen(filename, 'r');
if fid == -1
    error('Cannot read %s. Check path and permissions.', filename)

end

if ~isint(num)
    error('''num'' must be an integer.')

end

% Read one line at a time and (maybe) exit function if the number of
% lines read meets a the limit in input arg 'num'.
idx = 0;
while 1
    tline = fgetl(fid);
    if ~ischar(tline)
        break

    end
    idx = idx + 1;
    lynes{idx} = tline;
    if ~isempty(num) && idx == num
        break

    end
end
fclose(fid);

numlines = length(lynes);
if num ~= -1 && numlines < num
    warning(sprintf(['Requested %i lines read but %s is only %i lines ' ...
                     'long.'], num, filename, numlines))

end
lynes = lynes';
