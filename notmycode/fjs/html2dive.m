function [x,y]=html2dive(serial,seq,diro)
% [x,y]=HTML2DIVE(serial,seq,diro)
%
% Plots Mermaid dive cycles from AUTOMAID processed html files
%
% INPUT:
%
% serial     A Mermaid's serial number
% seq        A sequential indexing the file list
% diro       The directory in which to find the html files     
%
% OUTPUT:
%
% x          A cell with a datetime array
% y          A cell depth in meters for those dates
% 
% TESTED ON:
%
% 9.0.0.341360 (R2016a)
%
% Last modified by fjsimons-at-alum.mit.edu, 03/12/2020
% Last modified by jdsimon@princeton.edu, 23-Mar-2020.

defval('diro',fullfile(getenv('MERMAID'), 'processed'))
defval('seq',1:5)
defval('serial','452.020-P-12')

% Collect a number of directory files
files=ls2cell(fullfile(diro,serial,'20*-*h*m*s'),1);
files=files(seq);

% Work locally
oldpath=pwd;

% For each of those, grab the dive cycle
for index=1:length(files)
  cd(files{index})
  % Parse the files using sed, awk, and regexp to temporary files
  !sed 's/ //g' ??_????????.html | sed 's/\"lines+markers\",\"y":\[/ /g' | awk '{print $2}' | sed 's/],"x\"/ /g' | awk '/ / {print $1}' | sed 's/\,/\n/g' >! y
  !sed 's/ //g' ??_????????.html | sed 's/\"lines+markers\",\"y":\[/ /g' | awk '{print $2}' | sed 's/\],\"x\"\:\[/ /' | awk '{print $2}' | sed 's/\]/ /' | awk '/ / {print $1}' | sed 's/\,/\n/g' | sed 's/\"//g' | sed 's/-//g' | sed 's/://g' >! x
  % Now load the files
  y{index}=load('y');
  x{index}=load('x');
  % Now turn them into date strings
  x{index}=datetime(datevec(datenum(reshape(sprintf('%14.14i',x{index}),14,[])','yyyymmddHHMMSS')));
  % Now remove the files
  system('rm -f x y');
end

% Return to where you were
cd(oldpath)

