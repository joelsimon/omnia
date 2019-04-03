function ha = doubleax(ha,ticktype,xtralabels,foremat)
% ha = DOUBLEAX(ha,ticktype,newlabels,foremat)
%
% Plots second axis label under current label.  Allows two label rows
% at ever tick mark instead of one.  Works on one axis at a time; no
% 'both' option.  New labels vector ('xtralabels') must be same length
% as current labels on the axis of interest.  See example below.
% Simply updates axis labels; does not adjust axis limits.
%
% Input:
% ha              Axis handle (def: gca)
% ticktype        'x' or 'y', case insensitive
% xtralabels      Vector of numbers, not strings, same length as
%                     current axis 
% foremat         Format specifier for sprintf (def: '%f')
%
% Output:
% ha              Updated axis handle
%
% Ex: 
%    p1 = subplot(2,1,1); p2 = subplot(2,1,2);
%    plot(p1,1:10);  plot(p2,-4:-1:-14)
%    xtralabels1 = rand(1,length(p1.XTickLabels));
%    xtralabels2 = rand(1,length(p2.YTickLabels));
%    ha1 = DOUBLEAX(p1,'x',xtralabels1,'%05.1f')
%    ha2 = DOUBLEAX(p2,'y',xtralabels2,'%+6.4f')
%
% Uses \newline which is a Tex interpreter builtin.  
% Not tested with LaTeX or other interpreters' special characters.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 20-Jul-2017, Version 2017b

% Defaults.
defval('ha',gca)
defval('foremat','%f')

% Sanity checks: 
% Verify 'axes' and not 'figure' or other handles passed.
tipe = get(ha,'Type');
if ~strcmp(tipe,'axes')
    errstr = 'Handle must be type ''axes''.\nYou passed type ''%s''.';
    error(sprintf(errstr,tipe))
end

% We dealing with X or Y axis?
switch upper(ticktype)
  case 'X'
    tick = 'Xtick';
    tickLabels ='XTickLabel';
    oldticks = ha.XTick(:);
    oldlabels = ha.XTickLabel(:);
  case 'Y'
    tick = 'Ytick';
    tickLabels ='YTickLabel';
    oldticks = ha.YTick(:);
    oldlabels = ha.YTickLabel(:);
  otherwise
    error('please specify X or Y axis')
end

% Convert double to string and put into vertical cell.
xtralabels = xtralabels(:);
xtralabels = num2str(xtralabels,foremat);
xtralabels = num2cell(xtralabels,2);

% Unzip oldlabels and also convert to desired format.
oldlabels = cellfun(@str2num,oldlabels);
oldlabels = num2str(oldlabels,foremat);
oldlabels = num2cell(oldlabels,2);

% Verify the length of the new labels equals the length of the old
% labels (else strcat on the cell fails).
assert(length(xtralabels)==length(oldlabels),['Length of ''xtralabels'' ' ...
                    'vector must equal length of current X/YTickLabels']);

% Concatenate cells and update axis.
newlabels = strcat(oldlabels,'\newline',xtralabels);
set(ha,tickLabels,newlabels)
