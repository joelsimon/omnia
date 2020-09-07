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

defval('diro','/u/fjsimons/MERMAID/processed')
defval('seq',1:5)
defval('serial','452.020-P-12')

% Collect a number of directory files
files=ls2cell(fullfile(diro,serial,'20*-*h*m*s'),1);
files=files(seq);

% Work locally
oldpath=pwd;

% Processing suites, remember to double-quote
pone=['sed ''s/ //g'' ??_????????.html'];
ptwo=['sed ''s/\"lines+markers\",\"y":\[/ /g'''];
ptri=['awk ''{print $2}'''];
% Divergence for the two cases
pfoa=['sed ''s/],"x\"/ /g'''];
pfob=['sed ''s/\],\"x\"\:\[/ /'''];
pfva=['awk ''/ / {print $1}'''];
pfvb=['awk ''{print $2}'''];
psxa=['sed ''s/\,/\n/g'''];
psxb=['sed ''s/\]/ /'''];
% The last bits
psvb=['awk ''/ / {print $1}'''];
patb=['sed ''s/\,/\n/g'''];
pnnb=['sed ''s/\"//g'''];
ptnb=['sed ''s/-//g'''];
plvb=['sed ''s/://g'''];

% For each of those, grab the dive cycle
for index=1:length(files)
  cd(files{index})
  % Parse the files using sed, awk, and regexp to temporary files
  system(sprintf('%s | %s | %s | %s | %s | %s >! y',pone,ptwo,ptri,pfoa,pfva, ...
                 psxa));
  system(sprintf(['%s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s>! ' ...
                  'x'],pone,ptwo,ptri,pfob,pfvb,psxb,psvb,patb,pnnb,ptnb,plvb));
  % Now load the files
  y{index}=load('y');
  x{index}=load('x');
  % Now turn them into date strings
  x{index}=datetime(datevec(datenum(reshape(sprintf('%14.14i',x{index}),14, ...
                                            [])','yyyymmddHHMMSS')));
  % Now remove the files
  system('rm -f x y');
end

% Return to where you were
cd(oldpath)