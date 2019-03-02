function x = cpgen(lx, cp, distr1, p1, distr2, p2, plt)
% x = CPGEN(lx, cp, distr1, p1, distr2, p2, plt)
%
% Changepoint Generator.
%
% Generates a time series concatenated at cp. Segment one, x(1:k), is
% a random draw from distribution 'dist1' with parameters 'p1'.
% Segment two, x(k+1:lx), is a random draw from distribution 'dist2'
% with parameters 'p2'.
%
% Inputs:
% lx             Length of time series (def: 1000)
% cp             Changepoint index, where distribution changes (def: 500)
% distr1,2       Distribution names (strings) (def: 'norm','norm')
% p1,2           Cell arrays of parameter for requested distribution 
%                    (def: {0 1},{0 2})
% plt            true to plot (def: false)
%
% Output:
% x              Time series concatenated at cp
%
% Ex. CPGEN('demo')
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 29-Dec-2018, Version 2017b

% Defaults
defval('lx',1000);
defval('cp',500);
defval('distr1','norm')
defval('distr2','norm')
defval('p1',{0 1});
defval('p2',{0 2});
defval('plt',false)

% Demo.
if ischar(lx)
    demo
    return
end

% Sanity.
if cp >= lx
    error('Changepoint ''cp'' greater than or equal to signal length ''lx''.')
end
if ~isint(cp)
    error('Changepoint ''cp'' must be an integer.')
end
if any([~iscell(p1) ~iscell(p2)])
    error('Both ''p1'' and ''p2'' must be cell arrays.')
end

% Combine distribution names and parameters into cells for looping.
dist = {distr1 distr2};
params = {p1 p2};
pts = [{1:cp}  {cp+1:lx}];
x = zeros(lx,1);

%% MAIN ROUTINE
for i = 1:2
    switch dist{i}
      case {'norm' 'normal'}
        % N.B.: {:} notation expands a cell into a comma separated list.
        x(pts{i}) = normrnd(params{i}{:},[length(pts{i}) 1]);
      otherwise
        try
            %% This is terrible; eval is no good.  Expand to other
            %% cases as necessary.
            x(pts{i}) = random(eval(sprintf('distr%i',i)), ...
                               params{i}{:},[length(pts{i}) 1]);
        catch ME
            % Something went awry. Return MEexception for inspection.
            ME
            warning('Something''s wrong. Inspect ME. ''dbquit'' and retry.')
            keyboard
        end
    end
end
%% END MAIN


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The two distributions are not connected. Ergo you won't see one of
% the segments if it's one sample long (not a line).
if plt
    pltx = plot([1:cp],x(1:cp),'k',[cp+1:lx],x(cp+1:end),'b');
    parstr1 = sprintf(repmat('%.1f ',[1 length(p1)]),p1{:});
    parstr2 = sprintf(repmat('%.1f ',[1 length(p2)]),p2{:});    
    legend(sprintf('%s %s',distr1,parstr1), sprintf('%s %s',distr2, ...
                                                    parstr2), ...
           'Location','NW','AutoUpdate','off')
    xlim([1 lx])
end

% Run cpgen twice and plot.
function demo
    figure;
    ax(1) = subplot(2,1,1);
    ax(2) = subplot(2,1,2);
    % Run cpgen twice
    axes(ax(1))
    cpgen(23456,12345,'norm',{0 1},'norm',{1 2},1);
    axes(ax(2))
    cpgen(23456,12345,'logn',{0 1},'ncf',{2 17 5},1);
    title(ax(1),'cpgen.m demo')
