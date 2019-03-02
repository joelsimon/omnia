function out = fx(func, idx)
% out = FX(func, idx)
% 
% FX allows functional indexing or 'output look ahead' as in Python.
% Useful mostly for functions with cell outputs.  Use string 'end' for
% last returned index.  Only returns single output of 'func', no
% arrays.
% 
% Inputs:
% func         Function with (possibly) multiple outputs
% idx          Output index of interest (def: 1)
%                  (an integer, or string 'end')
% Output:
% out          Value of function output at index of interest
%
% Ex1: (return second output of function strsplit)
%    mystr = 'hello.world'
%    FX(strsplit(mystr, '.') ,2)
% 
% Ex2: (return last output of function strsplit)
%     mystr = 'hello.world.whats.up'
%     FX(strsplit(mystr, '.'), 'end')
% 
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 12-Jan-2018, Version 2017b

% Default to return first entry.
defval('idx', 1)

% Sanity.
if ~strcmp(idx, 'end')  && ~isint(idx) 
    error('Input only either integer index, or ''end'' for ''idx''.')
end

% Main.
if iscell(func)
    if strcmp(idx,'end')
        out = func{end};
    else
        out = func{idx};
    end
else
    if strcmp(idx,'end')
        out = func(end);   
    else
        out = func(idx);
    end
end
